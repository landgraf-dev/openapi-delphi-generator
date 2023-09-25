unit OpenApiGen.V3.Analyzer;

interface

uses
  Generics.Collections, SysUtils, Classes, TypInfo, StrUtils,

  Bcl.Logging,
  XData.JSchema.Classes,
  OpenAPI.V3.Document,
  OpenAPI.Types,

  OpenApiGen.Options,
  OpenApiGen.CustomAnalyzer,
  OpenApiGen.Metadata;

type
  TOpenApiAnalyzer = class(TOpenApiCustomAnalyzer)
  strict private
    FDocument: TOpenApiDocument;
    function GetBaseUrl: string;
    function BuildMetaMethod(Method: TMetaMethod; const Path: string; Operation: TOperation; const HttpMethod: string): Boolean;
    procedure ProcessPathItem(const Path: string; PathItem: TPathItem);
    procedure ProcessOperation(const Path: string; PathItem: TPathItem; Operation: TOperation; const HttpMethod: string);
    procedure BuildMetaParam(MetaParam: TMetaParam; Param: TParameter; const MethodName: string);
    procedure DoSolveServiceOperation(var ServiceName, ServiceDescription, OperationName: string;
      const Path: string; PathItem: TPathItem; Operation: TOperation);
  strict protected
    function MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string; ListType: TListType): IMetaType; override;
  public
    procedure Analyze(ADocument: TOpenApiDocument);
    property Document: TOpenApiDocument read FDocument;
  end;

const
  MimeTypeJson = 'application/json';

implementation

function ChooseStr(const S1, S2: string): string;
begin
  if S1 <> '' then
    Result := S1
  else
    Result := S2;
end;

{ TOpenApiAnalyzer }

procedure TOpenApiAnalyzer.Analyze(ADocument: TOpenApiDocument);
var
  Path: TPair<string, TPathItem>;
  Schema: TPair<string, TJsonSchema>;
begin
  FDocument := ADocument;

  // Build meta information
  MetaClient.Clear;

  for Schema in Document.Components.Schemas do
    MetaTypeFromSchema(Schema.Value, Schema.Key, TListType.ltAuto);
  for Path in Document.Paths do
    ProcessPathItem(Path.Key, Path.Value);

  MetaClient.InterfaceName := Format('I%sClient', [Options.ClientName]);
  MetaClient.ClientClass := Format('T%sClient', [Options.ClientName]);
  MetaClient.ConfigClass := Format('T%sConfig', [Options.ClientName]);
  MetaClient.BaseUrl := GetBaseUrl;
end;

function TOpenApiAnalyzer.BuildMetaMethod(Method: TMetaMethod; const Path: string; Operation: TOperation;
  const HttpMethod: string): Boolean;
var
  Param: TParameter;
  ResponseType: IMetaType;
  ResponseItem: TPair<string, TResponse>;
  TargetResponseType: IMetaType;
  MetaParam: TMetaParam;
  ErrorMsg: string;
  ListType: TListType;
  ConsumesJson: Boolean;
  ProducesJson: Boolean;
  ContentPair: TPair<string, TMediaType>;
  BodyParamName: string;
begin
  if (Operation.Servers <> nil) and (Operation.Servers.Count > 1) then
    raise Exception.Create('Multiple servers are not yet supported');

  Result := False;
  try
    Method.HttpMethod := HttpMethod;
    Method.UrlPath := Path;

    if Operation.Parameters <> nil then
      for Param in Operation.Parameters do
      begin
        MetaParam := TMetaParam.Create;
        Method.Params.Add(MetaParam);
        MetaParam.Description := Param.Description;
        BuildMetaParam(MetaParam, Param, Method.CodeName);
      end;

    if Operation.RequestBody <> nil then
    begin
      ConsumesJson := False;
      if Operation.RequestBody.Content <> nil then
        for ContentPair in Operation.RequestBody.Content do
          if SameText(MimeTypeJson, ContentPair.Key) then
          begin
            ConsumesJson := True;

            // Add JSON body param
            MetaParam := TMetaParam.Create;
            Method.Params.Add(MetaParam);
            MetaParam.Description := Operation.RequestBody.Description;

            BodyParamName := 'Body';
            MetaParam.RestName := BodyParamName;
            MetaParam.CodeName := ProcessNaming(MetaParam.RestName, Options.ServiceOptions.ParamNaming);
            MetaParam.ParamType := MetaTypeFromSchema(ContentPair.Value.Schema, Method.CodeName + 'Input', TListType.ltAuto);
            MetaParam.Location := TParamLocation.plBody;
          end;
      if ConsumesJson then
        Method.Consumes := MimeTypeJson
      else
        raise EOpenApiAnalyzerException.CreateFmt('Request body is present in method "%s" but does not consume JSON', [Method.UrlPath]);
    end;

    ProducesJson := False;
    ResponseType := nil;
    for ResponseItem in Operation.Responses do
      if ((ResponseItem.Key = 'default') or (StrToInt(ResponseItem.Key) < 300)) and Assigned(ResponseItem.Value.Content) then
      begin
        for ContentPair in ResponseItem.Value.Content do
          if SameText(MimeTypeJson, ContentPair.Key) then
            begin
              ProducesJson := True;

              if Options.XDataService then
                ListType := TListType.ltArray
              else
                ListType := TListType.ltAuto;

              TargetResponseType := MetaTypeFromSchema(ContentPair.Value.Schema, Method.CodeName + 'Output', ListType);
              if ResponseType = nil then
                ResponseType := TargetResponseType
              else
              if ResponseType.TypeName <> TargetResponseType.TypeName then
                raise EOpenApiAnalyzerException.CreateFmt('Ambiguous response types: %s and %s', [ResponseType.TypeName, TargetResponseType.TypeName]);
            end;
      end;
    Method.ReturnType := ResponseType;
    if (ResponseType <> nil) and not ResponseType.IsBinary then
      if ProducesJson then
        Method.Produces := MimeTypeJson
      else
        raise EOpenApiAnalyzerException.CreateFmt('Response body is present in method "%s" but does not produce JSON', [Method.UrlPath]);
    Result := True;
  except
    on E: EOpenApiAnalyzerException do
    begin
      Method.Ignore := True;
      ErrorMsg := Format('Import of %s %s failed: %s', [HttpMethod, Path, E.Message]);
      Logger.Warning(ErrorMsg);
    end
    else
      raise;
  end;
end;

procedure TOpenApiAnalyzer.BuildMetaParam(MetaParam: TMetaParam; Param: TParameter; const MethodName: string);

  procedure DefineStyleAndExplode(DefaultStyle: TStyle; out Style: TStyle; out Explode: Boolean);
  begin
    if Param.Style.IsAssigned then
      Style := Param.Style
    else
      Style := DefaultStyle;
    if Param.Explode.IsAssigned then
      Explode := Param.Explode
    else
      Explode := Style = TStyle.Form;
  end;

var
  Style: TStyle;
  Explode: Boolean;
begin
  if Param.Schema = nil then
    raise EOpenApiAnalyzerException.CreateFmt('%.%s: missing schema', [MethodName, Param.Name]);
  if Param.Content <> nil then
    raise EOpenApiAnalyzerException.CreateFmt('%.%s: content property not supported', [MethodName, Param.Name]);

  MetaParam.RestName := Param.Name;
  MetaParam.CodeName := ProcessNaming(Param.Name, Options.ServiceOptions.ParamNaming);
  case Param.&In of
    Query:
      begin
        DefineStyleAndExplode(TStyle.Form, Style, Explode);
        if Style <> TStyle.Form then
          raise EOpenApiAnalyzerException.CreateFmt('%.%s: style not supported', [MethodName, Param.Name]);

        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plQuery;
      end;
    Path:
      begin
        DefineStyleAndExplode(TStyle.Simple, Style, Explode);
        if Style <> TStyle.Simple then
          raise EOpenApiAnalyzerException.CreateFmt('%.%s: style not supported', [MethodName, Param.Name]);

        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plUrl;
      end;
    Header:
      begin
        DefineStyleAndExplode(TStyle.Simple, Style, Explode);
        if Style <> TStyle.Simple then
          raise EOpenApiAnalyzerException.CreateFmt('%.%s: style not supported', [MethodName, Param.Name]);

        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plHeader;
      end;
//    Cookie:
//      begin
//        DefineStyleAndExplode(TStyle.Form, Style, Explode);
//        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
//        MetaParam.Location := TParamLocation.plCookie;
//      end;
  else
    raise EOpenApiAnalyzerException.CreateFmt('Unsupported parameter type: %s', [GetEnumName(TypeInfo(TLocation), Ord(Param.&In))]);
  end;
end;

procedure TOpenApiAnalyzer.DoSolveServiceOperation(var ServiceName, ServiceDescription, OperationName: string; const Path: string;
  PathItem: TPathItem; Operation: TOperation);
var
  Tag: TTag;
  P: Integer;
begin
  ServiceDescription := '';
  case Options.ServiceOptions.SolvingMode of
    TServiceSolvingMode.MultipleClientsFromFirstTagAndOperationId:
      begin
        if Operation.Tags.Count > 0 then
        begin
          ServiceName := Operation.Tags[0];
          if FDocument.Tags <> nil then
          begin
            Tag := FDocument.Tags.Find(ServiceName);
            if Tag <> nil then
              ServiceDescription := Tag.Description;
          end;
        end
        else
          ServiceName := '';
        OperationName := Operation.OperationId;
      end;
    TServiceSolvingMode.MultipleClientsFromXDataOperationId:
      begin
        P := Pos('.', Operation.OperationId);
        ServiceName := Copy(Operation.OperationId, 1, P - 1);
        OperationName := Copy(Operation.OperationId, P + 1);
        if StartsText('I', ServiceName) and EndsText('Service', ServiceName) then
          ServiceName := Copy(ServiceName, 2, Length(ServiceName) - 8);
      end;
  else
    // TServiceSolvingMode.SingleClientFromOperationId
    ServiceName := '';
    OperationName := Operation.OperationId;
  end;
end;

function TOpenApiAnalyzer.GetBaseUrl: string;
var
  Server: TServer;
begin
  Result := '/';
  if Document.Servers <> nil then
  begin
    if Document.Servers.Count > 1 then
      raise Exception.Create('Multiple servers are not yet supported');

    Server := Document.Servers[0];
    Result := Server.Url;
  end;

  if not StartsStr('/', Result) then
    Result := Result + '/';

  // Check if it's relative Url
  if Pos('://', Result) = 0 then
  begin
    if Options.DocumentUrl = '' then
      raise Exception.Create('Cannot determine the URL of the API spec, please provide it using DocumentUrl param');
    Result := Options.DocumentUrl + Result;
  end;
end;

function TOpenApiAnalyzer.MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string;
  ListType: TListType): IMetaType;
var
  ReferencedSchema: TJsonSchema;
begin
  if not Document.Components.Schemas.TryGetValue(RefSchema.SchemaName, ReferencedSchema) then
    raise Exception.CreateFmt('Could not solve reference "%s"', [RefSchema.Ref]);

  // if it's object, then just reference the type. Otherwise, use the referenced type inline
  if ReferencedSchema is TObjectSchema then
    Result := MetaTypeFromObject(RefSchema.SchemaName, TObjectSchema(ReferencedSchema))
  else
    Result := MetaTypeFromSchema(ReferencedSchema, DefaultTypeName, ListType);
end;

procedure TOpenApiAnalyzer.ProcessOperation(const Path: string; PathItem: TPathItem; Operation: TOperation;
  const HttpMethod: string);
var
  OperationName: string;
  MethodName: string;
  ServiceName: string;
  MetaMethod: TMetaMethod;
  Service: TMetaService;
  InterfaceName: string;
  ServiceClassName: string;
  ServiceDescription: string;
begin
  if Operation = nil then Exit;

  // Service Mode
  DoSolveServiceOperation(ServiceName, ServiceDescription, OperationName, Path, PathItem, Operation);

  // Auto-generate operation name
  if OperationName = '' then
    OperationName := BuildOperationName(Path, HttpMethod);

  // Find or create the service
  DoGetServiceName(ServiceName, ServiceName);
  Service := MetaClient.FindService(ServiceName);
  if Service = nil then
  begin
    Service := TMetaService.Create;
    MetaClient.Services.Add(Service);
    Service.ServiceName := ServiceName;
    Service.Description := ServiceDescription;
    DoGetInterfaceName(InterfaceName, ServiceName);
    Service.InterfaceName := InterfaceName;
    DoGetServiceClassName(ServiceClassName, ServiceName);
    Service.ServiceClass := ServiceClassName;
  end;

  // Method name
  DoGetMethodName(MethodName, OperationName);
  MetaMethod := TMetaMethod.Create;
  Service.Methods.Add(MetaMethod);
  MetaMethod.CodeName := MethodName;
  if MetaMethod.CodeName = '' then
    MetaMethod.Ignore := True;
  BuildMetaMethod(MetaMethod, Path, Operation, HttpMethod);

  MetaMethod.Summary := ChooseStr(Operation.Summary, PathItem.Summary);
  MetaMethod.Remarks := ChooseStr(Operation.Description, PathItem.Description);
end;


procedure TOpenApiAnalyzer.ProcessPathItem(const Path: string; PathItem: TPathItem);
begin
  if (Document.Servers <> nil) and (Document.Servers.Count > 1) then
    raise Exception.Create('Multiple servers are not yet supported');

  ProcessOperation(Path, PathItem, PathItem.Get, 'GET');
  ProcessOperation(Path, PathItem, PathItem.Put, 'PUT');
  ProcessOperation(Path, PathItem, PathItem.Post, 'POST');
  ProcessOperation(Path, PathItem, PathItem.Delete, 'DELETE');
  ProcessOperation(Path, PathItem, PathItem.Patch, 'PATCH');
  ProcessOperation(Path, PathItem, PathItem.Options, 'OPTIONS');
  ProcessOperation(Path, PathItem, PathItem.Head, 'HEAD');
  ProcessOperation(Path, PathItem, PathItem.Trace, 'TRACE');
end;

end.
