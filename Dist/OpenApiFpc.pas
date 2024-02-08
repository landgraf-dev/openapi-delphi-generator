unit OpenApiFpc;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  Classes, SysUtils, ZBase, ZLib, OpenApiRest, fphttpclient, opensslsockets;

type
  THttpRestRequest = class(TRestRequest)
  protected
    function InternalExecute: IRestResponse; override;
  end;

  { THttpRestResponse }

  THttpRestResponse = class(TInterfacedObject, IRestResponse)
  strict private
    FClient: TFPHTTPClient;
    FContent: TStream;
    FBytes: TBytes;
    FBytesLoaded: Boolean;
    procedure DecompressBytes(WindowBits: Integer);
  public
    constructor Create(Client: TFPHttpClient; Content: TBytesStream);
    destructor Destroy; override;
    function StatusCode: Integer;
    function ContentAsString: string;
    function ContentAsBytes: TBytes;
    function GetHeader(const Name: string): string;
  end;

  THttpRestRequestFactory = class(TInterfacedObject, IRestRequestFactory)
  public
    function CreateRequest: IRestRequest;
  end;

implementation

{ THttpRestRequestFactory }

function THttpRestRequestFactory.CreateRequest: IRestRequest;
begin
  Result := THttpRestRequest.Create;
end;

{ THttpRestRequest }

function THttpRestRequest.InternalExecute: IRestResponse;
var
  Client: TFPHTTPClient;
  SourceStream: TStream;
  Content: TBytesStream;
  I: Integer;
begin
  Client := TFPHTTPClient.Create(nil);
  try
    if Body <> '' then
      SourceStream := TStringStream.Create(Body, TEncoding.UTF8, False)
    else
      SourceStream := nil;
    try
      for I := 0 to Headers.Count - 1 do
        Client.AddHeader(Headers.Names[I], Headers.ValueFromIndex[I]);
      Client.RequestBody := SourceStream;
      Content := TBytesStream.Create;
      try
        Client.HTTPMethod(Self.Method, BuildUrl, Content, []);
        Result := THttpRestResponse.Create(Client, Content);
        Content := nil;
        Client := nil;
      finally
        Content.Free;
      end;
    finally
      SourceStream.Free;
    end;
  finally
    Client.Free;
  end;
end;

{ THttpRestResponse }

const
  BufSize = 65536;

function THttpRestResponse.ContentAsBytes: TBytes;
const
  BufSize = 65536;
var
  BytesRead: Int64;
  TotalRead: Int64;
begin
  if FBytesLoaded then Exit(FBytes);
  FContent.Position := 0;
  SetLength(FBytes, 0);
  TotalRead := 0;
  repeat
    SetLength(FBytes, Length(FBytes) + BufSize);
    BytesRead := FContent.Read(FBytes[TotalRead], BufSize);
    TotalRead := TotalRead + BytesRead;
  until BytesRead = 0;
  SetLength(FBytes, TotalRead);

  if SameText(GetHeader('Content-Encoding'), 'deflate') then
    DecompressBytes(15)
  else
  if SameText(GetHeader('Content-Encoding'), 'gzip') then
    DecompressBytes(31);

  Result := FBytes;
  FBytesLoaded := True;
end;

function THttpRestResponse.ContentAsString: string;
begin
  Result := TEncoding.UTF8.GetString(ContentAsBytes);
end;

procedure ZDecompress(const inBuffer: TBytes; out outBuffer: TBytes; outEstimate: Integer; bits: Integer);
var
  zstream: Z_Stream;
  delta, inSize, outSize: Integer;
  zresult: Integer;
  code: Integer;
begin
  inSize := Length(inBuffer);
  if inSize = 0 then
    raise Exception.Create(zerror(Z_BUF_ERROR));

  zstream := Default(Z_Stream);
  delta := (inSize + 255) and not 255;

  if outEstimate = 0 then
    outSize := delta
  else
    outSize := outEstimate;
  if outSize = 0 then
    outSize := 16;

  SetLength(outBuffer, outSize);

  try
    zstream.next_in := @inBuffer[0];
    zstream.avail_in := inSize;
    zstream.next_out := @outBuffer[0];
    zstream.avail_out := outSize;

    code := InflateInit2(zstream, bits);
    if code < 0 then
      raise Exception.Create(zerror(code));
    try
      repeat
        zresult := inflate(zstream, Z_NO_FLUSH);
        if (code < 0) and (code <> Z_BUF_ERROR) then
          raise Exception.Create(zerror(code));
        if (zstream.avail_out = 0) and (zresult <> Z_STREAM_END) then
        begin
          Inc(outSize, delta);
          SetLength(outBuffer, outSize);
          zstream.next_out := @outBuffer[zstream.total_out];
          zstream.avail_out := delta;
        end
        else if ((zresult <> Z_STREAM_END) and (zstream.avail_in = 0)) or
                ((zresult = Z_STREAM_END) and (zstream.avail_in <> 0)) then
          raise Exception.Create(zerror(Z_BUF_ERROR));
      until zresult = Z_STREAM_END;

    finally
      code := inflateEnd(zstream);
      if code < 0 then
        raise Exception.Create(zerror(code));
    end;

    SetLength(outBuffer, zstream.total_out);
  except
    SetLength(outBuffer, 0);
    raise;
  end;
end;

procedure THttpRestResponse.DecompressBytes(WindowBits: Integer);
var
  NewBytes: TBytes;
begin
  ZDecompress(FBytes, NewBytes, 0, WindowBits);
  FBytes := NewBytes
end;

constructor THttpRestResponse.Create(Client: TFPHttpClient;
  Content: TBytesStream);
begin
  inherited Create;
  FClient := Client;
  FContent := Content;
end;

destructor THttpRestResponse.Destroy;
begin
  FClient.Free;
  FContent.Free;
  inherited;
end;

function THttpRestResponse.GetHeader(const Name: string): string;
begin
  Result := Trim(FClient.ResponseHeaders.Values[Name]);
end;

function THttpRestResponse.StatusCode: Integer;
begin
  Result := FClient.ResponseStatusCode;
end;

initialization
  DefaultRequestFactory := THttpRestRequestFactory.Create;;
end.
