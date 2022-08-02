unit OpenApiGen.Options;

interface

uses
  System.Classes, Bcl.Collections;

type
  /// <summary>Specifies how the method name and service classes/interfaces are generated.</summary>
  TServiceSolvingMode = (
    /// <summary>Single service, method name from the Swagger operation ID.</summary>
    SingleClientFromOperationId,

    /// <summary>From the first operation tag and operation ID (method name = operation ID, service name = first operation tag).</summary>
    MultipleClientsFromFirstTagAndOperationId,

    /// <summary>Multiple clients from the Swagger operation ID in the form 'I{service name}Service.{operation}'.</summary>
    MultipleClientsFromXDataOperationId
  );

  TStringMapping = class(TOrderedDictionary<string, string>)
  end;

  TNamingOptions = class
  private
    FPascalCase: Boolean;
    FFormatString: string;
    FMapping: TStringMapping;
  public
    constructor Create;
    destructor Destroy; override;
    property FormatString: string read FFormatString write FFormatString;
    property PascalCase: Boolean read FPascalCase write FPascalCase;
    property Mapping: TStringMapping read FMapping;
  end;

  TDtoOptions = class
  private
    FClassNaming: TNamingOptions;
    FPropNaming: TNamingOptions;
    FFieldNaming: TNamingOptions;
  public
    constructor Create;
    destructor Destroy; override;
    property ClassNaming: TNamingOptions read FClassNaming;
    property PropNaming: TNamingOptions read FPropNaming;
    property FieldNaming: TNamingOptions read FFieldNaming;
  end;

  TServiceOptions = class
  private
    FMethodNaming: TNamingOptions;
    FServiceNaming: TNamingOptions;
    FInterfaceNaming: TNamingOptions;
    FSolvingMode: TServiceSolvingMode;
    FClassNaming: TNamingOptions;
    FParamNaming: TNamingOptions;
    FInterfaceGuids: TStringMapping;
  public
    constructor Create;
    destructor Destroy; override;
    property ServiceNaming: TNamingOptions read FServiceNaming;
    property InterfaceNaming: TNamingOptions read FInterfaceNaming;
    property ClassNaming: TNamingOptions read FClassNaming;
    property MethodNaming: TNamingOptions read FMethodNaming;
    property ParamNaming: TNamingOptions read FParamNaming;
    property SolvingMode: TServiceSolvingMode read FSolvingMode write FSolvingMode;
    property InterfaceGuids: TStringMapping read FInterfaceGuids;
  end;

  TGeneratorOptions = class
  private
    FInputDocument: string;
    FOutputFolder: string;
  public
    property InputDocument: string read FInputDocument write FInputDocument;
    property OutputFolder: string read FOutputFolder write FOutputFolder;
  end;

  TBuilderOptions = class
  private
    FDtoOptions: TDtoOptions;
    FServiceOptions: TServiceOptions;
    FClientName: string;
    FXDataService: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property ClientName: string read FClientName write FClientName;
    property DtoOptions: TDtoOptions read FDtoOptions;
    property ServiceOptions: TServiceOptions read FServiceOptions;
    property XDataService: Boolean read FXDataService write FXDataService;
  end;

implementation

{ TDtoOptions }

constructor TDtoOptions.Create;
begin
  inherited Create;
  FClassNaming := TNamingOptions.Create;
  FPropNaming := TNamingOptions.Create;
  FFieldNaming := TNamingOptions.Create;

  // Defaults
  FClassNaming.PascalCase := True;
  FClassNaming.FormatString := 'T%s';

  FFieldNaming.PascalCase := True;
  FFieldNaming.FormatString := 'F%s';

  FPropNaming.PascalCase := True;
end;

destructor TDtoOptions.Destroy;
begin
  FFieldNaming.Free;
  FPropNaming.Free;
  FClassNaming.Free;
  inherited;
end;

{ TServiceOptions }

constructor TServiceOptions.Create;
begin
  inherited Create;
  FInterfaceGuids := TStringMapping.Create;
  FMethodNaming := TNamingOptions.Create;
  FInterfaceNaming := TNamingOptions.Create;
  FServiceNaming := TNamingOptions.Create;
  FClassNaming := TNamingOptions.Create;
  FParamNaming := TNamingOptions.Create;

  // Defaults
  MethodNaming.PascalCase := True;

  InterfaceNaming.FormatString := 'I%sService';
  InterfaceNaming.PascalCase := True;

  ClassNaming.FormatString := 'T%sService';
  ClassNaming.PascalCase := True;

  ParamNaming.PascalCase := True;

  ServiceNaming.PascalCase := True;
end;

destructor TServiceOptions.Destroy;
begin
  FInterfaceGuids.Free;
  FMethodNaming.Free;
  FInterfaceNaming.Free;
  FServiceNaming.Free;
  FClassNaming.Free;
  FParamNaming.Free;
  inherited;
end;

{ TNamingOptions }

constructor TNamingOptions.Create;
begin
  inherited Create;
  FMapping := TStringMapping.Create;
end;

destructor TNamingOptions.Destroy;
begin
  FMapping.Free;
  inherited;
end;

{ TBuilderOptions }

constructor TBuilderOptions.Create;
begin
  inherited Create;
  FDtoOptions := TDtoOptions.Create;
  FServiceOptions := TServiceOptions.Create;
  FClientName := 'Api';
end;

destructor TBuilderOptions.Destroy;
begin
  FDtoOptions.Free;
  FServiceOptions.Free;
  inherited;
end;

end.
