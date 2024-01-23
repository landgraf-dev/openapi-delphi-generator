unit OpenApiIndy;

{$IF CompilerVersion < 29}
  {$DEFINE USEINDY}
{$IFEND}

interface

uses
  SysUtils, ZLib, Classes, IdHTTP, IdHeaderList, OpenApiRest;

type
  TIndyHTTP = class(TIdHTTP)
  end;

  TClientCreatedEvent = procedure(Client: TIdHttp) of object;

  TIndyRestRequest = class(TRestRequest)
  strict private
    FOnClientCreated: TClientCreatedEvent;
  protected
    procedure DoRedirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
  public
    constructor Create(AOnClientCreated: TClientCreatedEvent);
    function Execute: IRestResponse; override;
  end;

  TIndyRestResponse = class(TInterfacedObject, IRestResponse)
  strict private
    FClient: TIndyHTTP;
    FContent: TStream;
    FBytesLoaded: Boolean;
    FBytes: TBytes;
  public
    constructor Create(Client: TIndyHTTP; const ResponseBody: TBytes);
    destructor Destroy; override;
    function StatusCode: Integer;
    function ContentAsString: string;
    function ContentAsBytes: TBytes;
    function GetHeader(const Name: string): string;
  end;

  TIndyRestRequestFactory = class(TInterfacedObject, IRestRequestFactory)
  private
    FOnClientCreated: TClientCreatedEvent;
  public
    function CreateRequest: IRestRequest;
    property OnClientCreated: TClientCreatedEvent read FOnClientCreated write FOnClientCreated;
  end;

implementation

{ TIndyRestRequestFactory }

function TIndyRestRequestFactory.CreateRequest: IRestRequest;
begin
  Result := TIndyRestRequest.Create(FOnClientCreated);
end;

{ TIndyRestRequest }

constructor TIndyRestRequest.Create(AOnClientCreated: TClientCreatedEvent);
begin
  inherited Create;
  FOnClientCreated := AOnClientCreated;
end;

procedure TIndyRestRequest.DoRedirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean;
  var VMethod: TIdHTTPMethod);
var
  Headers: TIdHeaderList;
  I: Integer;
begin
  Headers := TIndyHttp(Sender).Request.CustomHeaders;
  for I := 0 to Headers.Count - 1 do
    if SameText(Headers.Names[I], 'Authorization') then
    begin
      Headers.Delete(I);
      Break;
    end;
end;

function TIndyRestRequest.Execute: IRestResponse;
var
  Client: TIndyHTTP;
  I: Integer;
  RequestBody: TStringStream;
  ResponseBody: TBytesStream;
begin
  Client := TIndyHTTP.Create;
  try
    Client.HandleRedirects := True;
    Client.OnRedirect := DoRedirect;
    Client.HTTPOptions := Client.HTTPOptions + [hoNoProtocolErrorException, hoWantProtocolErrorContent];
    RequestBody := nil;
    if Body <> '' then
      RequestBody := TStringStream.Create(Body, TEncoding.UTF8, False);
    try
      ResponseBody := TBytesStream.Create;
      try
        Client.Request.Accept := '';
        for I := 0 to Headers.Count - 1 do
          Client.Request.CustomHeaders.AddValue(Headers.Names[I], Headers.ValueFromIndex[I]);
        if Assigned(FOnClientCreated) then
          FOnClientCreated(Client);
        Client.DoRequest(Self.Method, BuildUrl, RequestBody, ResponseBody, []);
        Result := TIndyRestResponse.Create(Client, Copy(ResponseBody.Bytes, 0, ResponseBody.Size));
        Client := nil;
      finally
        ResponseBody.Free;
      end;
    finally
      RequestBody.Free;
    end;
  finally
    Client.Free;
  end;
end;

{ TIndyRestResponse }

constructor TIndyRestResponse.Create(Client: TIndyHTTP; const ResponseBody: TBytes);
begin
  inherited Create;
  FClient := Client;
  FContent := TBytesStream.Create(ResponseBody);
end;

destructor TIndyRestResponse.Destroy;
begin
  FClient.Free;
  FContent.Free;
  inherited;
end;

function TIndyRestResponse.GetHeader(const Name: string): string;
begin
  Result := FClient.Response.RawHeaders.Values[Name];
end;

function TIndyRestResponse.StatusCode: Integer;
begin
  Result := FClient.ResponseCode;
end;

function TIndyRestResponse.ContentAsBytes: TBytes;
const
  BufSize = 65536;
var
  BytesRead: Int64;
  TotalRead: Int64;
begin
  if FBytesLoaded then Exit(FBytes);

  FContent.Position := 0;
  if SameText(FClient.Response.ContentEncoding, 'deflate') then
    FContent := TZDecompressionStream.Create(FContent, 15, True)
  else
  if SameText(FClient.Response.ContentEncoding, 'gzip') then
    FContent := TZDecompressionStream.Create(FContent, 31, True);

  SetLength(FBytes, 0);
  TotalRead := 0;
  repeat
    SetLength(FBytes, Length(FBytes) + BufSize);
    BytesRead := FContent.Read(FBytes[TotalRead], BufSize);
    TotalRead := TotalRead + BytesRead;
  until BytesRead = 0;
  SetLength(FBytes, TotalRead);
  Result := FBytes;
  FBytesLoaded := True;
end;

function TIndyRestResponse.ContentAsString: string;
var
  LCharset: string;
  Encoding: TEncoding;
begin
  LCharset := FClient.Response.CharSet;
  if (LCharSet <> '') and not SameText(LCharSet, 'utf-8') then
  begin
    Encoding := TEncoding.GetEncoding(LCharSet);
    try
      Result := Encoding.GetString(ContentAsBytes);
    finally
      Encoding.Free;
    end;
  end
  else
    Result := TEncoding.UTF8.GetString(ContentAsBytes);
end;

{$IFDEF USEINDY}
initialization
  DefaultRequestFactory := TIndyRestRequestFactory.Create;;
{$ENDIF}

end.
