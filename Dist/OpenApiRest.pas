unit OpenApiRest;

interface

uses
  SysUtils, Classes,
  OpenApiJson;

type
  IRestResponse = interface
  ['{C2CE5CD8-FA9F-442F-9980-988A2A0EFF3D}']
    function StatusCode: Integer;
    function ContentAsString: string;
    function ContentAsBytes: TBytes;
  end;

  IRestRequest = interface
  ['{55328D2F-FC30-48C7-9578-5A8A9152E4DA}']
    procedure SetUrl(const Url: string);
    procedure SetMethod(const Method: string);
    procedure AddQueryParam(const Name, Value: string);
    procedure AddUrlParam(const Name, Value: string);
    procedure AddHeader(const Name, Value: string);
    procedure AddBody(const Value: string);
    function Execute: IRestResponse;
  end;

  IRestRequestFactory = interface
  ['{3F581342-8522-44BD-8D42-1CAFE7DD7CC1}']
    function CreateRequest: IRestRequest;
  end;

  TRestRequest = class(TInterfacedObject, IRestRequest)
  private
    FUrl: string;
    FMethod: string;
    FQueryParams: TStrings;
    FUrlParams: TStrings;
    FHeaders: TStrings;
    FBody: string;
  protected
    function BuildUrl: string;
    function PercentEncode(const Value: string): string; virtual;
    property Body: string read FBody;
    property Method: string read FMethod;
    property Headers: TStrings read FHeaders;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetUrl(const Url: string);
    procedure SetMethod(const Method: string);
    procedure AddHeader(const Name, Value: string);
    procedure AddQueryParam(const Name, Value: string); virtual;
    procedure AddUrlParam(const Name, Value: string); virtual;
    procedure AddBody(const Value: string); virtual;
    function Execute: IRestResponse; virtual; abstract;
  end;

  EOpenApiClientException = class(Exception)
  private
    FResponse: IRestResponse;
  public
    constructor Create(const Msg: string; Response: IRestResponse);
    property Response: IRestResponse read FResponse;
  end;

  IRestConfig = interface
  ['{19651CF9-B9EB-44CA-BF22-802D0EBA6549}']
    function GetAccessToken: string;
    function GetBaseUrl: string;
    procedure SetAccessToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    function GetRequestFactory: IRestRequestFactory;
    procedure SetRequestFactory(const Value: IRestRequestFactory);

    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
    property AccessToken: string read GetAccessToken write SetAccessToken;
    property RequestFactory: IRestRequestFactory read GetRequestFactory write SetRequestFactory;
  end;

  TCustomRestConfig = class(TInterfacedObject, IRestConfig)
  private
    FBaseUrl: string;
    FAccessToken: string;
    FRequestFactory: IRestRequestFactory;
    function GetAccessToken: string;
    function GetBaseUrl: string;
    procedure SetAccessToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    function GetRequestFactory: IRestRequestFactory;
    procedure SetRequestFactory(const Value: IRestRequestFactory);
  public
    constructor Create;
    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
    property AccessToken: string read GetAccessToken write SetAccessToken;
    property RequestFactory: IRestRequestFactory read GetRequestFactory write SetRequestFactory;
  end;

  TCustomRestService = class(TInterfacedObject)
  private
    FConfig: IRestConfig;
    FConverter: TCustomJsonConverter;
    function SanitizedBaseUrl: string;
  protected
    procedure CheckError(Response: IRestResponse);
    function CreateConverter: TCustomJsonConverter;
    function Converter: TCustomJsonConverter;
  public
    constructor Create(Config: IRestConfig); reintroduce;
    destructor Destroy; override;
    function CreateRequest(const UrlPath, HttpMethod: string): IRestRequest;
    property Config: IRestConfig read FConfig;
  end;

  IRestClient = interface
  ['{EC814857-4D41-49E1-BEBB-E2C8A3DFB8B3}']
    function GetConfig: IRestConfig;

    property Config: IRestConfig read GetConfig;
  end;

  TCustomRestClient = class(TInterfacedObject, IRestClient)
  private
    FConfig: IRestConfig;
    function GetConfig: IRestConfig;
  public
    constructor Create(Config: IRestConfig);
    property Config: IRestConfig read GetConfig;
  end;

var
  DefaultRequestFactory: IRestRequestFactory;

implementation

uses
  // refactor this later
  OpenApiHttp;

{ TRestService }

procedure TCustomRestService.CheckError(Response: IRestResponse);
begin
  if (Response.StatusCode < 200) or (Response.StatusCode >= 300) then
    raise EOpenApiClientException.Create('Request failed', Response);
end;

function TCustomRestService.Converter: TCustomJsonConverter;
begin
  if FConverter = nil then
    FConverter := CreateConverter;
  Result := FConverter;
end;

constructor TCustomRestService.Create(Config: IRestConfig);
begin
  inherited Create;
  Self.FConfig := Config;
end;

function TCustomRestService.CreateConverter: TCustomJsonConverter;
begin
  Result := TCustomJsonConverter.Create;
end;

function TCustomRestService.CreateRequest(const UrlPath, HttpMethod: string): IRestRequest;
var
  Url: string;
begin
  Result := Config.RequestFactory.CreateRequest;
  Url := SanitizedBaseUrl;
  if (Length(UrlPath) > 0) and (UrlPath[1] <> '/') then
    Url := Url + '/';
  Url := Url + UrlPath;
  Result.SetUrl(Url);
  Result.SetMethod(HttpMethod);
  if Config.AccessToken <> '' then
    Result.AddHeader('Authorization', 'Bearer ' + Config.AccessToken);
end;

destructor TCustomRestService.Destroy;
begin
  FConverter.Free;
  inherited;
end;

function TCustomRestService.SanitizedBaseUrl: string;
var
  BaseUrl: string;
begin
  BaseUrl := Config.BaseUrl;
  if BaseUrl = '' then
    raise EArgumentException.Create('Invalid BaseUrl');

  // Normalize BaseUrl by removing trailing slash
  if (Length(BaseUrl) > 0) and (BaseUrl[Length(BaseUrl)] = '/') then
    BaseUrl := Copy(BaseUrl, 1, Length(BaseUrl) - 1);
  Result := BaseUrl;
end;

{ TRestRequest }

procedure TRestRequest.AddBody(const Value: string);
begin
  FBody := Value;
end;

procedure TRestRequest.AddHeader(const Name, Value: string);
begin
  FHeaders.Values[Name] := Value;
end;

procedure TRestRequest.AddQueryParam(const Name, Value: string);
begin
  FQueryParams.Values[Name] := Value;
end;

procedure TRestRequest.AddUrlParam(const Name, Value: string);
begin
  FUrlParams.Values[Name] := Value;
end;

function TRestRequest.BuildUrl: string;
var
  I: Integer;
  Name, Value: string;
  Query: string;
begin
  Result := FUrl;
  for I := 0 to FUrlParams.Count - 1 do
  begin
    Name := FUrlParams.Names[I];
    Value := PercentEncode(FUrlParams.ValueFromIndex[I]);

    Result := StringReplace(Result, '{' + Name + '}', Value, [rfIgnoreCase, rfReplaceAll]);
  end;

  Query := '';
  for I := 0 to FQueryParams.Count - 1 do
  begin
    Name := FQueryParams.Names[I];
    Value := PercentEncode(FQueryParams.ValueFromIndex[I]);
    if Query <> '' then
      Query := Query + '&';
    Query := Query + Name + '=' + Value;
  end;

  if Query <> '' then
    Result := Result + '?' + Query;
end;

constructor TRestRequest.Create;
begin
  inherited Create;
  FQueryParams := TStringList.Create;
  FUrlParams := TStringList.Create;
  FHeaders := TStringList.Create;
end;

destructor TRestRequest.Destroy;
begin
  FHeaders.Free;
  FUrlParams.Free;
  FQueryParams.Free;
  inherited;
end;

function TRestRequest.PercentEncode(const Value: string): string;
begin
  {$MESSAGE WARN 'Implement'}
  Result := Value;
end;

procedure TRestRequest.SetMethod(const Method: string);
begin
  FMethod := Method;
end;

procedure TRestRequest.SetUrl(const Url: string);
begin
  FUrl := Url;
end;

{ EOpenApiClientException }

constructor EOpenApiClientException.Create(const Msg: string; Response: IRestResponse);
var
  Content: string;
  ErrorMsg: string;
begin
  ErrorMsg := Msg + sLineBreak + 'status: ' + IntToStr(Response.StatusCode);
  Content := Response.ContentAsString;
  if Content <> '' then
    ErrorMsg := ErrorMsg + sLineBreak + 'Response: ' + Copy(Content, 1, 512);
  FResponse := Response;
  inherited Create(ErrorMsg);
end;

{ TRestConfig }

constructor TCustomRestConfig.Create;
begin
  inherited Create;
  FRequestFactory := DefaultRequestFactory;
end;

function TCustomRestConfig.GetAccessToken: string;
begin
  Result := FAccessToken;
end;

function TCustomRestConfig.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TCustomRestConfig.GetRequestFactory: IRestRequestFactory;
begin
  Result := FRequestFactory;
end;

procedure TCustomRestConfig.SetAccessToken(const Value: string);
begin
  FAccessToken := Value;
end;

procedure TCustomRestConfig.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TCustomRestConfig.SetRequestFactory(const Value: IRestRequestFactory);
begin
  FRequestFactory := Value;
end;

{ TCustomRestClient }

constructor TCustomRestClient.Create(Config: IRestConfig);
begin
  inherited Create;
  FConfig := Config;
end;

function TCustomRestClient.GetConfig: IRestConfig;
begin
  Result := FConfig;
end;

initialization
  DefaultRequestFactory := THttpRestRequestFactory.Create;;
end.
