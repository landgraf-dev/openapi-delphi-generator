unit OpenApiGen.Builder;

{$I XData.inc}

interface

uses
  Generics.Collections, SysUtils, Classes, Character, TypInfo, StrUtils,
  Bcl.Logging,
  Bcl.Code.MetaClasses,
  Bcl.Code.DelphiGenerator,
  OpenAPI.Classes,
  OpenAPI.Classes.Path,
  OpenAPI.Classes.Operation,
  OpenAPI.Classes.Parameter,
  OpenAPI.Document,
  OpenAPI.Types,
  XData.JSchema.Classes,
  OpenApiGen.Options,
  OpenApiGen.Metadata;

type
  EOpenApiImportException = class(Exception)
  end;

  TListType = (ltAuto, ltArray, ltList);

  TGetIdentifierProc = reference to procedure(var Name: string; const Original: string);
  TMethodCreatedProc = reference to procedure(Method: TCodeMemberMethod; Parent: TCodeTypeDeclaration);
  TTypeCreatedProc = reference to procedure(CodeType: TCodeTypeDeclaration);
  TPropCreatedProc = reference to procedure(Prop: TCodeMemberProperty; Field: TCodeMemberField; Parent: TCodeTypeDeclaration);

  TOpenApiImporter = class
  private
    FDocument: TOpenApiDocument;
    FClientUnit: TCodeUnit;
    FDtoUnit: TCodeUnit;
    FJsonUnit: TCodeUnit;
    FLogger: ILogger;
    FOnGetMethodName: TGetIdentifierProc;
    FOnGetTypeName: TGetIdentifierProc;
    FOnGetPropName: TGetIdentifierProc;
    FOnGetFieldName: TGetIdentifierProc;
    FOnGetInterfaceName: TGetIdentifierProc;
    FOnGetServiceClassName: TGetIdentifierProc;

    FOnMethodCreated: TMethodCreatedProc;
    FOnPropCreated: TPropCreatedProc;
    FOnTypeCreated: TTypeCreatedProc;
    FOnServiceInterfaceCreated: TTypeCreatedProc;
    FOnServiceClassCreated: TTypeCreatedProc;
    FMetaTypes: TList<IMetaType>;
    FServices: TList<TMetaService>;
    FOptions: TBuilderOptions;
    function FindService(const Name: string): TMetaService;
    function FindMetaType(const Name: string): IMetaType;

    procedure GenerateRestService;
    procedure GenerateServiceInterfaceMethod(CodeMethod: TCodeMemberMethod; MetaMethod: TMetaMethod);
    procedure GenerateServiceClassMethod(CodeMethod: TCodeMemberMethod; MetaMethod: TMetaMethod);
    function GenerateMethodParam(CodeMethod: TCodeMemberMethod; MetaParam: TMetaParam): TCodeParameterDeclaration;
    function GenerateDTOClass(ObjType: TObjectMetaType): TCodeTypeDeclaration;
    procedure GenerateDTOProperty(CodeType: TCodeTypeDeclaration; Prop: TMetaProperty);
    procedure GenerateDTOSerialization(ObjType: TObjectMetaType);
    procedure GenerateDTODeserialization(ObjType: TObjectMetaType);
    function GenerateArrayType(ArrType: TArrayMetaType): TCodeTypeAliasDeclaration;
    procedure GenerateArraySerialization(ArrType: TArrayMetaType);
    procedure GenerateArrayDeserialization(ArrType: TArrayMetaType);
    function GenerateListType(ListType: TListMetaType): TCodeTypeDeclaration;
    procedure GenerateListSerialization(ListType: TListMetaType);
    procedure GenerateListDeserialization(ListType: TListMetaType);
    procedure GenerateService(Service: TMetaService);
    function GenerateServiceInterface(const InterfaceName: string): TCodeTypeDeclaration;
    function GenerateServiceClass(const TypeName, InterfaceName: string): TCodeTypeDeclaration;
    function GenerateJsonConverter: TCodeTypeDeclaration;

    procedure ProcessPathItem(const Path: string; PathItem: TPathItem);
    procedure ProcessOperation(const Path: string; PathItem: TPathItem;
      Operation: TOperation; const HttpMethod: string);
    function ProcessNaming(const S: string; Options: TNamingOptions): string;
    function BuildMetaMethod(Method: TMetaMethod; const Path: string; Operation: TOperation; const HttpMethod: string): Boolean;
    procedure BuildMetaParam(MetaParam: TMetaParam; Param: TParameter; const MethodName: string);
    function MetaTypeFromSchema(Schema: TJsonSchema; const DefaultTypeName: string; ListType: TListType): IMetaType;
    function MetaTypeFromString(const Format: string): IMetaType;
    function MetaTypeFromInteger(const Format: string): IMetaType;
    function MetaTypeFromArray(Schema: TArraySchema; const DefaultItemTypeName: string; ListType: TListType): IMetaType;
    function MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string; ListType: TListType): IMetaType;
    function MetaTypeFromObject(const Name: string; Schema: TObjectSchema): IMetaType;

    procedure RecreateCodeUnits;
    procedure DestroyCodeUnits;
    function HttpMethodToAttribute(const Method: string): string;
  strict protected
    function ToId(const S: string): string; virtual;
    function CleanId(const S: string): string; virtual;
    procedure DoGetPropName(var PropName: string; const Original: string);
    procedure DoGetFieldName(var FieldName: string; const Original: string);
    procedure DoGetMethodName(var MethodName: string; const Original: string);
    procedure DoGetTypeName(var TypeName: string; const Original: string);
    procedure DoGetInterfaceName(var InterfaceName: string; const Original: string);
    procedure DoGetServiceClassName(var ServiceClassName: string; const Original: string);
    procedure DoMethodCreated(Method: TCodeMemberMethod; Parent: TCodeTypeDeclaration);
    procedure DoTypeCreated(CodeType: TCodeTypeDeclaration);
    procedure DoServiceInterfaceCreated(CodeType: TCodeTypeDeclaration);
    procedure DoServiceClassCreated(CodeType: TCodeTypeDeclaration);
    procedure DoPropCreated(Prop: TCodeMemberProperty; Field: TCodeMemberField; Parent: TCodeTypeDeclaration);
    procedure DoSolveServiceOperation(var ServiceName, OperationName: string;
      const Path: string; PathItem: TPathItem; Operation: TOperation);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Build(ADocument: TOpenApiDocument);
    function CodeUnits: TArray<TCodeUnit>;
    property Options: TBuilderOptions read FOptions;
    property Document: TOpenApiDocument read FDocument;
    property OnGetMethodName: TGetIdentifierProc read FOnGetMethodName write FOnGetMethodName;
    property OnGetTypeName: TGetIdentifierProc read FOnGetTypeName write FOnGetTypeName;
    property OnGetPropName: TGetIdentifierProc read FOnGetPropName write FOnGetPropName;
    property OnGetFieldName: TGetIdentifierProc read FOnGetFieldName write FOnGetFieldName;
    property OnGetInterfaceName: TGetIdentifierProc read FOnGetInterfaceName write FOnGetInterfaceName;
    property OnGetServiceClassName: TGetIdentifierProc read FOnGetServiceClassName write FOnGetServiceClassName;
    property OnMethodCreated: TMethodCreatedProc read FOnMethodCreated write FOnMethodCreated;
    property OnPropCreated: TPropCreatedProc read FOnPropCreated write FOnPropCreated;
    property OnTypeCreated: TTypeCreatedProc read FOnTypeCreated write FOnTypeCreated;
    property OnServiceInterfaceCreated: TTypeCreatedProc read FOnServiceInterfaceCreated write FOnServiceInterfaceCreated;
    property OnServiceClassCreated: TTypeCreatedProc read FOnServiceClassCreated write FOnServiceClassCreated;
  end;

function ToPascalCase(const S: string): string;

implementation

uses
  Bcl.Utils;

const
  cFromJsonValue = 'FromJsonValue';
  cJsonValue = 'TJSONValue';

function ToPascalCase(const S: string): string;
var
  I: Integer;
  Convert: Boolean;
 begin
  I := 1;
  Result := '';
  Convert := True;
  while I <= Length(S) do
  begin
    if TBclUtils.IsLetter(S[I]) then
    begin
      if Convert then
      begin
        Result := Result + UpCase(S[I]);
        Convert := False;
      end
      else
        Result := Result + S[I];
    end
    else
    if S[I] = '_' then
      Convert := True
    else
      Result := Result + S[I];
    Inc(I);
  end;
end;

{ TOpenApiImporter }

procedure TOpenApiImporter.Build(ADocument: TOpenApiDocument);
var
  Path: TPair<string, TPathItem>;
  Definition: TPair<string, TJsonSchema>;
  MetaType: IMetaType;
  Service: TMetaService;
begin
  FDocument := ADocument;
  RecreateCodeUnits;

  if Options.XDataService then
  begin
    FClientUnit.UseUnit('System.Generics.Collections');
    FClientUnit.UseUnit('System.SysUtils');
    FClientUnit.UseUnit('System.Classes');
    FClientUnit.UseUnit('Bcl.Json.Attributes');
    FClientUnit.UseUnit('Bcl.Types.Nullable');
    FClientUnit.UseUnit('XData.Service.Common');
  end
  else
  begin
    FDtoUnit.UseUnit('System.Generics.Collections');
    FDtoUnit.UseUnit('System.SysUtils'); // Because of TBytes

    FJsonUnit.UseUnit('OpenApiJson');
    FJsonUnit.UseUnit(FDtoUnit.Name);

    FClientUnit.UseUnit('System.SysUtils');
    FClientUnit.UseUnit('OpenApiRest');
    FClientUnit.UseUnit(FJsonUnit.Name);
    FClientUnit.UseUnit(FDtoUnit.Name);
  end;

  FMetaTypes.Clear;

  // Build meta information
  for Definition in Document.Definitions do
    MetaTypeFromSchema(Definition.Value, Definition.Key, TListType.ltAuto);

  for Path in Document.Paths do
    ProcessPathItem(Path.Key, Path.Value);

  // Generate code from meta information
  for MetaType in FMetaTypes do
  begin
    // Create specific types. Maybe move such code to the meta type itself.
    if MetaType is TObjectMetaType then
      GenerateDTOClass(MetaType as TObjectMetaType)
    else
    if MetaType is TArrayMetaType then
      GenerateArrayType(MetaType as TArrayMetaType)
    else
    if MetaType is TListMetaType then
      GenerateListType(MetaType as TListMetaType);
  end;

  // Generate the base class for services
  GenerateRestService;

  // Generate services
  for Service in FServices do
    GenerateService(Service);
end;

function TOpenApiImporter.BuildMetaMethod(Method: TMetaMethod; const Path: string; Operation: TOperation;
  const HttpMethod: string): Boolean;
var
  Param: TParameter;
  ResponseType: IMetaType;
  ResponseItem: TPair<string, TResponse>;
  TargetResponseType: IMetaType;
  MetaParam: TMetaParam;
  ErrorMsg: string;
  ListType: TListType;
begin
  Result := False;
  try
    Method.HttpMethod := HttpMethod;
    Method.UrlPath := Path;
    for Param in Operation.Parameters do
    begin
      MetaParam := TMetaParam.Create;
      Method.Params.Add(MetaParam);
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
          raise EOpenApiImportException.CreateFmt('Ambiguous response types: %s and %s', [ResponseType.TypeName, TargetResponseType.TypeName]);
      end;
    Method.ReturnType := ResponseType;
    Result := True;
  except
    on E: EOpenApiImportException do
    begin
      Method.Ignore := True;
      ErrorMsg := Format('Import of %s %s failed: %s', [HttpMethod, Path, E.Message]);
      FLogger.Warning(ErrorMsg);
    end
    else
      raise;
  end;
end;

procedure TOpenApiImporter.BuildMetaParam(MetaParam: TMetaParam; Param: TParameter; const MethodName: string);
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
//    Header: ;
  else
    raise EOpenApiImportException.CreateFmt('Unsupported parameter type: %s', [GetEnumName(TypeInfo(TLocation), Ord(Param.&In))]);
  end;
end;

procedure TOpenApiImporter.GenerateService(Service: TMetaService);
var
  ParentIntf: TCodeTypeDeclaration;
  ParentClass: TCodeTypeDeclaration;
  MetaMethod: TMetaMethod;
  RttiMethod: TCodeMemberMethod;
begin
  if not Service.HasMethods then Exit;

  ParentIntf := GenerateServiceInterface(Service.InterfaceName);
  if not Options.XDataService then
    ParentClass := GenerateServiceClass(Service.ServiceClass, Service.InterfaceName)
  else
    ParentClass := nil;

  for MetaMethod in Service.Methods do
  begin
    if MetaMethod.Ignore then Continue;
    
    RttiMethod := ParentIntf.AddProcedure(MetaMethod.CodeName, mvPublic);
    GenerateServiceInterfaceMethod(RttiMethod, MetaMethod);
    DoMethodCreated(RttiMethod, ParentIntf);

    // Create method in implementation class
    if ParentClass <> nil then
    begin
      RttiMethod := ParentClass.AddProcedure(MetaMethod.CodeName, mvPublic);
      GenerateServiceClassMethod(RttiMethod, MetaMethod);
      DoMethodCreated(RttiMethod, ParentClass);
    end;
  end;
end;

procedure TOpenApiImporter.GenerateServiceClassMethod(CodeMethod: TCodeMemberMethod; MetaMethod: TMetaMethod);
const
  cIndex = 'I';
var
  Param: TMetaParam;
  Statements: TCodeStatements;
  Countable: ICountableMetaType;
  ForStatement: TCodeForStatement;
  ParamValue: string;
begin
  // Method declaration
  for Param in MetaMethod.Params do
    GenerateMethodParam(CodeMethod, Param);
  if MetaMethod.ReturnType <> nil then
    CodeMethod.ReturnType.BaseType := MetaMethod.ReturnType.TypeName;

  // Statement context
  Statements := CodeMethod.Statements;

  // Build request
  CodeMethod.DeclareVar('Request', 'IRestRequest');
  Statements.AddSnippetFmt('Request := CreateRequest(''%s'', ''%s'')', [MetaMethod.UrlPath, MetaMethod.HttpMethod]);

  // Add parameters to request
  for Param in MetaMethod.Params do
    case Param.Location of
      TParamLocation.plQuery:
        begin
          if Param.ParamType.QueryInterface(ICountableMetaType, Countable) = S_OK then
          begin
            if CodeMethod.IndexOfVar(cIndex) = -1 then
              CodeMethod.DeclareVar(cIndex, 'Integer');
            ForStatement := TCodeForStatement.Create;
            Statements.Add(ForStatement);
            ForStatement.VarName := cIndex;
            ForStatement.InitialExpression := TCodeSnippetExpression.Create('0');
            ForStatement.FinalExpression := TCodeSnippetExpression.Create(Format('Length(%s) - 1', [Param.CodeName]));
            ParamValue := Countable.GetItemType.CodeToParam(Format('%s[%s]', [Param.CodeName, cIndex]));
            ForStatement.Statements.AddSnippetFmt('Request.AddQueryParam(''%s'', %s)', [Param.RestName, ParamValue]);
          end
          else
          begin
            ParamValue := Param.ParamType.CodeToParam(Param.CodeName);
            Statements.AddSnippetFmt('Request.AddQueryParam(''%s'', %s)', [Param.RestName, ParamValue]);
          end;
        end;
      TParamLocation.plUrl:
        begin
          ParamValue := Param.ParamType.CodeToParam(Param.CodeName);
          Statements.AddSnippetFmt('Request.AddUrlParam(''%s'', %s)', [Param.RestName, ParamValue]);
        end;
      TParamLocation.plBody:
        begin
          Statements.AddSnippetFmt('Request.AddBody(Converter.%s(%s))', [Param.ParamType.ToJsonFunctionName, Param.CodeName]);
        end;
      TParamLocation.plForm:
        Statements.AddSnippetFmt('raise Exception.Create(''Form param ''''%s'''' not supported'')', [Param.CodeName]);
    end;

  // read response
  CodeMethod.DeclareVar('Response', 'IRestResponse');
  Statements.AddSnippet('Response := Request.Execute');
  Statements.AddSnippet('CheckError(Response)');
  if MetaMethod.ReturnType <> nil then
  begin
    if MetaMethod.ReturnType.IsBinary then
      Statements.AddSnippet('Result := Response.ContentAsBytes')
    else
      Statements.AddSnippetFmt('Result := Converter.%s(Response.ContentAsString)', [MetaMethod.ReturnType.FromJsonFunctionName]);
  end;
end;

procedure TOpenApiImporter.GenerateServiceInterfaceMethod(CodeMethod: TCodeMemberMethod; MetaMethod: TMetaMethod);
var
  RouteAttr: TCodeAttributeDeclaration;
  Param: TMetaParam;
  CodeParam: TCodeParameterDeclaration;
  Attr: string;
begin
  if Options.XDataService then
  begin
    // Add XData attributes
    CodeMethod.AddAttribute(HttpMethodToAttribute(MetaMethod.HttpMethod));
    RouteAttr := TCodeAttributeDeclaration.Create('Route');
    CodeMethod.CustomAttributes.Add(RouteAttr);
    RouteAttr.AddRawArgument(QuotedStr(MetaMethod.UrlPath));
  end;

  for Param in MetaMethod.Params do
  begin
    CodeParam := GenerateMethodParam(CodeMethod, Param);
    if Options.XDataService then
    begin
      case Param.Location of
        TParamLocation.plQuery:
          Attr := 'FromQuery';
        TParamLocation.plUrl:
          Attr := 'FromPath';
        TParamLocation.plBody:
          Attr := 'FromBody';
        TParamLocation.plForm:
          Attr := 'FromBody';
      end;
      CodeParam.AddAttribute(Attr);
    end;
  end;

  if MetaMethod.ReturnType <> nil then
    CodeMethod.ReturnType.BaseType := MetaMethod.ReturnType.TypeName;
end;

function TOpenApiImporter.CleanId(const S: string): string;
begin
  if StartsStr('&', S) then
    Result := Copy(S, 2)
  else
    Result := S;
end;

function TOpenApiImporter.CodeUnits: TArray<TCodeUnit>;
begin
  SetLength(Result, 3);
  Result[0] := FClientUnit;
  Result[1] := FJsonUnit;
  Result[2] := FDtoUnit;
end;

constructor TOpenApiImporter.Create;
begin
  inherited Create;
  FOptions := TBuilderOptions.Create;
  FLogger := TLogManager.Instance.GetLogger(Self);
  FMetaTypes := TList<IMetaType>.Create;
  FServices := TObjectList<TMetaService>.Create;
end;

procedure TOpenApiImporter.GenerateArrayDeserialization(ArrType: TArrayMetaType);
var
  Method: TCodeMemberMethod;
  ForStatement: TCodeForStatement;
  TypeCondition: TCodeConditionStatement;
  TryFinally: TCodeTryFinallyStatement;
begin
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ArrType.FromJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ArrType.TypeName);
  Method.AddParameter('Source', cJsonValue);

  // check for type
  TypeCondition := TCodeConditionStatement.Create;
  Method.Statements.Add(TypeCondition);
  TypeCondition.Condition := TCodeSnippetExpression.Create('not Json.IsArray(Source)');
  TypeCondition.TrueStatements.AddSnippet('SetLength(Result, 0)');
  TypeCondition.TrueStatements.AddSnippet('Exit');

  // Initiliaze the array and then loop to fill it
  Method.DeclareVar('Index', 'Integer');
  Method.AddSnippet('SetLength(Result, Json.ArrayLength(Source))');
  ForStatement := TCodeForStatement.Create;
  Method.Statements.Add(ForStatement);

  ForStatement.VarName := 'Index';
  ForStatement.InitialExpression := TCodeSnippetExpression.Create('0');
  ForStatement.FinalExpression := TCodeSnippetExpression.Create('Json.ArrayLength(Source) - 1');
  ForStatement.Statements.AddSnippetFmt('Result[Index] := Self.%s(Json.ArrayGet(Source, Index))',
    [ArrType.ItemType.FromJsonValueFunctionName]);

  // Create the method to convert the string to list
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ArrType.FromJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ArrType.TypeName);
  Method.AddParameter('Source', 'string');

  // create the instance, protected with try finally
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippet('JValue := JsonToJsonValue(Source)');
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);
  TryFinally.Statements.AddSnippetFmt('Result := %s(JValue)', [ArrType.FromJsonValueFunctionName]);
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

procedure TOpenApiImporter.GenerateArraySerialization(ArrType: TArrayMetaType);
var
  Method: TCodeMemberMethod;
  ForStatement: TCodeForStatement;
  TryExcept: TCodeTryExceptStatement;
  TryFinally: TCodeTryFinallyStatement;
begin
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ArrType.ToJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(cJsonValue);
  Method.AddParameter('Source', ArrType.TypeName);

  Method.DeclareVar('Index', 'Integer');
  Method.AddSnippet('Result := Json.CreateArray');

  TryExcept := TCodeTryExceptStatement.Create;
  Method.Statements.Add(TryExcept);
  TryExcept.ExceptStatements.AddSnippet('Result.Free');
  TryExcept.ExceptStatements.AddSnippet('raise');

  ForStatement := TCodeForStatement.Create;
  TryExcept.Statements.Add(ForStatement);

  ForStatement.VarName := 'Index';
  ForStatement.InitialExpression := TCodeSnippetExpression.Create('0');
  ForStatement.FinalExpression := TCodeSnippetExpression.Create('Length(Source) - 1');
  ForStatement.Statements.AddSnippetFmt('Json.ArrayAdd(Result, Self.%s(Source[Index]))', [ArrType.ItemType.ToJsonValueFunctionName]);

  // Create the method to convert the List to string
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ArrType.ToJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create('string');
  Method.AddParameter('Source', ArrType.TypeName);

  // create the instance, protected with try except
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippetFmt('JValue := %s(Source)', [ArrType.ToJsonValueFunctionName]);
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);

  TryFinally.Statements.AddSnippet('Result := JsonValueToJson(JValue)');
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

function TOpenApiImporter.GenerateArrayType(ArrType: TArrayMetaType): TCodeTypeAliasDeclaration;
var
  CodeType: TCodeTypeAliasDeclaration;
  ArrayType: string;
begin
  Result := FDtoUnit.FindAlias(ArrType.TypeName);
  if Result <> nil then Exit;

  if Options.XDataService then
    ArrayType := Format('TArray<%s>', [ArrType.ItemType.TypeName])
  else
    ArrayType := Format('array of %s', [ArrType.ItemType.TypeName]);
  CodeType := TCodeTypeAliasDeclaration.Create(ArrType.TypeName, TCodeTypeReference.Create(ArrayType));
  FDtoUnit.Aliases.Add(CodeType);
  Result := CodeType;

  // Implement JSON serialization
  if not Options.XDataService then
  begin
    GenerateArraySerialization(ArrType);
    GenerateArrayDeserialization(ArrType);
  end;

//  DoTypeCreated(CodeType);
end;

function TOpenApiImporter.GenerateDTOClass(ObjType: TObjectMetaType): TCodeTypeDeclaration;
var
  CodeType: TCodeTypeDeclaration;
  Prop: TMetaProperty;
begin
  Result := FDtoUnit.FindType(ObjType.TypeName);
  if Result <> nil then Exit;

  CodeType := TCodeTypeDeclaration.Create;
  FDtoUnit._Types.Add(CodeType);
  CodeType.Name := ObjType.TypeName;
  CodeType.IsClass := True;

  // Declare fields and properties
  for Prop in ObjType.Props do
    GenerateDTOProperty(CodeType, Prop);

  // Implement JSON serialization
  if not Options.XDataService then
  begin
    GenerateDTOSerialization(ObjType);
    GenerateDTODeserialization(ObjType);
  end;

  DoTypeCreated(CodeType);
  Result := CodeType;
end;

procedure TOpenApiImporter.GenerateDTODeserialization(ObjType: TObjectMetaType);
var
  Prop: TMetaProperty;
  Method: TCodeMemberMethod;
  TryExcept: TCodeTryExceptStatement;
  Condition: TCodeConditionStatement;
  Statements: TCodeStatements;
  TryFinally: TCodeTryFinallyStatement;
  TypeCondition: TCodeConditionStatement;
begin
  // Declare method to convert the TJSONValue to DTO
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ObjType.FromJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ObjType.TypeName);
  Method.AddParameter('Source', cJsonValue);

  // check for type
  TypeCondition := TCodeConditionStatement.Create;
  Method.Statements.Add(TypeCondition);
  TypeCondition.Condition := TCodeSnippetExpression.Create('not Json.IsObject(Source)');
  TypeCondition.TrueStatements.AddSnippet('Result := nil');
  TypeCondition.TrueStatements.AddSnippet('Exit');

  // create the instance, protected with try except
  Method.AddSnippetFmt('Result := %s.Create', [ObjType.TypeName]);
  TryExcept := TCodeTryExceptStatement.Create;
  Method.Statements.Add(TryExcept);
  TryExcept.ExceptStatements.AddSnippet('Result.Free');
  TryExcept.ExceptStatements.AddSnippet('raise');

  // Add code to load each property
  if ObjType.Props.Count > 0 then
    Method.DeclareVar('JValue', cJsonValue);
  for Prop in ObjType.Props do
  begin
    Statements := TryExcept.Statements;

    Condition := TCodeConditionStatement.Create;
    Statements.Add(Condition);
    Condition.Condition := TCodeSnippetExpression.Create(
      Format('Json.ObjContains(Source, ''%s'', JValue)', [Prop.RestName]));
    Statements := Condition.TrueStatements;
    Statements.AddSnippetFmt('Result.%s := Self.%s(JValue)',
      [Prop.PropName, Prop.PropType.FromJsonValueFunctionName]);
  end;

  // Create the method to convert the string to DTO
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ObjType.FromJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ObjType.TypeName);
  Method.AddParameter('Source', 'string');

  // create the instance, protected with try finally
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippet('JValue := JsonToJsonValue(Source)');
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);
  TryFinally.Statements.AddSnippetFmt('Result := %s(JValue)', [ObjType.FromJsonValueFunctionName]);
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

procedure TOpenApiImporter.GenerateListDeserialization(ListType: TListMetaType);
var
  Method: TCodeMemberMethod;
  ForStatement: TCodeForStatement;
  TryExcept: TCodeTryExceptStatement;
  TypeCondition: TCodeConditionStatement;
  TryFinally: TCodeTryFinallyStatement;
begin
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ListType.FromJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ListType.TypeName);
  Method.AddParameter('Source', cJsonValue);

  // check for type
  TypeCondition := TCodeConditionStatement.Create;
  Method.Statements.Add(TypeCondition);
  TypeCondition.Condition := TCodeSnippetExpression.Create('not Json.IsArray(Source)');
  TypeCondition.TrueStatements.AddSnippet('Result := nil');
  TypeCondition.TrueStatements.AddSnippet('Exit');

  // create the instance, protected with try except
  Method.DeclareVar('Index', 'Integer');
  Method.AddSnippetFmt('Result := %s.Create', [ListType.TypeName]);
  TryExcept := TCodeTryExceptStatement.Create;
  Method.Statements.Add(TryExcept);
  TryExcept.ExceptStatements.AddSnippet('Result.Free');
  TryExcept.ExceptStatements.AddSnippet('raise');

  ForStatement := TCodeForStatement.Create;
  TryExcept.Statements.Add(ForStatement);

  ForStatement.VarName := 'Index';
  ForStatement.InitialExpression := TCodeSnippetExpression.Create('0');
  ForStatement.FinalExpression := TCodeSnippetExpression.Create('Json.ArrayLength(Source) - 1');
  ForStatement.Statements.AddSnippetFmt('Result.Add(Self.%s(Json.ArrayGet(Source, Index)))',
    [ListType.ItemType.FromJsonValueFunctionName]);

  // Create the method to convert the string to list
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ListType.FromJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(ListType.TypeName);
  Method.AddParameter('Source', 'string');

  // create the instance, protected with try finally
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippet('JValue := JsonToJsonValue(Source)');
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);
  TryFinally.Statements.AddSnippetFmt('Result := %s(JValue)', [ListType.FromJsonValueFunctionName]);
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

procedure TOpenApiImporter.GenerateListSerialization(ListType: TListMetaType);
var
  Method: TCodeMemberMethod;
  ForStatement: TCodeForStatement;
  TryExcept: TCodeTryExceptStatement;
  NullCondition: TCodeConditionStatement;
  TryFinally: TCodeTryFinallyStatement;
begin
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ListType.ToJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(cJsonValue);
  Method.AddParameter('Source', ListType.TypeName);

  // check for nil
  NullCondition := TCodeConditionStatement.Create;
  Method.Statements.Add(NullCondition);
  NullCondition.Condition := TCodeSnippetExpression.Create('not Assigned(Source)');
  NullCondition.TrueStatements.AddSnippet('Result := Json.CreateNull');
  NullCondition.TrueStatements.AddSnippet('Exit');

  // create the instance, protected with try except
  Method.DeclareVar('Index', 'Integer');
  Method.AddSnippet('Result := Json.CreateArray');
  TryExcept := TCodeTryExceptStatement.Create;
  Method.Statements.Add(TryExcept);
  TryExcept.ExceptStatements.AddSnippet('Result.Free');
  TryExcept.ExceptStatements.AddSnippet('raise');

  ForStatement := TCodeForStatement.Create;
  TryExcept.Statements.Add(ForStatement);

  ForStatement.VarName := 'Index';
  ForStatement.InitialExpression := TCodeSnippetExpression.Create('0');
  ForStatement.FinalExpression := TCodeSnippetExpression.Create('Source.Count - 1');
  ForStatement.Statements.AddSnippetFmt('Json.ArrayAdd(Result, Self.%s(Source[Index]))', [ListType.ItemType.ToJsonValueFunctionName]);

  // Create the method to convert the List to string
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ListType.ToJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create('string');
  Method.AddParameter('Source', ListType.TypeName);

  // create the instance, protected with try except
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippetFmt('JValue := %s(Source)', [ListType.ToJsonValueFunctionName]);
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);

  TryFinally.Statements.AddSnippet('Result := JsonValueToJson(JValue)');
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

function TOpenApiImporter.GenerateListType(ListType: TListMetaType): TCodeTypeDeclaration;
var
  CodeType: TCodeTypeDeclaration;
  BaseType: string;
begin
  Result := FDtoUnit.FindType(ListType.TypeName);
  if Result <> nil then Exit;

//  if XDataService then
  if True then
  begin
    if ListType is TObjectListMetaType then
      BaseType := Format('TObjectList<%s>', [ListType.ItemType.TypeName])
    else
      BaseType := Format('TList<%s>', [ListType.ItemType.TypeName]);
  end
  else
    if ListType is TObjectListMetaType then
      BaseType := 'TObjectList'
    else
      BaseType := 'TList';

  CodeType := TCodeTypeDeclaration.Create;
  FDtoUnit._Types.Add(CodeType);
  CodeType.Name := ListType.TypeName;
  CodeType.BaseType := TCodeTypeReference.Create(BaseType);
  CodeType.IsClass := True;

  // Implement JSON serialization
  if not Options.XDataService then
  begin
    GenerateListSerialization(ListType);
    GenerateListDeserialization(ListType);
  end;

  DoTypeCreated(CodeType);

  Result := CodeType;
end;

procedure TOpenApiImporter.GenerateDTOProperty(CodeType: TCodeTypeDeclaration; Prop: TMetaProperty);
const
  cBoolean = 'Boolean';
var
  CodeProp: TCodeMemberProperty;
  CodeField: TCodeMemberField;
  GetterName, SetterName: string;
  SetterProc: TCodeMemberMethod;
  CodeCondition: TCodeConditionStatement;
begin
  GetterName := Prop.FieldName;
  SetterName := Prop.FieldName;

  // Define property setters and helper functions
  if Prop.PropType.IsManaged then
  begin
    // Add code related to memory management and object creation
    if Prop.Required then
      CodeType.DefaultCreate.Statements.AddSnippetFmt('%s := %s.Create', [Prop.FieldName, Prop.PropType.TypeName]);
    CodeType.DefaultDestroy.Statements.Insert(0, TCodeSnippetStatement.Create(Format('%s.Free', [Prop.FieldName])));

    SetterName := 'Set' + CleanId(Prop.PropName);
    SetterProc := CodeType.AddProcedure(SetterName, mvPrivate);
    SetterProc.AddParameter('Value', Prop.PropType.TypeName).Modifier := pmConst;

    CodeCondition := TCodeConditionStatement.Create;
    SetterProc.Statements.Add(CodeCondition);
    CodeCondition.Condition := TCodeSnippetExpression.Create(Format('Value <> %s', [Prop.FieldName]));
    CodeCondition.TrueStatements.AddSnippetFmt('%s.Free', [Prop.FieldName]);
    CodeCondition.TrueStatements.AddSnippetFmt('%s := Value', [Prop.FieldName]);
  end
  else
  if not Prop.Required and not Options.XDataService then
  begin
    SetterName := 'Set' + CleanId(Prop.PropName);
    SetterProc := CodeType.AddProcedure(SetterName, mvPrivate);
    SetterProc.AddParameter('Value', Prop.PropType.TypeName).Modifier := pmConst;

    SetterProc.Statements.AddSnippetFmt('%s := Value', [Prop.FieldName]);
    SetterProc.Statements.AddSnippetFmt('%s := True', [Prop.HasValueFieldName]);
  end;

  // Create property and field
  CodeField := CodeType.AddField(Prop.FieldName, Prop.PropType.TypeName, mvPrivate);
  CodeProp := CodeType.AddProperty(Prop.PropName, Prop.PropType.TypeName, GetterName, SetterName, mvPublic);
  if Prop.IsNullable and not Options.XDataService then
  begin
    // Create IsNull field/prop
    CodeType.AddField(Prop.HasValueFieldName, cBoolean, mvPrivate);
    CodeType.AddProperty(Prop.HasValuePropName, cBoolean, Prop.HasValueFieldName, Prop.HasValueFieldName, mvPublic);
  end;

  // Add XData attributes
  if Options.XDataService then
  begin
    if Prop.PropType.IsManaged then
      CodeField.AddAttribute('JsonManaged');
    CodeField.AddAttribute('JsonProperty').AddRawArgument(QuotedStr(Prop.RestName));
  end;

  DoPropCreated(CodeProp, CodeField, CodeType);
end;

procedure TOpenApiImporter.GenerateDTOSerialization(ObjType: TObjectMetaType);
var
  Prop: TMetaProperty;
  Method: TCodeMemberMethod;
  TryExcept: TCodeTryExceptStatement;
  Condition: TCodeConditionStatement;
  Statements: TCodeStatements;
  TryFinally: TCodeTryFinallyStatement;
  NullCondition: TCodeConditionStatement;
begin
  // Declare method to convert the DTO to TJSONValue
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ObjType.ToJsonValueFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create(cJsonValue);
  Method.AddParameter('Source', ObjType.TypeName);

  // check for nil
  NullCondition := TCodeConditionStatement.Create;
  Method.Statements.Add(NullCondition);
  NullCondition.Condition := TCodeSnippetExpression.Create('not Assigned(Source)');
  NullCondition.TrueStatements.AddSnippet('Result := Json.CreateNull');
  NullCondition.TrueStatements.AddSnippet('Exit');

  // create the instance, protected with try except
  Method.AddSnippet('Result := Json.CreateObject');
  TryExcept := TCodeTryExceptStatement.Create;
  Method.Statements.Add(TryExcept);
  TryExcept.ExceptStatements.AddSnippet('Result.Free');
  TryExcept.ExceptStatements.AddSnippet('raise');

  // Add code to load each property
  for Prop in ObjType.Props do
  begin
    Statements := TryExcept.Statements;
    if Prop.IsNullable then
    begin
      Condition := TCodeConditionStatement.Create;
      Statements.Add(Condition);
      Condition.Condition := TCodeSnippetExpression.Create(Format('Source.%s', [Prop.HasValuePropName]));
      Statements := Condition.TrueStatements;
    end
    else
    if not Prop.Required and Prop.PropType.IsManaged then
    begin
      Condition := TCodeConditionStatement.Create;
      Statements.Add(Condition);
      Condition.Condition := TCodeSnippetExpression.Create(Format('Assigned(Source.%s)', [Prop.PropName]));
      Statements := Condition.TrueStatements;
    end;
    Statements.AddSnippetFmt('Json.ObjAddProp(Result, ''%s'', Self.%s(Source.%s))',
      [Prop.RestName, Prop.PropType.ToJsonValueFunctionName, Prop.PropName]);
  end;

  // Create the method to convert the DTO to string
  Method := TCodeMemberMethod.Create;
  GenerateJsonConverter.Members.Add(Method);
  Method.Name := ObjType.ToJsonFunctionName;
  Method.Visibility := mvPublic;
  Method.ReturnType := TCodeTypeReference.Create('string');
  Method.AddParameter('Source', ObjType.TypeName);

  // create the instance, protected with try except
  Method.DeclareVar('JValue', cJsonValue);
  Method.AddSnippetFmt('JValue := %s(Source)', [ObjType.ToJsonValueFunctionName]);
  TryFinally := TCodeTryFinallyStatement.Create;
  Method.Statements.Add(TryFinally);

  TryFinally.Statements.AddSnippet('Result := JsonValueToJson(JValue)');
  TryFinally.FinallyStatements.AddSnippet('JValue.Free');
end;

function TOpenApiImporter.GenerateJsonConverter: TCodeTypeDeclaration;
var
  Converter: TCodeTypeDeclaration;
begin
  Converter := FJsonUnit.FindType('TJsonConverter');
  if Converter <> nil then Exit(Converter);

  Converter := TCodeTypeDeclaration.Create;
  FJsonUnit._Types.Add(Converter);
  Converter.IsClass := True;
  Converter.BaseType := TCodeTypeReference.Create('TCustomJsonConverter');
  Converter.Name := 'TJsonConverter';

  Result := Converter;
end;

function TOpenApiImporter.MetaTypeFromArray(Schema: TArraySchema; const DefaultItemTypeName: string;
  ListType: TListType): IMetaType;
var
  ItemType: IMetaType;
begin
  if Schema.ValidateItemByPosition then
    raise EOpenApiImportException.CreateFmt('Array schema validated by position not supported (%s)', [DefaultItemTypeName]);
  if Schema.ItemSchemas.Count <> 1 then
    raise EOpenApiImportException.CreateFmt('Expecting only one item schema in array (%s)', [DefaultItemTypeName]);

  ItemType := MetaTypeFromSchema(Schema.ItemSchemas[0], DefaultItemTypeName, ListType);
  if ListType = TListType.ltAuto then
  begin
    if ItemType.IsManaged then
      ListType := TListType.ltList
    else
      ListType := TListType.ltArray;
  end;

  if ListType = TListType.ltArray then
    Result := TArrayMetaType.Create(ItemType)
  else
  if ItemType.IsManaged then
    Result := TObjectListMetaType.Create(ItemType)
  else
    Result := TListMetaType.Create(ItemType);
end;

function TOpenApiImporter.MetaTypeFromInteger(const Format: string): IMetaType;
begin
  if Format = 'int64' then
    Result := TInt64MetaType.Create
  else
    Result := TIntegerMetaType.Create
end;

function TOpenApiImporter.MetaTypeFromObject(const Name: string; Schema: TObjectSchema): IMetaType;
var
  TypeName: string;
  SchemaProp: TPair<string, TJsonSchema>;
  PropName: string;
  FieldName: string;
  ObjType: TObjectMetaType;
  MetaProp: TMetaProperty;
begin
  DoGetTypeName(TypeName, Name);
  ObjType := TObjectMetaType.Create(TypeName);
  Result := ObjType;
  for SchemaProp in Schema.Properties do
  begin
    MetaProp := TMetaProperty.Create;
    ObjType.Props.Add(MetaProp);

    DoGetPropName(PropName, SchemaProp.Key);
    DoGetFieldName(FieldName, SchemaProp.Key);

    MetaProp.RestName := SchemaProp.Key;
    MetaProp.PropName := PropName;
    MetaProp.FieldName := FieldName;
    MetaProp.Required := Schema.Required.IndexOf(SchemaProp.Key) >= 0;
    MetaProp.PropType := MetaTypeFromSchema(SchemaProp.Value, Name + PropName, TListType.ltList);
    if Options.XDataService and not MetaProp.Required and not MetaProp.PropType.IsManaged then
      MetaProp.PropType := TNullableMetaType.Create(MetaProp.PropType);
  end;
end;

function TOpenApiImporter.MetaTypeFromReference(RefSchema: TReferenceSchema;
  const DefaultTypeName: string; ListType: TListType): IMetaType;
var
  ReferencedSchema: TJsonSchema;
begin
  if not Document.Definitions.TryGetValue(RefSchema.DefinitionName, ReferencedSchema) then
    raise EOpenApiImportException.CreateFmt('Reference not in definition "%s"', [RefSchema.Ref]);

  // if it's object, then just reference the type. Otherwise, use the referenced type inline
  if ReferencedSchema is TObjectSchema then
    Result := MetaTypeFromObject(RefSchema.DefinitionName, TObjectSchema(ReferencedSchema))
  else
    Result := MetaTypeFromSchema(ReferencedSchema, DefaultTypeName, ListType);
end;

function TOpenApiImporter.MetaTypeFromSchema(Schema: TJsonSchema; const DefaultTypeName: string; ListType: TListType): IMetaType;
begin
  if Schema = nil then
    raise EOpenApiImportException.Create('Schema not defined');

  if Schema is TStringSchema then
    Result := MetaTypeFromString(Schema.Format)
  else
  if Schema is TNumberSchema then
    Result := TDoubleMetaType.Create
  else
  if Schema is TIntegerSchema then
    Result := MetaTypeFromInteger(Schema.Format)
  else
  if Schema is TBooleanSchema then
    Result := TBooleanMetaType.Create
  else
  if Schema is TFileSchema then
    Result := TBinaryMetaType.Create
  else
  if Schema is TReferenceSchema then
    Result := MetaTypeFromReference(TReferenceSchema(Schema), DefaultTypeName, ListType)
  else
  if Schema is TObjectSchema then
    Result := MetaTypeFromObject(DefaultTypeName, TObjectSchema(Schema))
  else
  if Schema is TArraySchema then
    Result := MetaTypeFromArray(TArraySchema(Schema), DefaultTypeName + 'Item', ListType)
  else
    raise EOpenApiImportException.CreateFmt('Unsupported schema type: %s', [Schema.ClassName]);

  if Result is TObjectMetaType and (FindMetaType(Result.TypeName) = nil) then
    FMetaTypes.Add(Result);
  if Result is TArrayMetaType and (FindMetaType(Result.TypeName) = nil) then
    FMetaTypes.Add(Result);
  if Result is TListMetaType and (FindMetaType(Result.TypeName) = nil) then
    FMetaTypes.Add(Result);
end;

function TOpenApiImporter.MetaTypeFromString(const Format: string): IMetaType;
begin
  if Format = 'date' then
    Result := TDateMetaType.Create
  else
  if Format = 'date-time' then
    Result := TDateTimeMetaType.Create
  else
  if Format = 'byte' then
    Result := TBytesMetaType.Create
  else
    Result := TStringMetaType.Create;
end;

destructor TOpenApiImporter.Destroy;
begin
  Options.Free;
  FServices.Free;
  FMetaTypes.Free;
  DestroyCodeUnits;
  inherited;
end;

procedure TOpenApiImporter.DestroyCodeUnits;
begin
  FreeAndNil(FClientUnit);
  FreeAndNil(FDtoUnit);
  FreeAndNil(FJsonUnit);
end;

procedure TOpenApiImporter.DoGetFieldName(var FieldName: string; const Original: string);
begin
  FieldName := ProcessNaming(Original, Options.DTOOptions.FieldNaming);
  if Assigned(FOnGetFieldName) then
    FOnGetPropName(FieldName, Original);
end;

procedure TOpenApiImporter.DoGetInterfaceName(var InterfaceName: string; const Original: string);
begin
  InterfaceName := ProcessNaming(Original, Options.ServiceOptions.InterfaceNaming);
  if Assigned(FOnGetInterfaceName) then
    FOnGetInterfaceName(InterfaceName, Original);
end;

procedure TOpenApiImporter.DoGetMethodName(var MethodName: string; const Original: string);
begin
  MethodName := ProcessNaming(Original, Options.ServiceOptions.MethodNaming);
  if Assigned(FOnGetMethodName) then
    FOnGetMethodName(MethodName, Original);
end;

procedure TOpenApiImporter.DoGetPropName(var PropName: string; const Original: string);
begin
  PropName := ProcessNaming(Original, Options.DTOOptions.PropNaming);
  if Assigned(FOnGetPropName) then
    FOnGetPropName(PropName, Original);
end;

function TOpenApiImporter.GenerateServiceClass(const TypeName, InterfaceName: string): TCodeTypeDeclaration;
var
  Service: TCodeTypeDeclaration;
begin
  Service := FClientUnit.FindType(TypeName);
  if Service <> nil then Exit(Service);

  Service := TCodeTypeDeclaration.Create;
  FClientUnit._Types.Add(Service);
  Service.IsClass := True;
  Service.BaseType.BaseType := 'TRestService';
  Service.InterfaceTypes.Add(TCodeTypeReference.Create(InterfaceName));
  Service.Name := TypeName;

  DoServiceClassCreated(Service);

  Result := Service;
end;

procedure TOpenApiImporter.DoGetServiceClassName(var ServiceClassName: string; const Original: string);
begin
  ServiceClassName := ProcessNaming(Original, Options.ServiceOptions.ClassNaming);
  if Assigned(FOnGetServiceClassName) then
    FOnGetServiceClassName(ServiceClassName, Original);
end;

function TOpenApiImporter.GenerateServiceInterface(const InterfaceName: string): TCodeTypeDeclaration;
var
  Service: TCodeTypeDeclaration;
  RouteAttr: TCodeAttributeDeclaration;
begin
  Service := FClientUnit.FindType(InterfaceName);
  if Service <> nil then Exit(Service);

  Service := TCodeTypeDeclaration.Create;
  FClientUnit._Types.Add(Service);
  Service.IsInterface := True;
  Service.BaseType.BaseType := 'IInvokable';
  Service.Name := InterfaceName;
  Service.InterfaceGuid := TGUID.NewGuid;

  if Options.XDataService then
  begin
    // Add service contract
    Service.AddAttribute('ServiceContract');

    // Add route attribute
    RouteAttr := TCodeAttributeDeclaration.Create('Route');
    Service.CustomAttributes.Add(RouteAttr);
    RouteAttr.AddRawArgument(QuotedStr(''));
  end;

  DoServiceInterfaceCreated(Service);

  Result := Service;
end;

procedure TOpenApiImporter.DoGetTypeName(var TypeName: string; const Original: string);
begin
  TypeName := ProcessNaming(Original, Options.DTOOptions.ClassNaming);
  if Assigned(FOnGetTypeName) then
    FOnGetTypeName(TypeName, Original);
end;

procedure TOpenApiImporter.DoServiceClassCreated(CodeType: TCodeTypeDeclaration);
begin
  if Assigned(FOnServiceClassCreated) then
    FOnServiceClassCreated(CodeType);
end;

procedure TOpenApiImporter.DoServiceInterfaceCreated(CodeType: TCodeTypeDeclaration);
begin
  if Assigned(FOnServiceInterfaceCreated) then
    FOnServiceInterfaceCreated(CodeType);
end;

procedure TOpenApiImporter.DoMethodCreated(Method: TCodeMemberMethod; Parent: TCodeTypeDeclaration);
begin
  if Assigned(FOnMethodCreated) then
    FOnMethodCreated(Method, Parent);
end;

procedure TOpenApiImporter.DoPropCreated(Prop: TCodeMemberProperty; Field: TCodeMemberField; Parent: TCodeTypeDeclaration);
begin
  if Assigned(FOnPropCreated) then
    FOnPropCreated(Prop, Field, Parent);
end;

procedure TOpenApiImporter.DoSolveServiceOperation(var ServiceName, OperationName: string; const Path: string;
  PathItem: TPathItem; Operation: TOperation);
begin
  case Options.ServiceOptions.SolvingMode of
    TServiceSolvingMode.MultipleClientsFromFirstTagAndOperationId:
      begin
        if Operation.Tags.Count > 0 then
          ServiceName := Operation.Tags[0]
        else
          ServiceName := '';
        OperationName := Operation.OperationId;
      end
  else
    // TServiceSolvingMode.SingleClientFromOperationId
    ServiceName := '';
    OperationName := Operation.OperationId;
  end;
end;

procedure TOpenApiImporter.DoTypeCreated(CodeType: TCodeTypeDeclaration);
begin
  if Assigned(FOnTypeCreated) then
    FOnTypeCreated(CodeType);
end;

function TOpenApiImporter.FindMetaType(const Name: string): IMetaType;
var
  MetaType: IMetaType;
begin
  for MetaType in FMetaTypes do
    if SameText(Name, MetaType.TypeName) then
      Exit(MetaType);
  Result := nil;
end;

function TOpenApiImporter.FindService(const Name: string): TMetaService;
var
  Service: TMetaService;
begin
  for Service in FServices do
    if SameText(Name, Service.ServiceName) then
      Exit(Service);
  Result := nil;
end;

function TOpenApiImporter.HttpMethodToAttribute(const Method: string): string;
begin
  if Method = 'GET' then
    Result := 'HttpGet'
  else
  if Method = 'PUT' then
    Result := 'HttpPut'
  else
  if Method = 'POST' then
    Result := 'HttpPost'
  else
  if Method = 'DELETE' then
    Result := 'HttpDelete'
  else
  if Method = 'PATCH' then
    Result := 'HttpPatch'
  else
    raise EOpenApiImportException.CreateFmt('Unsupported HTTP method: %s', [Method]);
end;

function TOpenApiImporter.ProcessNaming(const S: string; Options: TNamingOptions): string;
var
  Index: Integer;
begin
  Index := Options.Mapping.IndexOfName(S);
  if Index >= 0 then
    Exit(Options.Mapping.ValueFromIndex[Index]);

  Result := ToId(S);
  if Options.PascalCase then
    Result := ToPascalCase(Result);
  if Options.FormatString <> '' then
    Result := Format(Options.FormatString, [Result]);
  if TDelphiCodeGenerator.IsReservedWord(Result) then
    Result := '&' + Result;
end;

procedure TOpenApiImporter.ProcessOperation(const Path: string; PathItem: TPathItem;
  Operation: TOperation; const HttpMethod: string);
var
  OperationName: string;
  MethodName: string;
  ServiceName: string;
  MetaMethod: TMetaMethod;
  Service: TMetaService;
  InterfaceName: string;
  ServiceClassName: string;
begin
  if Operation = nil then Exit;

  // Service Mode
  DoSolveServiceOperation(ServiceName, OperationName, Path, PathItem, Operation);

  // Find or create the service
  Service := FindService(ServiceName);
  if Service = nil then
  begin
    Service := TMetaService.Create;
    FServices.Add(Service);
    Service.ServiceName := ServiceName;
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
  BuildMetaMethod(MetaMethod, Path, Operation, HttpMethod);
end;

function TOpenApiImporter.GenerateMethodParam(CodeMethod: TCodeMemberMethod; MetaParam: TMetaParam): TCodeParameterDeclaration;
begin
  Result := CodeMethod.AddParameter(MetaParam.CodeName, MetaParam.ParamType.TypeName);
end;

procedure TOpenApiImporter.GenerateRestService;
var
  CodeType: TCodeTypeDeclaration;
begin
  CodeType := TCodeTypeDeclaration.Create;
  FClientUnit._Types.Add(CodeType);
  CodeType.Name := 'TRestService';
  CodeType.IsClass := True;
  CodeType.BaseType := TCodeTypeReference.Create('TCustomRestService');

  CodeType.AddFunction('CreateConverter', 'TJsonConverter', mvProtected)
    .AddSnippet('Result := TJsonConverter.Create');

  CodeType.AddFunction('Converter', 'TJsonConverter', mvProtected)
    .AddSnippet('Result := TJsonConverter(inherited Converter)');
end;

procedure TOpenApiImporter.ProcessPathItem(const Path: string; PathItem: TPathItem);
begin
  ProcessOperation(Path, PathItem, PathItem.Get, 'GET');
  ProcessOperation(Path, PathItem, PathItem.Put, 'PUT');
  ProcessOperation(Path, PathItem, PathItem.Post, 'POST');
  ProcessOperation(Path, PathItem, PathItem.Delete, 'DELETE');
  ProcessOperation(Path, PathItem, PathItem.Patch, 'PATCH');
  ProcessOperation(Path, PathItem, PathItem.Options, 'OPTIONS');
  ProcessOperation(Path, PathItem, PathItem.Head, 'HEAD');
end;

procedure TOpenApiImporter.RecreateCodeUnits;
begin
  DestroyCodeUnits;
  FClientUnit := TCodeUnit.Create;
  FClientUnit.Name := Options.ClientName + 'Client';

  FDtoUnit := TCodeUnit.Create;
  FDtoUnit.Name := Options.ClientName + 'Dtos';

  FJsonUnit := TCodeUnit.Create;
  FJsonUnit.Name := Options.ClientName + 'Json';
end;

function TOpenApiImporter.ToId(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do
    if not (TBclUtils.IsDigit(S[I]) or TBclUtils.IsLetter(S[I]) or (S[I] = '_')) then
      Result[I] := '_';
  if (Result <> '') and TBclUtils.IsDigit(Result[1]) then
    Result := '_' + Result;
end;

end.
