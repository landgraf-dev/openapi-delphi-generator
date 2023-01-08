unit PetStore3Client;

interface

uses
  SysUtils, 
  OpenApiRest, 
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
    procedure UpdatePet(Body: TPet);
    /// <summary>
    /// Add a new pet to the store
    /// </summary>
    /// <param name="Body">
    /// Create a new pet in the store
    /// </param>
    /// <remarks>
    /// Add a new pet to the store
    /// </remarks>
    procedure AddPet(Body: TPet);
    /// <summary>
    /// Finds Pets by status
    /// </summary>
    /// <param name="Status">
    /// Status values that need to be considered for filter
    /// </param>
    /// <remarks>
    /// Multiple status values can be provided with comma separated strings
    /// </remarks>
    procedure FindPetsByStatus(Status: string);
    /// <summary>
    /// Finds Pets by tags
    /// </summary>
    /// <param name="Tags">
    /// Tags to filter by
    /// </param>
    /// <remarks>
    /// Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    /// </remarks>
    procedure FindPetsByTags(Tags: stringArray);
    /// <summary>
    /// Find pet by ID
    /// </summary>
    /// <param name="PetId">
    /// ID of pet to return
    /// </param>
    /// <remarks>
    /// Returns a single pet
    /// </remarks>
    procedure GetPetById(PetId: Int64);
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
    procedure UpdatePet(Body: TPet);
    /// <param name="Body">
    /// Create a new pet in the store
    /// </param>
    procedure AddPet(Body: TPet);
    /// <param name="Status">
    /// Status values that need to be considered for filter
    /// </param>
    procedure FindPetsByStatus(Status: string);
    /// <param name="Tags">
    /// Tags to filter by
    /// </param>
    procedure FindPetsByTags(Tags: stringArray);
    /// <param name="PetId">
    /// ID of pet to return
    /// </param>
    procedure GetPetById(PetId: Int64);
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
    procedure GetInventory;
    /// <summary>
    /// Place an order for a pet
    /// </summary>
    /// <remarks>
    /// Place a new order in the store
    /// </remarks>
    procedure PlaceOrder(Body: TOrder);
    /// <summary>
    /// Find purchase order by ID
    /// </summary>
    /// <param name="OrderId">
    /// ID of order that needs to be fetched
    /// </param>
    /// <remarks>
    /// For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.
    /// </remarks>
    procedure GetOrderById(OrderId: Int64);
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
    procedure GetInventory;
    procedure PlaceOrder(Body: TOrder);
    /// <param name="OrderId">
    /// ID of order that needs to be fetched
    /// </param>
    procedure GetOrderById(OrderId: Int64);
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
    procedure CreateUser(Body: TUser);
    /// <summary>
    /// Creates list of users with given input array
    /// </summary>
    /// <remarks>
    /// Creates list of users with given input array
    /// </remarks>
    procedure CreateUsersWithListInput(Body: TUserList);
    /// <summary>
    /// Logs user into the system
    /// </summary>
    /// <param name="Username">
    /// The user name for login
    /// </param>
    /// <param name="Password">
    /// The password for login in clear text
    /// </param>
    procedure LoginUser(Username: string; Password: string);
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
    procedure GetUserByName(Username: string);
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
    procedure CreateUser(Body: TUser);
    procedure CreateUsersWithListInput(Body: TUserList);
    /// <param name="Username">
    /// The user name for login
    /// </param>
    /// <param name="Password">
    /// The password for login in clear text
    /// </param>
    procedure LoginUser(Username: string; Password: string);
    procedure LogoutUser;
    /// <param name="Username">
    /// The name that needs to be fetched. Use user1 for testing. 
    /// </param>
    procedure GetUserByName(Username: string);
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

procedure TPetService.UpdatePet(Body: TPet);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'PUT');
  Request.AddBody(Converter.TPetToJson(Body));
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
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.FindPetsByStatus(Status: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByStatus', 'GET');
  Request.AddQueryParam('status', Status);
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.FindPetsByTags(Tags: stringArray);
var
  Request: IRestRequest;
  I: Integer;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByTags', 'GET');
  for I := 0 to Length(Tags) - 1 do
    Request.AddQueryParam('tags', Tags[I]);
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.GetPetById(PetId: Int64);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'GET');
  Request.AddUrlParam('petId', IntToStr(PetId));
  Response := Request.Execute;
  CheckError(Response);
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

procedure TStoreService.GetInventory;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/inventory', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TStoreService.PlaceOrder(Body: TOrder);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order', 'POST');
  Request.AddBody(Converter.TOrderToJson(Body));
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TStoreService.GetOrderById(OrderId: Int64);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'GET');
  Request.AddUrlParam('orderId', IntToStr(OrderId));
  Response := Request.Execute;
  CheckError(Response);
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

procedure TUserService.CreateUser(Body: TUser);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user', 'POST');
  Request.AddBody(Converter.TUserToJson(Body));
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
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.LoginUser(Username: string; Password: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/login', 'GET');
  Request.AddQueryParam('username', Username);
  Request.AddQueryParam('password', Password);
  Response := Request.Execute;
  CheckError(Response);
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

procedure TUserService.GetUserByName(Username: string);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'GET');
  Request.AddUrlParam('username', Username);
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.UpdateUser(Username: string; Body: TUser);
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'PUT');
  Request.AddUrlParam('username', Username);
  Request.AddBody(Converter.TUserToJson(Body));
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
