unit PetStoreClient;

interface

uses
  System.SysUtils, 
  OpenApiRest, 
  PetStoreJson, 
  PetStoreDtos;

type
  TRestService = class;
  TPetService = class;
  TStoreService = class;
  TUserService = class;
  
  TRestService = class(TCustomRestService)
  protected
    function CreateConverter: TJsonConverter;
    function Converter: TJsonConverter;
  public
    constructor Create;
  end;
  
  IPetService = interface(IInvokable)
    ['{068D6C7E-07CF-438B-9306-42E6B86536B6}']
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    procedure UpdatePet(Body: TPet);
    procedure AddPet(Body: TPet);
    function FindPetsByStatus(Status: stringArray): TPetList;
    function FindPetsByTags(Tags: stringArray): TPetList;
    function GetPetById(PetId: Int64): TPet;
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    procedure DeletePet(ApiKey: string; PetId: Int64);
  end;
  
  TPetService = class(TRestService, IPetService)
  public
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    procedure UpdatePet(Body: TPet);
    procedure AddPet(Body: TPet);
    function FindPetsByStatus(Status: stringArray): TPetList;
    function FindPetsByTags(Tags: stringArray): TPetList;
    function GetPetById(PetId: Int64): TPet;
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    procedure DeletePet(ApiKey: string; PetId: Int64);
  end;
  
  IStoreService = interface(IInvokable)
    ['{55DDD78A-6C80-4FE5-A1C3-BECDC07F6053}']
    function PlaceOrder(Body: TOrder): TOrder;
    function GetOrderById(OrderId: Int64): TOrder;
    procedure DeleteOrder(OrderId: Int64);
    function GetInventory: TGetInventoryOutput;
  end;
  
  TStoreService = class(TRestService, IStoreService)
  public
    function PlaceOrder(Body: TOrder): TOrder;
    function GetOrderById(OrderId: Int64): TOrder;
    procedure DeleteOrder(OrderId: Int64);
    function GetInventory: TGetInventoryOutput;
  end;
  
  IUserService = interface(IInvokable)
    ['{B0343463-453E-405F-B1B7-33FFD33C7415}']
    procedure CreateUsersWithArrayInput(Body: TUserList);
    procedure CreateUsersWithListInput(Body: TUserList);
    function GetUserByName(Username: string): TUser;
    procedure UpdateUser(Username: string; Body: TUser);
    procedure DeleteUser(Username: string);
    function LoginUser(Username: string; Password: string): string;
    procedure LogoutUser;
    procedure CreateUser(Body: TUser);
  end;
  
  TUserService = class(TRestService, IUserService)
  public
    procedure CreateUsersWithArrayInput(Body: TUserList);
    procedure CreateUsersWithListInput(Body: TUserList);
    function GetUserByName(Username: string): TUser;
    procedure UpdateUser(Username: string; Body: TUser);
    procedure DeleteUser(Username: string);
    function LoginUser(Username: string; Password: string): string;
    procedure LogoutUser;
    procedure CreateUser(Body: TUser);
  end;
  
implementation

{ TRestService }

function TRestService.CreateConverter: TJsonConverter;
begin
  Result := TJsonConverter.Create;
end;

function TRestService.Converter: TJsonConverter;
begin
  Result := TJsonConverter(inherited Converter);
end;

constructor TRestService.Create;
begin
  inherited Create('https://petstore.swagger.io/v2');
end;

{ TPetService }

function TPetService.UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}/uploadImage', 'POST');
  Request.AddUrlParam('petId', IntToStr(PetId));
  raise Exception.Create('Form param ''AdditionalMetadata'' not supported');
  raise Exception.Create('Form param ''&File'' not supported');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TApiResponseFromJson(Response.ContentAsString);
end;

procedure TPetService.UpdatePet(Body: TPet);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'PUT');
  Request.AddBody(Converter.TPetToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.AddPet(Body: TPet);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'POST');
  Request.AddBody(Converter.TPetToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

function TPetService.FindPetsByStatus(Status: stringArray): TPetList;
var
  Request: IRestRequest;
  I: Integer;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByStatus', 'GET');
  for I := 0 to Length(Status) - 1 do
    Request.AddQueryParam('status', Status[I]);
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TPetListFromJson(Response.ContentAsString);
end;

function TPetService.FindPetsByTags(Tags: stringArray): TPetList;
var
  Request: IRestRequest;
  I: Integer;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByTags', 'GET');
  for I := 0 to Length(Tags) - 1 do
    Request.AddQueryParam('tags', Tags[I]);
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TPetListFromJson(Response.ContentAsString);
end;

function TPetService.GetPetById(PetId: Int64): TPet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'GET');
  Request.AddUrlParam('petId', IntToStr(PetId));
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TPetFromJson(Response.ContentAsString);
end;

procedure TPetService.UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'POST');
  Request.AddUrlParam('petId', IntToStr(PetId));
  raise Exception.Create('Form param ''Name'' not supported');
  raise Exception.Create('Form param ''Status'' not supported');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.DeletePet(ApiKey: string; PetId: Int64);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'DELETE');
  Request.AddHeader('api_key', ApiKey);
  Request.AddUrlParam('petId', IntToStr(PetId));
  Response := Request.Execute;
  CheckError(Response);
end;

{ TStoreService }

function TStoreService.PlaceOrder(Body: TOrder): TOrder;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order', 'POST');
  Request.AddBody(Converter.TOrderToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TOrderFromJson(Response.ContentAsString);
end;

function TStoreService.GetOrderById(OrderId: Int64): TOrder;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'GET');
  Request.AddUrlParam('orderId', IntToStr(OrderId));
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TOrderFromJson(Response.ContentAsString);
end;

procedure TStoreService.DeleteOrder(OrderId: Int64);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'DELETE');
  Request.AddUrlParam('orderId', IntToStr(OrderId));
  Response := Request.Execute;
  CheckError(Response);
end;

function TStoreService.GetInventory: TGetInventoryOutput;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/inventory', 'GET');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TGetInventoryOutputFromJson(Response.ContentAsString);
end;

{ TUserService }

procedure TUserService.CreateUsersWithArrayInput(Body: TUserList);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/createWithArray', 'POST');
  Request.AddBody(Converter.TUserListToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.CreateUsersWithListInput(Body: TUserList);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/createWithList', 'POST');
  Request.AddBody(Converter.TUserListToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

function TUserService.GetUserByName(Username: string): TUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'GET');
  Request.AddUrlParam('username', Username);
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TUserFromJson(Response.ContentAsString);
end;

procedure TUserService.UpdateUser(Username: string; Body: TUser);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'PUT');
  Request.AddUrlParam('username', Username);
  Request.AddBody(Converter.TUserToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.DeleteUser(Username: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'DELETE');
  Request.AddUrlParam('username', Username);
  Response := Request.Execute;
  CheckError(Response);
end;

function TUserService.LoginUser(Username: string; Password: string): string;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/login', 'GET');
  Request.AddQueryParam('username', Username);
  Request.AddQueryParam('password', Password);
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.stringFromJson(Response.ContentAsString);
end;

procedure TUserService.LogoutUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/logout', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.CreateUser(Body: TUser);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user', 'POST');
  Request.AddBody(Converter.TUserToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
end;

end.
