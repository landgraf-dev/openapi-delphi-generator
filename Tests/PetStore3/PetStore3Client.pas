unit PetStore3Client;

interface

uses
  SysUtils, 
  OpenApiRest, 
  PetStore3Json, 
  PetStore3Dtos;

type
  TPetStore3Config = class;
  TPetStore3Client = class;
  
  TPetStore3Config = class(TCustomRestConfig)
  public
    constructor Create;
  end;
  
  IPetStore3Client = interface(IRestClient)
  end;
  
  TPetStore3Client = class(TCustomRestClient, IPetStore3Client)
  public
    constructor Create;
  end;
  
implementation

{ TPetStore3Config }

constructor TPetStore3Config.Create;
begin
  inherited Create;
  BaseUrl := '';
end;

{ TPetStore3Client }

constructor TPetStore3Client.Create;
begin
  inherited Create(TPetStore3Config.Create);
end;

end.
