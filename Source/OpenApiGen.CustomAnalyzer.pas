unit OpenApiGen.CustomAnalyzer;

interface

uses
  Generics.Collections, SysUtils, Character, StrUtils,
  Bcl.Logging,
  XData.JSchema.Classes,
  OpenApiGen.Options,
  OpenApiGen.Metadata;

type
  TListType = (ltAuto, ltArray, ltList);

  TGetIdentifierProc = reference to procedure(var Name: string; const Original: string);

  TOpenApiCustomAnalyzer = class
  strict private
    FLogger: ILogger;
    FMetaClient: TMetaClient;
    FOptions: TBuilderOptions;
    FOwnsOptions: Boolean;
  strict private
    FOnGetMethodName: TGetIdentifierProc;
    FOnGetTypeName: TGetIdentifierProc;
    FOnGetServiceName: TGetIdentifierProc;
    FOnGetPropName: TGetIdentifierProc;
    FOnGetFieldName: TGetIdentifierProc;
    FOnGetInterfaceName: TGetIdentifierProc;
    FOnGetServiceClassName: TGetIdentifierProc;
  strict protected
    function ToId(const S: string): string; virtual;
    function BuildOperationName(const Path, HttpMethod: string): string;

    function ProcessNaming(const S: string; Options: TNamingOptions): string;
    procedure DoGetPropName(var PropName: string; const Original: string);
    procedure DoGetFieldName(var FieldName: string; const Original: string);
    procedure DoGetMethodName(var MethodName: string; const Original: string);
    procedure DoGetTypeName(var TypeName: string; const Original: string);
    procedure DoGetServiceName(var ServiceName: string; const Original: string);
    procedure DoGetInterfaceName(var InterfaceName: string; const Original: string);
    procedure DoGetServiceClassName(var ServiceClassName: string; const Original: string);

    function MetaTypeFromSchema(Schema: TJsonSchema; const DefaultTypeName: string; ListType: TListType): IMetaType;
    function MetaTypeFromString(const Format: string): IMetaType;
    function MetaTypeFromInteger(const Format: string): IMetaType;
    function MetaTypeFromArray(Schema: TArraySchema; const DefaultItemTypeName: string; ListType: TListType): IMetaType;
    function MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string; ListType: TListType): IMetaType; virtual;
    function MetaTypeFromObject(const Name: string; Schema: TObjectSchema): IMetaType;

    property Logger: ILogger read FLogger;
  public
    constructor Create(Options: TBuilderOptions; AOwnsOptions: Boolean = False); reintroduce;
    destructor Destroy; override;

    property Options: TBuilderOptions read FOptions;
    property MetaClient: TMetaClient read FMetaClient;
  public
    property OnGetMethodName: TGetIdentifierProc read FOnGetMethodName write FOnGetMethodName;
    property OnGetTypeName: TGetIdentifierProc read FOnGetTypeName write FOnGetTypeName;
    property OnGetServiceName: TGetIdentifierProc read FOnGetServiceName write FOnGetServiceName;
    property OnGetPropName: TGetIdentifierProc read FOnGetPropName write FOnGetPropName;
    property OnGetFieldName: TGetIdentifierProc read FOnGetFieldName write FOnGetFieldName;
    property OnGetInterfaceName: TGetIdentifierProc read FOnGetInterfaceName write FOnGetInterfaceName;
    property OnGetServiceClassName: TGetIdentifierProc read FOnGetServiceClassName write FOnGetServiceClassName;
  end;

  EOpenApiAnalyzerException = class(Exception)
  end;

function ToPascalCase(const S: string): string;

implementation

uses
  Bcl.Code.DelphiGenerator,
  Bcl.Utils;

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

{ TOpenApiCustomAnalyzer }

function TOpenApiCustomAnalyzer.BuildOperationName(const Path, HttpMethod: string): string;
var
  TempName: string;
  Parts: TArray<string>;
  Part: string;
begin
  TempName := Path;
  TempName := StringReplace(TempName, '{', '', [rfReplaceAll]);
  TempName := StringReplace(TempName, '}', '', [rfReplaceAll]);
  Parts := SplitString(TempName + '/' + LowerCase(HttpMethod), '/');
  if TempName = '/' then
    Result := 'Root'
  else
    Result := '';
  for Part in Parts do
    if Part <> '' then
      Result := Result + ToPascalCase(Part);
  Result := ToId(Result);
end;

constructor TOpenApiCustomAnalyzer.Create(Options: TBuilderOptions; AOwnsOptions: Boolean);
begin
  inherited Create;
  FOptions := Options;
  FOwnsOptions := AOwnsOptions;
  FLogger := TLogManager.Instance.GetLogger(Self);
  FMetaClient := TMetaClient.Create;
end;

destructor TOpenApiCustomAnalyzer.Destroy;
begin
  FMetaClient.Free;
  if FOwnsOptions then
    FOptions.Free;
  inherited;
end;

procedure TOpenApiCustomAnalyzer.DoGetFieldName(var FieldName: string; const Original: string);
begin
  FieldName := ProcessNaming(Original, Options.DTOOptions.FieldNaming);
  if Assigned(FOnGetFieldName) then
    FOnGetPropName(FieldName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetInterfaceName(var InterfaceName: string; const Original: string);
begin
  InterfaceName := ProcessNaming(Original, Options.ServiceOptions.InterfaceNaming);
  if Assigned(FOnGetInterfaceName) then
    FOnGetInterfaceName(InterfaceName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetMethodName(var MethodName: string; const Original: string);
begin
  MethodName := ProcessNaming(Original, Options.ServiceOptions.MethodNaming);
  if Assigned(FOnGetMethodName) then
    FOnGetMethodName(MethodName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetPropName(var PropName: string; const Original: string);
begin
  PropName := ProcessNaming(Original, Options.DTOOptions.PropNaming);
  if Assigned(FOnGetPropName) then
    FOnGetPropName(PropName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetServiceClassName(var ServiceClassName: string; const Original: string);
begin
  ServiceClassName := ProcessNaming(Original, Options.ServiceOptions.ClassNaming);
  if Assigned(FOnGetServiceClassName) then
    FOnGetServiceClassName(ServiceClassName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetServiceName(var ServiceName: string; const Original: string);
begin
  ServiceName := ProcessNaming(Original, Options.ServiceOptions.ServiceNaming);
  if Assigned(FOnGetServiceName) then
    FOnGetServiceName(ServiceName, Original);
end;

procedure TOpenApiCustomAnalyzer.DoGetTypeName(var TypeName: string; const Original: string);
begin
  TypeName := ProcessNaming(Original, Options.DTOOptions.ClassNaming);
  if Assigned(FOnGetTypeName) then
    FOnGetTypeName(TypeName, Original);
end;

function TOpenApiCustomAnalyzer.MetaTypeFromArray(Schema: TArraySchema; const DefaultItemTypeName: string;
  ListType: TListType): IMetaType;
var
  ItemType: IMetaType;
begin
  if Schema.ValidateItemByPosition then
    raise EOpenApiAnalyzerException.CreateFmt('Array schema validated by position not supported (%s)', [DefaultItemTypeName]);
  if Schema.ItemSchemas.Count <> 1 then
    raise EOpenApiAnalyzerException.CreateFmt('Expecting only one item schema in array (%s)', [DefaultItemTypeName]);

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

function TOpenApiCustomAnalyzer.MetaTypeFromInteger(const Format: string): IMetaType;
begin
  if Format = 'int64' then
    Result := TInt64MetaType.Create
  else
    Result := TIntegerMetaType.Create
end;

function TOpenApiCustomAnalyzer.MetaTypeFromObject(const Name: string; Schema: TObjectSchema): IMetaType;
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
  ObjType.SetDescription(Schema.Description);
  for SchemaProp in Schema.Properties do
  begin
    MetaProp := TMetaProperty.Create;
    ObjType.Props.Add(MetaProp);

    DoGetPropName(PropName, SchemaProp.Key);
    DoGetFieldName(FieldName, SchemaProp.Key);

    MetaProp.RestName := SchemaProp.Key;
    MetaProp.PropName := PropName;
    MetaProp.FieldName := FieldName;
    MetaProp.Description := SchemaProp.Value.Description;
    MetaProp.Required := Schema.Required.IndexOf(SchemaProp.Key) >= 0;
    MetaProp.PropType := MetaTypeFromSchema(SchemaProp.Value, Name + PropName, TListType.ltList);
    if Options.XDataService and not MetaProp.Required and not MetaProp.PropType.IsManaged then
      MetaProp.PropType := TNullableMetaType.Create(MetaProp.PropType);
  end;
end;

function TOpenApiCustomAnalyzer.MetaTypeFromReference(RefSchema: TReferenceSchema; const DefaultTypeName: string;
  ListType: TListType): IMetaType;
begin
end;

function TOpenApiCustomAnalyzer.MetaTypeFromSchema(Schema: TJsonSchema; const DefaultTypeName: string;
  ListType: TListType): IMetaType;
var
  Schemas: TList<TJsonSchema>;
begin
  if Schema = nil then
    raise EOpenApiAnalyzerException.Create('Schema not defined');

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
  if Schema is TOneOfSchema then
  begin
    Schemas := TOneOfSchema(Schema).Schemas;
    if Schemas.Count = 0 then
      raise EOpenApiAnalyzerException.Create('OneOf schema does not have sub schemas')
    else
    begin
      if Schemas.Count > 1 then
        Logger.Warning(Format('OneOf for type %s has multiple schemas, picking the first schema in list', [DefaultTypeName]));
      Result := MetaTypeFromSchema(Schemas[0], DefaultTypeName, ListType);
    end;
  end
  else
    raise EOpenApiAnalyzerException.CreateFmt('Unsupported schema type: %s', [Schema.ClassName]);

  if Result is TObjectMetaType and (MetaClient.FindMetaType(Result.TypeName) = nil) then
    MetaClient.MetaTypes.Add(Result);
  if Result is TArrayMetaType and (MetaClient.FindMetaType(Result.TypeName) = nil) then
    MetaClient.MetaTypes.Add(Result);
  if Result is TListMetaType and (MetaClient.FindMetaType(Result.TypeName) = nil) then
    MetaClient.MetaTypes.Add(Result);
end;

function TOpenApiCustomAnalyzer.MetaTypeFromString(const Format: string): IMetaType;
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

function TOpenApiCustomAnalyzer.ProcessNaming(const S: string; Options: TNamingOptions): string;
begin
  if Options.Mapping.TryGetValue(S, Result) then
    Exit;

  Result := ToId(S);
  if Options.PascalCase then
    Result := ToPascalCase(Result);
  if Options.FormatString <> '' then
    Result := Format(Options.FormatString, [Result]);
  if TDelphiCodeGenerator.IsReservedWord(Result) then
    Result := '&' + Result;

  if Options.Mapping.ContainsKey(Result) then
    Result := Options.Mapping[Result];
end;

function TOpenApiCustomAnalyzer.ToId(const S: string): string;
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
