unit PetStoreClient;

interface

uses
  SysUtils, 
  OpenApiRest, 
  PetStoreJson, 
  PetStoreDtos;

type
  TRestService = class;
  TPetService = class;
  TStoreService = class;
  TUserService = class;
  TPetStoreConfig = class;
  TPetStoreClient = class;
  
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
    /// uploads an image
    /// </summary>
    /// <param name="PetId">
    /// ID of pet to update
    /// </param>
    /// <param name="AdditionalMetadata">
    /// Additional data to pass to server
    /// </param>
    /// <param name="&File">
    /// file to upload
    /// </param>
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    /// <summary>
    /// Update an existing pet
    /// </summary>
    /// <param name="Body">
    /// Pet object that needs to be added to the store
    /// </param>
    procedure UpdatePet(Body: TPet);
    /// <summary>
    /// Add a new pet to the store
    /// </summary>
    /// <param name="Body">
    /// Pet object that needs to be added to the store
    /// </param>
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
    function FindPetsByStatus(Status: stringArray): TPetList;
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
    /// Updated name of the pet
    /// </param>
    /// <param name="Status">
    /// Updated status of the pet
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
    /// <param name="PetId">
    /// ID of pet to update
    /// </param>
    /// <param name="AdditionalMetadata">
    /// Additional data to pass to server
    /// </param>
    /// <param name="&File">
    /// file to upload
    /// </param>
    function UploadFile(PetId: Int64; AdditionalMetadata: string; &File: TBytes): TApiResponse;
    /// <param name="Body">
    /// Pet object that needs to be added to the store
    /// </param>
    procedure UpdatePet(Body: TPet);
    /// <param name="Body">
    /// Pet object that needs to be added to the store
    /// </param>
    procedure AddPet(Body: TPet);
    /// <param name="Status">
    /// Status values that need to be considered for filter
    /// </param>
    function FindPetsByStatus(Status: stringArray): TPetList;
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
    /// Updated name of the pet
    /// </param>
    /// <param name="Status">
    /// Updated status of the pet
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
    /// Place an order for a pet
    /// </summary>
    /// <param name="Body">
    /// order placed for purchasing the pet
    /// </param>
    function PlaceOrder(Body: TOrder): TOrder;
    /// <summary>
    /// Find purchase order by ID
    /// </summary>
    /// <param name="OrderId">
    /// ID of pet that needs to be fetched
    /// </param>
    /// <remarks>
    /// For valid response try integer IDs with value >= 1 and <= 10. Other values will generated exceptions
    /// </remarks>
    function GetOrderById(OrderId: Int64): TOrder;
    /// <summary>
    /// Delete purchase order by ID
    /// </summary>
    /// <param name="OrderId">
    /// ID of the order that needs to be deleted
    /// </param>
    /// <remarks>
    /// For valid response try integer IDs with positive integer value. Negative or non-integer values will generate API errors
    /// </remarks>
    procedure DeleteOrder(OrderId: Int64);
    /// <summary>
    /// Returns pet inventories by status
    /// </summary>
    /// <remarks>
    /// Returns a map of status codes to quantities
    /// </remarks>
    function GetInventory: TGetInventoryOutput;
  end;
  
  TStoreService = class(TRestService, IStoreService)
  public
    /// <param name="Body">
    /// order placed for purchasing the pet
    /// </param>
    function PlaceOrder(Body: TOrder): TOrder;
    /// <param name="OrderId">
    /// ID of pet that needs to be fetched
    /// </param>
    function GetOrderById(OrderId: Int64): TOrder;
    /// <param name="OrderId">
    /// ID of the order that needs to be deleted
    /// </param>
    procedure DeleteOrder(OrderId: Int64);
    function GetInventory: TGetInventoryOutput;
  end;
  
  /// <summary>
  /// Operations about user
  /// </summary>
  IUserService = interface(IInvokable)
    ['{6AF38CCE-1A86-4473-9BC7-CAA13A24F719}']
    /// <summary>
    /// Creates list of users with given input array
    /// </summary>
    /// <param name="Body">
    /// List of user object
    /// </param>
    procedure CreateUsersWithArrayInput(Body: TUserList);
    /// <summary>
    /// Creates list of users with given input array
    /// </summary>
    /// <param name="Body">
    /// List of user object
    /// </param>
    procedure CreateUsersWithListInput(Body: TUserList);
    /// <summary>
    /// Get user by user name
    /// </summary>
    /// <param name="Username">
    /// The name that needs to be fetched. Use user1 for testing. 
    /// </param>
    function GetUserByName(Username: string): TUser;
    /// <summary>
    /// Updated user
    /// </summary>
    /// <param name="Username">
    /// name that need to be updated
    /// </param>
    /// <param name="Body">
    /// Updated user object
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
    /// Create user
    /// </summary>
    /// <param name="Body">
    /// Created user object
    /// </param>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure CreateUser(Body: TUser);
  end;
  
  TUserService = class(TRestService, IUserService)
  public
    /// <param name="Body">
    /// List of user object
    /// </param>
    procedure CreateUsersWithArrayInput(Body: TUserList);
    /// <param name="Body">
    /// List of user object
    /// </param>
    procedure CreateUsersWithListInput(Body: TUserList);
    /// <param name="Username">
    /// The name that needs to be fetched. Use user1 for testing. 
    /// </param>
    function GetUserByName(Username: string): TUser;
    /// <param name="Username">
    /// name that need to be updated
    /// </param>
    /// <param name="Body">
    /// Updated user object
    /// </param>
    procedure UpdateUser(Username: string; Body: TUser);
    /// <param name="Username">
    /// The name that needs to be deleted
    /// </param>
    procedure DeleteUser(Username: string);
    /// <param name="Username">
    /// The user name for login
    /// </param>
    /// <param name="Password">
    /// The password for login in clear text
    /// </param>
    function LoginUser(Username: string; Password: string): string;
    procedure LogoutUser;
    /// <param name="Body">
    /// Created user object
    /// </param>
    procedure CreateUser(Body: TUser);
  end;
  
  TPetStoreConfig = class(TCustomRestConfig)
  public
    constructor Create;
  end;
  
  IPetStoreClient = interface(IRestClient)
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
  
  TPetStoreClient = class(TCustomRestClient, IPetStoreClient)
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

{ TPetStoreConfig }

constructor TPetStoreConfig.Create;
begin
  inherited Create;
  BaseUrl := 'https://petstore.swagger.io/v2';
end;

{ TPetStoreClient }

function TPetStoreClient.Pet: IPetService;
begin
  Result := TPetService.Create(Config);
end;

function TPetStoreClient.Store: IStoreService;
begin
  Result := TStoreService.Create(Config);
end;

function TPetStoreClient.User: IUserService;
begin
  Result := TUserService.Create(Config);
end;

constructor TPetStoreClient.Create;
begin
  inherited Create(TPetStoreConfig.Create);
end;

end.
