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

  TCustomRestService = class(TInterfacedObject)
  private
    FConverter: TCustomJsonConverter;
    FRequestFactory: IRestRequestFactory;
    FBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
  protected
    procedure CheckError(Response: IRestResponse);
    function CreateConverter: TCustomJsonConverter;
    function Converter: TCustomJsonConverter;
    property RequestFactory: IRestRequestFactory read FRequestFactory;
  public
    constructor Create(const BaseUrl: string);
    destructor Destroy; override;
    function CreateRequest(const UrlPath, HttpMethod: string): IRestRequest;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
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

constructor TCustomRestService.Create(const BaseUrl: string);
begin
  inherited Create;
  Self.BaseUrl := BaseUrl;
  FRequestFactory := DefaultRequestFactory;
end;

function TCustomRestService.CreateConverter: TCustomJsonConverter;
begin
  Result := TCustomJsonConverter.Create;
end;

function TCustomRestService.CreateRequest(const UrlPath, HttpMethod: string): IRestRequest;
var
  Url: string;
begin
  Result := RequestFactory.CreateRequest;
  Url := BaseUrl;
  if (Length(UrlPath) > 0) and (UrlPath[1] <> '/') then
    Url := Url + '/';
  Url := Url + UrlPath;
  Result.SetUrl(Url);
  Result.SetMethod(HttpMethod);
end;

destructor TCustomRestService.Destroy;
begin
  FConverter.Free;
  inherited;
end;

procedure TCustomRestService.SetBaseUrl(const Value: string);
begin
  if Value = '' then
    raise EArgumentException.Create('Invalid BaseUrl');
  FBaseUrl := Value;

  // Normalize BaseUrl by removing trailing slash
  if (Length(FBaseUrl) > 0) and (FBaseUrl[Length(FBaseUrl)] = '/') then
    FBaseUrl := Copy(FBaseUrl, 1, Length(FBaseUrl) - 1);
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

initialization
  DefaultRequestFactory := THttpRestRequestFactory.Create;;
end.
