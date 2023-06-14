unit OpenApiGen.V2.Analyzer;

interface

uses
  Generics.Collections, SysUtils, Classes, TypInfo, StrUtils,

  Bcl.Logging,
  XData.JSchema.Classes,
  OpenAPI.Classes,
  OpenAPI.Classes.Path,
  OpenAPI.Classes.Operation,
  OpenAPI.Classes.Parameter,
  OpenApi.Document,
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

{ TOpenApiAnalyzer }

procedure TOpenApiAnalyzer.Analyze(ADocument: TOpenApiDocument);
var
  Path: TPair<string, TPathItem>;
  Definition: TPair<string, TJsonSchema>;
begin
  FDocument := ADocument;

  // Build meta information
  MetaClient.Clear;
  for Definition in Document.Definitions do
    MetaTypeFromSchema(Definition.Value, Definition.Key, TListType.ltAuto);
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
begin
  Result := False;
  try
    ConsumesJson := Operation.Consumes.Contains(MimeTypeJson);
    if not ConsumesJson and (Operation.Consumes.Count = 0) then
      ConsumesJson := Document.Consumes.Contains(MimeTypeJson);
    ProducesJson := Operation.Produces.Contains(MimeTypeJson);
    if not ProducesJson and (Operation.Produces.Count = 0) then
      ProducesJson := Document.Produces.Contains(MimeTypeJson);

    Method.HttpMethod := HttpMethod;
    Method.UrlPath := Path;
    Method.Summary := Operation.Summary;
    Method.Remarks := Operation.Description;

    for Param in Operation.Parameters do
    begin
      if Param.InBody then
        if ConsumesJson then
          Method.Consumes := MimeTypeJson
        else
          raise EOpenApiAnalyzerException.CreateFmt('Body parameter %s is present but method does not consume JSON', [Param.Name]);

      MetaParam := TMetaParam.Create;
      Method.Params.Add(MetaParam);
      MetaParam.Description := Param.Description;
      BuildMetaParam(MetaParam, Param, Method.CodeName);
    end;

    ResponseType := nil;
    for ResponseItem in Operation.Responses do
      if ((ResponseItem.Key = 'default') or (StrToInt(ResponseItem.Key) < 300)) and Assigned(ResponseItem.Value.Schema) then
      begin
        if Options.XDataService then
          ListType := TListType.ltArray
        else
          ListType := TListType.ltAuto;
        TargetResponseType := MetaTypeFromSchema(ResponseItem.Value.Schema, Method.CodeName + 'Output', ListType);
        if ResponseType = nil then
          ResponseType := TargetResponseType
        else
        if ResponseType.TypeName <> TargetResponseType.TypeName then
          raise EOpenApiAnalyzerException.CreateFmt('Ambiguous response types: %s and %s', [ResponseType.TypeName, TargetResponseType.TypeName]);
      end;
    Method.ReturnType := ResponseType;
    if (ResponseType <> nil) and not ResponseType.IsBinary then
      if ProducesJson then
        Method.Produces := MimeTypeJson
      else
        raise EOpenApiAnalyzerException.Create('Method returns data be method does not produce JSON');
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
begin
  MetaParam.RestName := Param.Name;
  MetaParam.CodeName := ProcessNaming(Param.Name, Options.ServiceOptions.ParamNaming);
  case Param.&In of
    Body:
      begin
        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + 'Input', TListType.ltAuto);
        MetaParam.Location := TParamLocation.plBody;
      end;
    Query:
      begin
        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plQuery;
      end;
    Path:
      begin
        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plUrl;
      end;
    FormData:
      begin
        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plForm;
      end;
    Header:
      begin
        MetaParam.ParamType := MetaTypeFromSchema(Param.Schema, MethodName + Param.Name, TListType.ltAuto);
        MetaParam.Location := TParamLocation.plHeader;
      end;
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
          Tag := FDocument.Tags.Find(ServiceName);
          if Tag <> nil then
            ServiceDescription := Tag.Description;
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
    ServiceName := Options.ClientName;
    OperationName := Operation.OperationId;
  end;
end;

function TOpenApiAnalyzer.GetBaseUrl: string;
begin
  Result := Document.Host;
  if Result = '' then
    Result := Options.DocumentUrl;
  if EndsStr('/', Result) then
    Result := Copy(Result, 1, Length(Result) - 1);
  if not StartsStr('/', Document.BasePath) then
    Result := Result + '/';
  Result := Result + Document.BasePath;

  if Pos('://', Result) = 0 then
  begin
    if TProtocol.Https in Document.Schemes then
      Result := 'https://' + Result
    else
    if TProtocol.Http in Document.Schemes then
      Result := 'http://' + Result
    else
      // hard code this, but it should use same scheme as the original
      // OpenAPI document
      Result := 'https://' + Result;
  end;
end;

function TOpenApiAnalyzer.MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string;
  ListType: TListType): IMetaType;
var
  ReferencedSchema: TJsonSchema;
begin
  if not Document.Definitions.TryGetValue(RefSchema.DefinitionName, ReferencedSchema) then
    raise EOpenApiAnalyzerException.CreateFmt('Reference not in definition "%s"', [RefSchema.Ref]);

  // if it's object, then just reference the type. Otherwise, use the referenced type inline
  if ReferencedSchema is TObjectSchema then
    Result := MetaTypeFromObject(RefSchema.DefinitionName, TObjectSchema(ReferencedSchema))
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
end;


procedure TOpenApiAnalyzer.ProcessPathItem(const Path: string; PathItem: TPathItem);
begin
  ProcessOperation(Path, PathItem, PathItem.Get, 'GET');
  ProcessOperation(Path, PathItem, PathItem.Put, 'PUT');
  ProcessOperation(Path, PathItem, PathItem.Post, 'POST');
  ProcessOperation(Path, PathItem, PathItem.Delete, 'DELETE');
  ProcessOperation(Path, PathItem, PathItem.Patch, 'PATCH');
  ProcessOperation(Path, PathItem, PathItem.Options, 'OPTIONS');
  ProcessOperation(Path, PathItem, PathItem.Head, 'HEAD');
end;

end.
