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
    /// <remarks>
    /// Update an existing pet by Id
    /// </remarks>
    procedure UpdatePet;
    /// <summary>
    /// Add a new pet to the store
    /// </summary>
    /// <remarks>
    /// Add a new pet to the store
    /// </remarks>
    procedure AddPet;
    /// <summary>
    /// Finds Pets by status
    /// </summary>
    /// <remarks>
    /// Multiple status values can be provided with comma separated strings
    /// </remarks>
    procedure FindPetsByStatus;
    /// <summary>
    /// Finds Pets by tags
    /// </summary>
    /// <remarks>
    /// Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    /// </remarks>
    procedure FindPetsByTags;
    /// <summary>
    /// Find pet by ID
    /// </summary>
    /// <remarks>
    /// Returns a single pet
    /// </remarks>
    procedure GetPetById;
    /// <summary>
    /// Updates a pet in the store with form data
    /// </summary>
    procedure UpdatePetWithForm;
    /// <summary>
    /// Deletes a pet
    /// </summary>
    procedure DeletePet;
    /// <summary>
    /// uploads an image
    /// </summary>
    procedure UploadFile;
  end;
  
  TPetService = class(TRestService, IPetService)
  public
    procedure UpdatePet;
    procedure AddPet;
    procedure FindPetsByStatus;
    procedure FindPetsByTags;
    procedure GetPetById;
    procedure UpdatePetWithForm;
    procedure DeletePet;
    procedure UploadFile;
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
    procedure PlaceOrder;
    /// <summary>
    /// Find purchase order by ID
    /// </summary>
    /// <remarks>
    /// For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.
    /// </remarks>
    procedure GetOrderById;
    /// <summary>
    /// Delete purchase order by ID
    /// </summary>
    /// <remarks>
    /// For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors
    /// </remarks>
    procedure DeleteOrder;
  end;
  
  TStoreService = class(TRestService, IStoreService)
  public
    procedure GetInventory;
    procedure PlaceOrder;
    procedure GetOrderById;
    procedure DeleteOrder;
  end;
  
  /// <summary>
  /// Operations about user
  /// </summary>
  IUserService = interface(IInvokable)
    ['{6AF38CCE-1A86-4473-9BC7-CAA13A24F719}']
    /// <summary>
    /// Create user
    /// </summary>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure CreateUser;
    /// <summary>
    /// Creates list of users with given input array
    /// </summary>
    /// <remarks>
    /// Creates list of users with given input array
    /// </remarks>
    procedure CreateUsersWithListInput;
    /// <summary>
    /// Logs user into the system
    /// </summary>
    procedure LoginUser;
    /// <summary>
    /// Logs out current logged in user session
    /// </summary>
    procedure LogoutUser;
    /// <summary>
    /// Get user by user name
    /// </summary>
    procedure GetUserByName;
    /// <summary>
    /// Update user
    /// </summary>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure UpdateUser;
    /// <summary>
    /// Delete user
    /// </summary>
    /// <remarks>
    /// This can only be done by the logged in user.
    /// </remarks>
    procedure DeleteUser;
  end;
  
  TUserService = class(TRestService, IUserService)
  public
    procedure CreateUser;
    procedure CreateUsersWithListInput;
    procedure LoginUser;
    procedure LogoutUser;
    procedure GetUserByName;
    procedure UpdateUser;
    procedure DeleteUser;
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

procedure TPetService.UpdatePet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'PUT');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.AddPet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet', 'POST');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.FindPetsByStatus;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByStatus', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.FindPetsByTags;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/findByTags', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.GetPetById;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.UpdatePetWithForm;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'POST');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.DeletePet;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}', 'DELETE');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TPetService.UploadFile;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/pet/{petId}/uploadImage', 'POST');
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

procedure TStoreService.PlaceOrder;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order', 'POST');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TStoreService.GetOrderById;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TStoreService.DeleteOrder;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/store/order/{orderId}', 'DELETE');
  Response := Request.Execute;
  CheckError(Response);
end;

{ TUserService }

procedure TUserService.CreateUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user', 'POST');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.CreateUsersWithListInput;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/createWithList', 'POST');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.LoginUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/login', 'GET');
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

procedure TUserService.GetUserByName;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'GET');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.UpdateUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'PUT');
  Response := Request.Execute;
  CheckError(Response);
end;

procedure TUserService.DeleteUser;
var
  Request: IRestRequest;
  Response: IRestResponse;
begin
  Request := CreateRequest('/user/{username}', 'DELETE');
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
