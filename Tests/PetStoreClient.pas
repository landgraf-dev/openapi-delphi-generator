unit PetStoreClient;

interface

uses
  System.SysUtils, 
  OpenApiRest, 
  PetStoreJson, 
  PetStoreDtos;

type
  TRestService = class;
  TService = class;
  
  TRestService = class(TCustomRestService)
  protected
    function CreateConverter: TJsonConverter;
    function Converter: TJsonConverter;
  public
    constructor Create;
  end;
  
  IService = interface(IInvokable)
    ['{B671860A-7BCD-4F07-84A6-FF6F2C98AC9C}']
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    procedure UpdatePet(Body: TPet);
    procedure AddPet(Body: TPet);
    function FindPetsByStatus(Status: stringArray): TPetList;
    function FindPetsByTags(Tags: stringArray): TPetList;
    function GetPetById(PetId: Int64): TPet;
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    procedure DeletePet(ApiKey: string; PetId: Int64);
    function PlaceOrder(Body: TOrder): TOrder;
    function GetOrderById(OrderId: Int64): TOrder;
    procedure DeleteOrder(OrderId: Int64);
    function GetInventory: TGetInventoryOutput;
    procedure CreateUsersWithArrayInput(Body: TUserList);
    procedure CreateUsersWithListInput(Body: TUserList);
    function GetUserByName(Username: string): TUser;
    procedure UpdateUser(Username: string; Body: TUser);
    procedure DeleteUser(Username: string);
    function LoginUser(Username: string; Password: string): string;
    procedure LogoutUser;
    procedure CreateUser(Body: TUser);
  end;
  
  TService = class(TRestService, IService)
  public
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    procedure UpdatePet(Body: TPet);
    procedure AddPet(Body: TPet);
    function FindPetsByStatus(Status: stringArray): TPetList;
    function FindPetsByTags(Tags: stringArray): TPetList;
    function GetPetById(PetId: Int64): TPet;
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    procedure DeletePet(ApiKey: string; PetId: Int64);
    function PlaceOrder(Body: TOrder): TOrder;
    function GetOrderById(OrderId: Int64): TOrder;
    procedure DeleteOrder(OrderId: Int64);
    function GetInventory: TGetInventoryOutput;
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

{ TService }

function TService.UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
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

procedure TService.UpdatePet(Body: TPet);
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

procedure TService.AddPet(Body: TPet);
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

function TService.FindPetsByStatus(Status: stringArray): TPetList;
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

function TService.FindPetsByTags(Tags: stringArray): TPetList;
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

function TService.GetPetById(PetId: Int64): TPet;
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

procedure TService.UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
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

procedure TService.DeletePet(ApiKey: string; PetId: Int64);
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

function TService.PlaceOrder(Body: TOrder): TOrder;
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

function TService.GetOrderById(OrderId: Int64): TOrder;
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

procedure TService.DeleteOrder(OrderId: Int64);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'DELETE');
  Request.AddUrlParam('orderId', IntToStr(OrderId));
  Response := Request.Execute;
  CheckError(Response);
end;

function TService.GetInventory: TGetInventoryOutput;
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

procedure TService.CreateUsersWithArrayInput(Body: TUserList);
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

procedure TService.CreateUsersWithListInput(Body: TUserList);
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

function TService.GetUserByName(Username: string): TUser;
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

procedure TService.UpdateUser(Username: string; Body: TUser);
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

procedure TService.DeleteUser(Username: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'DELETE');
  Request.AddUrlParam('username', Username);
  Response := Request.Execute;
  CheckError(Response);
end;

function TService.LoginUser(Username: string; Password: string): string;
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

procedure TService.LogoutUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/logout', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TService.CreateUser(Body: TUser);
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
