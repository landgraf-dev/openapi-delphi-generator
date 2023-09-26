unit OpenApiGen.Metadata;

interface

uses
  Generics.Collections, SysUtils;

type
  IMetaType = interface
  ['{B4DC806C-42C7-4323-8F3B-1A3FE7B75F6A}']
    function TypeName: string;
    function CodeToParam(const ParamName: string): string;
    function IsManaged: Boolean;
    function ToJsonFunctionName: string;
    function ToJsonValueFunctionName: string;
    function FromJsonFunctionName: string;
    function FromJsonValueFunctionName: string;
    function IsBinary: Boolean;
    function Description: string;
  end;

  ICountableMetaType = interface
  ['{8AAB3498-C990-4D60-AF24-CABFF705D67B}']
    function GetItemType: IMetaType;
  end;

  TMetaType = class(TInterfacedObject, IMetaType)
  strict private
    FDescription: string;
  public
    function TypeName: string; virtual; abstract;
    function CodeToParam(const ParamName: string): string; virtual;
    function IsManaged: Boolean; virtual;
    function ToJsonFunctionName: string; virtual;
    function ToJsonValueFunctionName: string; virtual;
    function FromJsonFunctionName: string; virtual;
    function FromJsonValueFunctionName: string; virtual;
    function IsBinary: Boolean; virtual;
    function Description: string;
    procedure SetDescription(const Value: string);
  end;

  TStringMetaType = class(TMetaType)
  public
    function TypeName: string; override;
    function CodeToParam(const ParamName: string): string; override;
  end;

  TDoubleMetaType = class(TMetaType)
  public
    function TypeName: string; override;
  end;

  TIntegerMetaType = class(TMetaType)
  public
    function TypeName: string; override;
    function CodeToParam(const ParamName: string): string; override;
  end;

  TInt64MetaType = class(TIntegerMetaType)
  public
    function TypeName: string; override;
  end;

  TBooleanMetaType = class(TMetaType)
  public
    function TypeName: string; override;
    function CodeToParam(const ParamName: string): string; override;
  end;

  TDateTimeMetaType = class(TMetaType)
  public
    function TypeName: string; override;
    function CodeToParam(const ParamName: string): string; override;
  end;

  TDateMetaType = class(TDateTimeMetaType)
  public
    function TypeName: string; override;
    function CodeToParam(const ParamName: string): string; override;
  end;

  TBytesMetaType = class(TMetaType)
  public
    function TypeName: string; override;
  end;

  TBinaryMetaType = class(TMetaType)
  public
    function TypeName: string; override;
    function IsBinary: Boolean; override;
  end;

  TListMetaType = class(TMetaType)
  private
    FItemType: IMetaType;
  public
    function TypeName: string; override;
    function IsManaged: Boolean; override;
  public
    constructor Create(const AItemType: IMetaType);
    property ItemType: IMetaType read FItemType;
  end;

  TObjectListMetaType = class(TListMetaType)
  end;

  TMetaProperty = class
  private
    FFieldName: string;
    FPropName: string;
    [Weak] FPropType: IMetaType;
    FRestName: string;
    FRequired: Boolean;
    FDescription: string;
    function GetHasValueFieldName: string;
    function GetHasValuePropName: string;
    function GetIsNullable: Boolean;
  public
    property FieldName: string read FFieldName write FFieldName;
    property PropName: string read FPropName write FPropName;
    property RestName: string read FRestName write FRestName;
    property PropType: IMetaType read FPropType write FPropType;
    property Required: Boolean read FRequired write FRequired;
    property HasValueFieldName: string read GetHasValueFieldName;
    property HasValuePropName: string read GetHasValuePropName;
    property IsNullable: Boolean read GetIsNullable;
    property Description: string read FDescription write FDescription;
  end;

  TObjectMetaType = class(TMetaType)
  private
    FTypeName: string;
    FProps: TList<TMetaProperty>;
  public
    constructor Create(const ATypeName: string);
    destructor Destroy; override;
    function TypeName: string; override;
    function IsManaged: Boolean; override;
    property Props: TList<TMetaProperty> read FProps;
  end;

  TArrayMetaType = class(TMetaType, ICountableMetaType)
  private
    FTypeName: string;
    FItemType: IMetaType;
    function GetItemType: IMetaType;
  public
    function TypeName: string; override;
  public
    constructor Create(const AItemType: IMetaType);
    property ItemType: IMetaType read GetItemType;
  end;

  TNullableMetaType = class(TMetaType)
  private
    FWrappedType: IMetaType;
  public
    constructor Create(AWrappedType: IMetaType);
    function TypeName: string; override;
    property WrappedType: IMetaType read FWrappedType;
  end;

  TParamLocation = (plQuery, plUrl, plBody, plForm, plHeader);

  TMetaParam = class
  private
    FRestName: string;
    FCodeName: string;
    FParamType: IMetaType;
    FLocation: TParamLocation;
    FDescription: string;
  public
    property RestName: string read FRestName write FRestName;
    property CodeName: string read FCodeName write FCodeName;
    property ParamType: IMetaType read FParamType write FParamType;
    property Location: TParamLocation read FLocation write FLocation;
    property Description: string read FDescription write FDescription;
  end;

  TMetaMethod = class
  private
    FCodeName: string;
    FParams: TList<TMetaParam>;
    FReturnType: IMetaType;
    FUrlPath: string;
    FHttpMethod: string;
    FIgnore: Boolean;
    FProduces: string;
    FConsumes: string;
    FRemarks: string;
    FSummary: string;
  public
    constructor Create;
    destructor Destroy; override;
    property CodeName: string read FCodeName write FCodeName;
    property HttpMethod: string read FHttpMethod write FHttpMethod;
    property Params: TList<TMetaParam> read FParams;
    property UrlPath: string read FUrlPath write FUrlPath;
    property ReturnType: IMetaType read FReturnType write FReturnType;
    property Ignore: Boolean read FIgnore write FIgnore;
    property Consumes: string read FConsumes write FConsumes;
    property Produces: string read FProduces write FProduces;
    property Summary: string read FSummary write FSummary;
    property Remarks: string read FRemarks write FRemarks;
  end;

  TMetaService = class
  private
    FInterfaceName: string;
    FServiceName: string;
    FServiceClass: string;
    FMethods: TList<TMetaMethod>;
    FDescription: string;
  public
    constructor Create;
    destructor Destroy; override;
    function HasMethods: Boolean;
    property ServiceName: string read FServiceName write FServiceName;
    property InterfaceName: string read FInterfaceName write FInterfaceName;
    property ServiceClass: string read FServiceClass write FServiceClass;
    property Methods: TList<TMetaMethod> read FMethods;
    property Description: string read FDescription write FDescription;
  end;

  TMetaClient = class
  private
    FMetaTypes: TList<IMetaType>;
    FServices: TList<TMetaService>;
    FInterfaceName: string;
    FClientClass: string;
    FConfigClass: string;
    FBaseUrl: string;
    FReferences: TList<IMetaType>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddReference(AType: IMetaType); // just for memory management
    function FindMetaType(const Name: string): IMetaType;
    function FindService(const Name: string): TMetaService;
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property InterfaceName: string read FInterfaceName write FInterfaceName;
    property ClientClass: string read FClientClass write FClientClass;
    property ConfigClass: string read FConfigClass write FConfigClass;
    property MetaTypes: TList<IMetaType> read FMetaTypes;
    property Services: TList<TMetaService> read FServices;
  end;

implementation

const
  cToJsonValueFmt = '%sToJsonValue';

{ TMetaType }

function TMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := ParamName;
end;

function TMetaType.Description: string;
begin
  Result := FDescription;
end;

function TMetaType.FromJsonFunctionName: string;
begin
  Result := Format('%sFromJson', [TypeName]);
end;

function TMetaType.FromJsonValueFunctionName: string;
begin
  Result := Format('%sFromJsonValue', [TypeName]);
end;

function TMetaType.IsBinary: Boolean;
begin
  Result := False;
end;

function TMetaType.IsManaged: Boolean;
begin
  Result := False;
end;

procedure TMetaType.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

function TMetaType.ToJsonFunctionName: string;
begin
  Result := Format('%sToJson', [TypeName]);
end;

function TMetaType.ToJsonValueFunctionName: string;
begin
  Result := Format('%sToJsonValue', [TypeName]);
end;

{ TStringMetaType }

function TStringMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := ParamName;
end;

function TStringMetaType.TypeName: string;
begin
  Result := 'string';
end;

{ TListMetaType }

constructor TListMetaType.Create(const AItemType: IMetaType);
begin
  inherited Create;
  FItemType := AItemType;
end;

function TListMetaType.IsManaged: Boolean;
begin
  Result := True;
end;

function TListMetaType.TypeName: string;
begin
  Result := Format('%sList', [ItemType.TypeName]);
end;

{ TNullableMetaType }

constructor TNullableMetaType.Create(AWrappedType: IMetaType);
begin
  inherited Create;
  FWrappedType := AWrappedType;
end;

function TNullableMetaType.TypeName: string;
begin
  Result := Format('Nullable<%s>', [WrappedType.TypeName]);
end;

{ TArrayMetaType }

constructor TArrayMetaType.Create(const AItemType: IMetaType);
begin
  inherited Create;
  FItemType := AItemType;
  FTypeName := Format('%sArray', [AItemType.TypeName]);
end;

function TArrayMetaType.GetItemType: IMetaType;
begin
  Result := FItemType;
end;

function TArrayMetaType.TypeName: string;
begin
  Result := FTypeName;
end;

{ TObjectMetaType }

constructor TObjectMetaType.Create(const ATypeName: string);
begin
  inherited Create;
  FTypeName := ATypeName;
  FProps := TObjectList<TMetaProperty>.Create(True);
end;

destructor TObjectMetaType.Destroy;
begin
  FProps.Free;
  inherited;
end;

function TObjectMetaType.IsManaged: Boolean;
begin
  Result := True;
end;

function TObjectMetaType.TypeName: string;
begin
  Result := FTypeName;
end;

{ TDoubleMetaType }

function TDoubleMetaType.TypeName: string;
begin
  Result := 'Double';
end;

{ TIntegerMetaType }

function TIntegerMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := Format('IntToStr(%s)', [ParamName]);
end;

function TIntegerMetaType.TypeName: string;
begin
  Result := 'Integer';
end;

{ TInt64MetaType }

function TInt64MetaType.TypeName: string;
begin
  Result := 'Int64';
end;

{ TBooleanMetaType }

function TBooleanMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := Format('BoolToParam(%s)', [ParamName]);
end;

function TBooleanMetaType.TypeName: string;
begin
  Result := 'Boolean';
end;

{ TBinaryMetaType }

function TBinaryMetaType.IsBinary: Boolean;
begin
  Result := True;
end;

function TBinaryMetaType.TypeName: string;
begin
  Result := 'TBytes';
end;

{ TDateTimeMetaType }

function TDateTimeMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := Format('DateTimeToIso(%s)', [ParamName]);
end;

function TDateTimeMetaType.TypeName: string;
begin
  Result := 'TDateTime';
end;

{ TDateMetaType }

function TDateMetaType.CodeToParam(const ParamName: string): string;
begin
  Result := Format('DateToIso(%s)', [ParamName]);
end;

function TDateMetaType.TypeName: string;
begin
  Result := 'TDate';
end;

{ TBytesMetaType }

function TBytesMetaType.TypeName: string;
begin
  Result := 'TBytes';
end;

{ TMetaMethod }

constructor TMetaMethod.Create;
begin
  inherited Create;
  FParams := TObjectList<TMetaParam>.Create(True);
end;

destructor TMetaMethod.Destroy;
begin
  FParams.Free;
  inherited;
end;

{ TMetaService }

constructor TMetaService.Create;
begin
  inherited Create;
  FMethods := TObjectList<TMetaMethod>.Create(True);
end;

destructor TMetaService.Destroy;
begin
  FMethods.Free;
  inherited;
end;

function TMetaService.HasMethods: Boolean;
var
  Method: TMetaMethod;
begin
  Result := False;
  for Method in Methods do
    if not Method.Ignore then
      Exit(True);
end;

{ TMetaProperty }

function TMetaProperty.GetIsNullable: Boolean;
begin
  Result := not Required and Assigned(PropType) and not PropType.IsManaged;
end;

function TMetaProperty.GetHasValueFieldName: string;
begin
  Result := FieldName + 'HasValue';
end;

function TMetaProperty.GetHasValuePropName: string;
begin
  Result := PropName + 'HasValue';
end;

{ TMetaClient }

procedure TMetaClient.AddReference(AType: IMetaType);
begin
  FReferences.Add(AType);
end;

procedure TMetaClient.Clear;
begin
  MetaTypes.Clear;
  Services.Clear;
  FReferences.Clear;
end;

constructor TMetaClient.Create;
begin
  inherited Create;
  FMetaTypes := TList<IMetaType>.Create;
  FServices := TObjectList<TMetaService>.Create;
  FReferences := TList<IMetaType>.Create;
end;

destructor TMetaClient.Destroy;
begin
  FReferences.Free;
  FServices.Free;
  FMetaTypes.Free;
  inherited;
end;

function TMetaClient.FindMetaType(const Name: string): IMetaType;
var
  MetaType: IMetaType;
begin
  for MetaType in MetaTypes do
    if SameText(Name, MetaType.TypeName) then
      Exit(MetaType);
  Result := nil;
end;

function TMetaClient.FindService(const Name: string): TMetaService;
var
  Service: TMetaService;
begin
  for Service in Services do
    if SameText(Name, Service.ServiceName) then
      Exit(Service);
  Result := nil;
end;

end.
