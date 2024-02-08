unit OpenApiHttp;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient, System.ZLib, OpenApiRest;

type
  TClientCreatedEvent = procedure(Client: THttpClient; Request: IHttpRequest) of object;

  THttpRestRequest = class(TRestRequest)
  strict private
    FOnClientCreated: TClientCreatedEvent;
  strict protected
    function InternalExecute: IRestResponse; override;
  public
    constructor Create(AOnClientCreated: TClientCreatedEvent);
  end;

  THttpRestResponse = class(TInterfacedObject, IRestResponse)
  strict private
    FClient: THttpClient;
    FResponse: IHttpResponse;
    FContent: TStream;
    FWrapped: TStream;
    FBytes: TBytes;
    FBytesLoaded: Boolean;
  public
    constructor Create(Response: IHttpResponse; Content: TBytesStream; Client: THttpClient);
    destructor Destroy; override;
    function StatusCode: Integer;
    function ContentAsString: string;
    function ContentAsBytes: TBytes;
    function GetHeader(const Name: string): string;
  end;

  THttpRestRequestFactory = class(TInterfacedObject, IRestRequestFactory)
  private
    FOnClientCreated: TClientCreatedEvent;
  public
    function CreateRequest: IRestRequest;
    property OnClientCreated: TClientCreatedEvent read FOnClientCreated write FOnClientCreated;
  end;

implementation

{ THttpRestRequestFactory }

function THttpRestRequestFactory.CreateRequest: IRestRequest;
begin
  Result := THttpRestRequest.Create(FOnClientCreated);
end;

{ THttpRestRequest }

constructor THttpRestRequest.Create(AOnClientCreated: TClientCreatedEvent);
begin
  inherited Create;
  FOnClientCreated := AOnClientCreated;
end;

function THttpRestRequest.InternalExecute: IRestResponse;
var
  Request: IHttpRequest;
  Response: IHttpResponse;
  Client: THttpClient;
  SourceStream: TStream;
  Content: TBytesStream;
  I: Integer;
  Url: string;
  LogId: string;
begin
  Client := THttpClient.Create;
  try
    Client.HandleRedirects := False;
    Url := BuildUrl();
    Request := Client.GetRequest(Self.Method, Url);
    if Body <> '' then
      SourceStream := TStringStream.Create(Body, TEncoding.UTF8, False)
    else
      SourceStream := nil;
    for I := 0 to Headers.Count - 1 do
      Request.SetHeaderValue(Headers.Names[I], Headers.ValueFromIndex[I]);
    try
      Request.SourceStream := SourceStream;
      if Assigned(FOnClientCreated) then
       FOnClientCreated(Client, Request);
      if Assigned(Logger) then
        LogId := Logger.LogRequest(Self.Method, Url, SourceStream);

      Content := TBytesStream.Create;
      try
        Response := Client.Execute(Request, Content);
        Result := THttpRestResponse.Create(Response, Content, Client);
        if Assigned(Logger) then
          Logger.LogResponse(Self.Method, Url, LogId, Result);
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

function THttpRestResponse.ContentAsBytes: TBytes;
const
  BufSize = 65536;
var
  BytesRead: Int64;
  TotalRead: Int64;
begin
  if FBytesLoaded then Exit(FBytes);

  FContent.Position := 0;
  if SameText(FResponse.ContentEncoding, 'deflate') then
  begin
    FWrapped := FContent;
    FContent := TZDecompressionStream.Create(FWrapped, 15)
  end
  else
  if SameText(FResponse.ContentEncoding, 'gzip') then
  begin
    FWrapped := FContent;
    FContent := TZDecompressionStream.Create(FWrapped, 31);
  end;
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

function THttpRestResponse.ContentAsString: string;
var
  LCharset: string;
  Encoding: TEncoding;
begin
  LCharset := FResponse.GetContentCharset;
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

constructor THttpRestResponse.Create(Response: IHttpResponse; Content: TBytesStream; Client: THttpClient);
begin
  inherited Create;
  FResponse := Response;
  FClient := Client;
  FContent := Content;
end;

destructor THttpRestResponse.Destroy;
begin
  FClient.Free;
  FContent.Free;
  FWrapped.Free;
  inherited;
end;

function THttpRestResponse.GetHeader(const Name: string): string;
begin
  Result := FResponse.HeaderValue[Name];
end;

function THttpRestResponse.StatusCode: Integer;
begin
  Result := FResponse.StatusCode;
end;

initialization
  DefaultRequestFactory := THttpRestRequestFactory.Create;;
end.
