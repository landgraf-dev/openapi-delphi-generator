unit PetStore3Client;

interface

uses
  SysUtils, 
  OpenApiRest, 
  OpenApiUtils, 
  PetStore3Json, 
  PetStore3Dtos;

type
  TRestService = class;
  TPetService = class;
  TStoreService = class;
  TUserService = class;
  TPetStore3Config = class;
  TPetStore3Client = class;
  
  TRestService = class(TCustomRestService)
  protected
    function CreateConverter: TCustomJsonConverter; override;
    function Converter: TJsonConverter;
  end;
  
  /// <summary>
  /// Everything about your Pets
  /// </summary>
  IPetService = interface(IInvokable)
    ['{1B571204-1E67-4BF3-A9E9-9C1489E8FF0C}']
    /// <summary>
    /// Update an existing pet
    /// </summary>
    /// <param name="Body">
    /// Update an existent pet in the store
    /// </param>
    /// <remarks>
    /// Update an existing pet by Id
    /// </remarks>
    function UpdatePet(Body: TPet): TPet;
    /// <summary>
    /// Add a new pet to the store
    /// </summary>
    /// <param name="Body">
    /// Create a new pet in the store
    /// </param>
    /// <remarks>
    /// Add a new pet to the store
    /// </remarks>
    function AddPet(Body: TPet): TPet;
    /// <summary>
    /// Finds Pets by status
    /// </summary>
    /// <param name="Status">
    /// Status values that need to be considered for filter
    /// </param>
    /// <remarks>
    /// Multiple status values can be provided with comma separated strings
    /// </remarks>
    function FindPetsByStatus(Status: string): TPetList;
    /// <summary>
    /// Finds Pets by tags
    /// </summary>
    /// <param name="Tags">
    /// Tags to filter by
    /// </param>
    /// <remarks>
    /// Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    /// </remarks>
    function FindPetsByTags(Tags: stringArray): TPetList;
    /// <summary>
    /// Find pet by ID
    /// </summary>
    /// <param name="PetId">
    /// ID of pet to return
    /// </param>
    /// <remarks>
    /// Returns a single pet
    /// </remarks>
    function GetPetById(PetId: Int64): TPet;
    /// <summary>
    /// Updates a pet in the store with form data
    /// </summary>
    /// <param name="PetId">
    /// ID of pet that needs to be updated
    /// </param>
    /// <param name="Name">
    /// Name of pet that needs to be updated
    /// </param>
    /// <param name="Status">
    /// Status of pet that needs to be updated
    /// </param>
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    /// <summary>
    /// Deletes a pet
    /// </summary>
    /// <param name="PetId">
    /// Pet id to delete
    /// </param>
    procedure DeletePet(ApiKey: string; PetId: Int64);
  end;
  
  TPetService = class(TRestService, IPetService)
  public
    /// <param name="Body">
    /// Update an existent pet in the store
    /// </param>
    function UpdatePet(Body: TPet): TPet;
    /// <param name="Body">
    /// Create a new pet in the store
    /// </param>
    function AddPet(Body: TPet): TPet;
    /// <param name="Status">
    /// Status values that need to be considered for filter
    /// </param>
    function FindPetsByStatus(Status: string): TPetList;
    /// <param name="Tags">
    /// Tags to filter by
    /// </param>
    function FindPetsByTags(Tags: stringArray): TPetList;
    /// <param name="PetId">
    /// ID of pet to return
    /// </param>
    function GetPetById(PetId: Int64): TPet;
    /// <param name="PetId">
    /// ID of pet that needs to be updated
    /// </param>
    /// <param name="Name">
    /// Name of pet that needs to be updated
    /// </param>
    /// <param name="Status">
    /// Status of pet that needs to be updated
    /// </param>
    procedure UpdatePetWithForm(PetId: Int64; Name: string; Status: string);
    /// <param name="PetId">
    /// Pet id to delete
    /// </param>
    procedure DeletePet(ApiKey: string; PetId: Int64);
  end;
  
  /// <summary>
  /// Access to Petstore orders
  /// </summary>
  IStoreService = interface(IInvokable)
    ['{7C716BC0-88A7-431F-9232-5CA18E91B492}']
    /// <summary>
    /// Returns pet inventories by status
    /// </summary>
    /// <remarks>
    /// Returns a map of status codes to quantities
    /// </remarks>
    function GetInventory: TGetInventoryOutput;
    /// <summary>
    /// Place an order for a pet
    /// </summary>
    /// <remarks>
    /// Place a new order in the store
    /// </remarks>
    function PlaceOrder(Body: TOrder): TOrder;
    /// <summary>
    /// Find purchase order by ID
    /// </summary>
    /// <param name="OrderId">
    /// ID of order that needs to be fetched
    /// </param>
    /// <remarks>
    /// For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.
    /// </remarks>
    function GetOrderById(OrderId: Int64): TOrder;
    /// <summary>
    /// Delete purchase order by ID
    /// </summary>
    /// <param name="OrderId">
    /// ID of the order that needs to be deleted
    /// </param>
    /// <remarks>
    /// For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors
    /// </remarks>
    procedure DeleteOrder(OrderId: Int64);
  end;
  
  TStoreService = class(TRestService, IStoreService)
  public
    function GetInventory: TGetInventoryOutput;
    function PlaceOrder(Body: TOrder): TOrder;
    /// <param name="OrderId">
    /// ID of order that needs to be fetched
    /// </param>
    function GetOrderById(OrderId: Int64): TOrder;
    /// <param name="OrderId">
    /// ID of the order that needs to be deleted
    /// </param>
    procedure DeleteOrder(OrderId: Int64);
  end;
  
  /// <summary>
  /// Operations about user
  /// </summary>
  IUserService = interface(IInvokable)
    ['{6AF38CCE-1A86-4473-9BC7-CAA13A24F719}']
    /// <summary>
    /// Create user
    /// </summary>
    /// <param name="Body">
    /// Created user object
    /// </param>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    function CreateUser(Body: TUser): TUser;
    /// <summary>
    /// Creates list of users with given input array
    /// </summary>
    /// <remarks>
    /// Creates list of users with given input array
    /// </remarks>
    function CreateUsersWithListInput(Body: TUserList): TUser;
    /// <summary>
    /// Logs user into the system
    /// </summary>
    /// <param name="Username">
    /// The user name for login
    /// </param>
    /// <param name="Password">
    /// The password for login in clear text
    /// </param>
    function LoginUser(Username: string; Password: string): string;
    /// <summary>
    /// Logs out current logged in user session
    /// </summary>
    procedure LogoutUser;
    /// <summary>
    /// Get user by user name
    /// </summary>
    /// <param name="Username">
    /// The name that needs to be fetched. Use user1 for testing. 
    /// </param>
    function GetUserByName(Username: string): TUser;
    /// <summary>
    /// Update user
    /// </summary>
    /// <param name="Username">
    /// name that need to be deleted
    /// </param>
    /// <param name="Body">
    /// Update an existent user in the store
    /// </param>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure UpdateUser(Username: string; Body: TUser);
    /// <summary>
    /// Delete user
    /// </summary>
    /// <param name="Username">
    /// The name that needs to be deleted
    /// </param>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure DeleteUser(Username: string);
  end;
  
  TUserService = class(TRestService, IUserService)
  public
    /// <param name="Body">
    /// Created user object
    /// </param>
    function CreateUser(Body: TUser): TUser;
    function CreateUsersWithListInput(Body: TUserList): TUser;
    /// <param name="Username">
    /// The user name for login
    /// </param>
    /// <param name="Password">
    /// The password for login in clear text
    /// </param>
    function LoginUser(Username: string; Password: string): string;
    procedure LogoutUser;
    /// <param name="Username">
    /// The name that needs to be fetched. Use user1 for testing. 
    /// </param>
    function GetUserByName(Username: string): TUser;
    /// <param name="Username">
    /// name that need to be deleted
    /// </param>
    /// <param name="Body">
    /// Update an existent user in the store
    /// </param>
    procedure UpdateUser(Username: string; Body: TUser);
    /// <param name="Username">
    /// The name that needs to be deleted
    /// </param>
    procedure DeleteUser(Username: string);
  end;
  
  TPetStore3Config = class(TCustomRestConfig)
  public
    constructor Create;
  end;
  
  IPetStore3Client = interface(IRestClient)
    /// <summary>
    /// Everything about your Pets
    /// </summary>
    function Pet: IPetService;
    /// <summary>
    /// Access to Petstore orders
    /// </summary>
    function Store: IStoreService;
    /// <summary>
    /// Operations about user
    /// </summary>
    function User: IUserService;
  end;
  
  TPetStore3Client = class(TCustomRestClient, IPetStore3Client)
  public
    function Pet: IPetService;
    function Store: IStoreService;
    function User: IUserService;
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

{ TPetService }

function TPetService.UpdatePet(Body: TPet): TPet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'PUT');
  Request.AddBody(Converter.TPetToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TPetFromJson(Response.ContentAsString);
end;

function TPetService.AddPet(Body: TPet): TPet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'POST');
  Request.AddBody(Converter.TPetToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TPetFromJson(Response.ContentAsString);
end;

function TPetService.FindPetsByStatus(Status: string): TPetList;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByStatus', 'GET');
  Request.AddQueryParam('status', Status);
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
  Request.AddQueryParam('name', Name);
  Request.AddQueryParam('status', Status);
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

{ TUserService }

function TUserService.CreateUser(Body: TUser): TUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user', 'POST');
  Request.AddBody(Converter.TUserToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TUserFromJson(Response.ContentAsString);
end;

function TUserService.CreateUsersWithListInput(Body: TUserList): TUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/createWithList', 'POST');
  Request.AddBody(Converter.TUserListToJson(Body));
  Request.AddHeader('Content-Type', 'application/json');
  Request.AddHeader('Accept', 'application/json');
  Response := Request.Execute;
  CheckError(Response);
  Result := Converter.TUserFromJson(Response.ContentAsString);
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

{ TPetStore3Config }

constructor TPetStore3Config.Create;
begin
  inherited Create;
  BaseUrl := 'https://petstore3.swagger.io/api/v3';
end;

{ TPetStore3Client }

function TPetStore3Client.Pet: IPetService;
begin
  Result := TPetService.Create(Config);
end;

function TPetStore3Client.Store: IStoreService;
begin
  Result := TStoreService.Create(Config);
end;

function TPetStore3Client.User: IUserService;
begin
  Result := TUserService.Create(Config);
end;

constructor TPetStore3Client.Create;
begin
  inherited Create(TPetStore3Config.Create);
end;

end.
