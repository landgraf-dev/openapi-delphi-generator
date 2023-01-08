unit PetStore3Client;

interface

uses
  SysUtils, 
  OpenApiRest, 
  PetStore3Json, 
  PetStore3Dtos;

type
  TRestService = class;
  TPetStore3Config = class;
  TPetStore3Client = class;
  
  TRestService = class(TCustomRestService)
  protected
    function CreateConverter: TCustomJsonConverter; override;
    function Converter: TJsonConverter;
  end;
  
  TPetStore3Config = class(TCustomRestConfig)
  public
    constructor Create;
  end;
  
  IPetStore3Client = interface(IRestClient)
    function : IService;
  end;
  
  TPetStore3Client = class(TCustomRestClient, IPetStore3Client)
  public
    function : IService;
    constructor Create;
  end;
  
implementation

{ TRestService }

function TRestService.CreateConverter: TCustomJsonConverter;
begin
  Result := TJsonConverter.Create;
end;

function TRestService.Converter: TJsonConverter;
begin
  Result := TJsonConverter(inherited Converter);
end;

{ TPetStore3Config }

constructor TPetStore3Config.Create;
begin
  inherited Create;
  BaseUrl := 'https://petstore3.swagger.io/api/v3';
end;

{ TPetStore3Client }

function TPetStore3Client.: IService;
begin
  Result := TService.Create(Config);
end;

constructor TPetStore3Client.Create;
begin
  inherited Create(TPetStore3Config.Create);
end;

end.
