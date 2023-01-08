unit PetStore3Json;

interface

uses
  OpenApiJson, 
  PetStore3Dtos;

type
  TJsonConverter = class;
  
  TJsonConverter = class(TCustomJsonConverter)
  public
    function TOrderToJsonValue(Source: TOrder): TJSONValue;
    function TOrderToJson(Source: TOrder): string;
    function TOrderFromJsonValue(Source: TJSONValue): TOrder;
    function TOrderFromJson(Source: string): TOrder;
    function TAddressToJsonValue(Source: TAddress): TJSONValue;
    function TAddressToJson(Source: TAddress): string;
    function TAddressFromJsonValue(Source: TJSONValue): TAddress;
    function TAddressFromJson(Source: string): TAddress;
    function TAddressListToJsonValue(Source: TAddressList): TJSONValue;
    function TAddressListToJson(Source: TAddressList): string;
    function TAddressListFromJsonValue(Source: TJSONValue): TAddressList;
    function TAddressListFromJson(Source: string): TAddressList;
    function TCustomerToJsonValue(Source: TCustomer): TJSONValue;
    function TCustomerToJson(Source: TCustomer): string;
    function TCustomerFromJsonValue(Source: TJSONValue): TCustomer;
    function TCustomerFromJson(Source: string): TCustomer;
    function TCategoryToJsonValue(Source: TCategory): TJSONValue;
    function TCategoryToJson(Source: TCategory): string;
    function TCategoryFromJsonValue(Source: TJSONValue): TCategory;
    function TCategoryFromJson(Source: string): TCategory;
    function TUserToJsonValue(Source: TUser): TJSONValue;
    function TUserToJson(Source: TUser): string;
    function TUserFromJsonValue(Source: TJSONValue): TUser;
    function TUserFromJson(Source: string): TUser;
    function TTagToJsonValue(Source: TTag): TJSONValue;
    function TTagToJson(Source: TTag): string;
    function TTagFromJsonValue(Source: TJSONValue): TTag;
    function TTagFromJson(Source: string): TTag;
    function stringListToJsonValue(Source: stringList): TJSONValue;
    function stringListToJson(Source: stringList): string;
    function stringListFromJsonValue(Source: TJSONValue): stringList;
    function stringListFromJson(Source: string): stringList;
    function TTagListToJsonValue(Source: TTagList): TJSONValue;
    function TTagListToJson(Source: TTagList): string;
    function TTagListFromJsonValue(Source: TJSONValue): TTagList;
    function TTagListFromJson(Source: string): TTagList;
    function TPetToJsonValue(Source: TPet): TJSONValue;
    function TPetToJson(Source: TPet): string;
    function TPetFromJsonValue(Source: TJSONValue): TPet;
    function TPetFromJson(Source: string): TPet;
    function TApiResponseToJsonValue(Source: TApiResponse): TJSONValue;
    function TApiResponseToJson(Source: TApiResponse): string;
    function TApiResponseFromJsonValue(Source: TJSONValue): TApiResponse;
    function TApiResponseFromJson(Source: string): TApiResponse;
    function TPetListToJsonValue(Source: TPetList): TJSONValue;
    function TPetListToJson(Source: TPetList): string;
    function TPetListFromJsonValue(Source: TJSONValue): TPetList;
    function TPetListFromJson(Source: string): TPetList;
    function stringArrayToJsonValue(Source: stringArray): TJSONValue;
    function stringArrayToJson(Source: stringArray): string;
    function stringArrayFromJsonValue(Source: TJSONValue): stringArray;
    function stringArrayFromJson(Source: string): stringArray;
    function TGetInventoryOutputToJsonValue(Source: TGetInventoryOutput): TJSONValue;
    function TGetInventoryOutputToJson(Source: TGetInventoryOutput): string;
    function TGetInventoryOutputFromJsonValue(Source: TJSONValue): TGetInventoryOutput;
    function TGetInventoryOutputFromJson(Source: string): TGetInventoryOutput;
    function TUserListToJsonValue(Source: TUserList): TJSONValue;
    function TUserListToJson(Source: TUserList): string;
    function TUserListFromJsonValue(Source: TJSONValue): TUserList;
    function TUserListFromJson(Source: string): TUserList;
  end;
  
implementation

{ TJsonConverter }

function TJsonConverter.TOrderToJsonValue(Source: TOrder): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    if Source.PetIdHasValue then
      Json.ObjAddProp(Result, 'petId', Self.Int64ToJsonValue(Source.PetId));
    if Source.QuantityHasValue then
      Json.ObjAddProp(Result, 'quantity', Self.IntegerToJsonValue(Source.Quantity));
    if Source.ShipDateHasValue then
      Json.ObjAddProp(Result, 'shipDate', Self.TDateTimeToJsonValue(Source.ShipDate));
    if Source.StatusHasValue then
      Json.ObjAddProp(Result, 'status', Self.stringToJsonValue(Source.Status));
    if Source.CompleteHasValue then
      Json.ObjAddProp(Result, 'complete', Self.BooleanToJsonValue(Source.Complete));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TOrderToJson(Source: TOrder): string;
var
  JValue: TJSONValue;
begin
  JValue := TOrderToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TOrderFromJsonValue(Source: TJSONValue): TOrder;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TOrder.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'petId', JValue) then
      Result.PetId := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'quantity', JValue) then
      Result.Quantity := Self.IntegerFromJsonValue(JValue);
    if Json.ObjContains(Source, 'shipDate', JValue) then
      Result.ShipDate := Self.TDateTimeFromJsonValue(JValue);
    if Json.ObjContains(Source, 'status', JValue) then
      Result.Status := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'complete', JValue) then
      Result.Complete := Self.BooleanFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TOrderFromJson(Source: string): TOrder;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TOrderFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TAddressToJsonValue(Source: TAddress): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.StreetHasValue then
      Json.ObjAddProp(Result, 'street', Self.stringToJsonValue(Source.Street));
    if Source.CityHasValue then
      Json.ObjAddProp(Result, 'city', Self.stringToJsonValue(Source.City));
    if Source.StateHasValue then
      Json.ObjAddProp(Result, 'state', Self.stringToJsonValue(Source.State));
    if Source.ZipHasValue then
      Json.ObjAddProp(Result, 'zip', Self.stringToJsonValue(Source.Zip));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TAddressToJson(Source: TAddress): string;
var
  JValue: TJSONValue;
begin
  JValue := TAddressToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TAddressFromJsonValue(Source: TJSONValue): TAddress;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TAddress.Create;
  try
    if Json.ObjContains(Source, 'street', JValue) then
      Result.Street := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'city', JValue) then
      Result.City := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'state', JValue) then
      Result.State := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'zip', JValue) then
      Result.Zip := Self.stringFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TAddressFromJson(Source: string): TAddress;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TAddressFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TAddressListToJsonValue(Source: TAddressList): TJSONValue;
var
  Index: Integer;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateArray;
  try
    for Index := 0 to Source.Count - 1 do
      Json.ArrayAdd(Result, Self.TAddressToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TAddressListToJson(Source: TAddressList): string;
var
  JValue: TJSONValue;
begin
  JValue := TAddressListToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TAddressListFromJsonValue(Source: TJSONValue): TAddressList;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TAddressList.Create;
  try
    for Index := 0 to Json.ArrayLength(Source) - 1 do
      Result.Add(Self.TAddressFromJsonValue(Json.ArrayGet(Source, Index)));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TAddressListFromJson(Source: string): TAddressList;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TAddressListFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TCustomerToJsonValue(Source: TCustomer): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    if Source.UsernameHasValue then
      Json.ObjAddProp(Result, 'username', Self.stringToJsonValue(Source.Username));
    if Assigned(Source.Address) then
      Json.ObjAddProp(Result, 'address', Self.TAddressListToJsonValue(Source.Address));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TCustomerToJson(Source: TCustomer): string;
var
  JValue: TJSONValue;
begin
  JValue := TCustomerToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TCustomerFromJsonValue(Source: TJSONValue): TCustomer;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TCustomer.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'username', JValue) then
      Result.Username := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'address', JValue) then
      Result.Address := Self.TAddressListFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TCustomerFromJson(Source: string): TCustomer;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TCustomerFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TCategoryToJsonValue(Source: TCategory): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    if Source.NameHasValue then
      Json.ObjAddProp(Result, 'name', Self.stringToJsonValue(Source.Name));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TCategoryToJson(Source: TCategory): string;
var
  JValue: TJSONValue;
begin
  JValue := TCategoryToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TCategoryFromJsonValue(Source: TJSONValue): TCategory;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TCategory.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'name', JValue) then
      Result.Name := Self.stringFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TCategoryFromJson(Source: string): TCategory;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TCategoryFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TUserToJsonValue(Source: TUser): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    if Source.UsernameHasValue then
      Json.ObjAddProp(Result, 'username', Self.stringToJsonValue(Source.Username));
    if Source.FirstNameHasValue then
      Json.ObjAddProp(Result, 'firstName', Self.stringToJsonValue(Source.FirstName));
    if Source.LastNameHasValue then
      Json.ObjAddProp(Result, 'lastName', Self.stringToJsonValue(Source.LastName));
    if Source.EmailHasValue then
      Json.ObjAddProp(Result, 'email', Self.stringToJsonValue(Source.Email));
    if Source.PasswordHasValue then
      Json.ObjAddProp(Result, 'password', Self.stringToJsonValue(Source.Password));
    if Source.PhoneHasValue then
      Json.ObjAddProp(Result, 'phone', Self.stringToJsonValue(Source.Phone));
    if Source.UserStatusHasValue then
      Json.ObjAddProp(Result, 'userStatus', Self.IntegerToJsonValue(Source.UserStatus));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TUserToJson(Source: TUser): string;
var
  JValue: TJSONValue;
begin
  JValue := TUserToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TUserFromJsonValue(Source: TJSONValue): TUser;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TUser.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'username', JValue) then
      Result.Username := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'firstName', JValue) then
      Result.FirstName := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'lastName', JValue) then
      Result.LastName := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'email', JValue) then
      Result.Email := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'password', JValue) then
      Result.Password := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'phone', JValue) then
      Result.Phone := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'userStatus', JValue) then
      Result.UserStatus := Self.IntegerFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TUserFromJson(Source: string): TUser;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TUserFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TTagToJsonValue(Source: TTag): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    if Source.NameHasValue then
      Json.ObjAddProp(Result, 'name', Self.stringToJsonValue(Source.Name));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TTagToJson(Source: TTag): string;
var
  JValue: TJSONValue;
begin
  JValue := TTagToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TTagFromJsonValue(Source: TJSONValue): TTag;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TTag.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'name', JValue) then
      Result.Name := Self.stringFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TTagFromJson(Source: string): TTag;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TTagFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.stringListToJsonValue(Source: stringList): TJSONValue;
var
  Index: Integer;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateArray;
  try
    for Index := 0 to Source.Count - 1 do
      Json.ArrayAdd(Result, Self.stringToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.stringListToJson(Source: stringList): string;
var
  JValue: TJSONValue;
begin
  JValue := stringListToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.stringListFromJsonValue(Source: TJSONValue): stringList;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := stringList.Create;
  try
    for Index := 0 to Json.ArrayLength(Source) - 1 do
      Result.Add(Self.stringFromJsonValue(Json.ArrayGet(Source, Index)));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.stringListFromJson(Source: string): stringList;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := stringListFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TTagListToJsonValue(Source: TTagList): TJSONValue;
var
  Index: Integer;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateArray;
  try
    for Index := 0 to Source.Count - 1 do
      Json.ArrayAdd(Result, Self.TTagToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TTagListToJson(Source: TTagList): string;
var
  JValue: TJSONValue;
begin
  JValue := TTagListToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TTagListFromJsonValue(Source: TJSONValue): TTagList;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TTagList.Create;
  try
    for Index := 0 to Json.ArrayLength(Source) - 1 do
      Result.Add(Self.TTagFromJsonValue(Json.ArrayGet(Source, Index)));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TTagListFromJson(Source: string): TTagList;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TTagListFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TPetToJsonValue(Source: TPet): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.IdHasValue then
      Json.ObjAddProp(Result, 'id', Self.Int64ToJsonValue(Source.Id));
    Json.ObjAddProp(Result, 'name', Self.stringToJsonValue(Source.Name));
    if Assigned(Source.Category) then
      Json.ObjAddProp(Result, 'category', Self.TCategoryToJsonValue(Source.Category));
    Json.ObjAddProp(Result, 'photoUrls', Self.stringListToJsonValue(Source.PhotoUrls));
    if Assigned(Source.Tags) then
      Json.ObjAddProp(Result, 'tags', Self.TTagListToJsonValue(Source.Tags));
    if Source.StatusHasValue then
      Json.ObjAddProp(Result, 'status', Self.stringToJsonValue(Source.Status));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TPetToJson(Source: TPet): string;
var
  JValue: TJSONValue;
begin
  JValue := TPetToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TPetFromJsonValue(Source: TJSONValue): TPet;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TPet.Create;
  try
    if Json.ObjContains(Source, 'id', JValue) then
      Result.Id := Self.Int64FromJsonValue(JValue);
    if Json.ObjContains(Source, 'name', JValue) then
      Result.Name := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'category', JValue) then
      Result.Category := Self.TCategoryFromJsonValue(JValue);
    if Json.ObjContains(Source, 'photoUrls', JValue) then
      Result.PhotoUrls := Self.stringListFromJsonValue(JValue);
    if Json.ObjContains(Source, 'tags', JValue) then
      Result.Tags := Self.TTagListFromJsonValue(JValue);
    if Json.ObjContains(Source, 'status', JValue) then
      Result.Status := Self.stringFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TPetFromJson(Source: string): TPet;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TPetFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TApiResponseToJsonValue(Source: TApiResponse): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
    if Source.CodeHasValue then
      Json.ObjAddProp(Result, 'code', Self.IntegerToJsonValue(Source.Code));
    if Source.&TypeHasValue then
      Json.ObjAddProp(Result, 'type', Self.stringToJsonValue(Source.&Type));
    if Source.MessageHasValue then
      Json.ObjAddProp(Result, 'message', Self.stringToJsonValue(Source.Message));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TApiResponseToJson(Source: TApiResponse): string;
var
  JValue: TJSONValue;
begin
  JValue := TApiResponseToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TApiResponseFromJsonValue(Source: TJSONValue): TApiResponse;
var
  JValue: TJSONValue;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TApiResponse.Create;
  try
    if Json.ObjContains(Source, 'code', JValue) then
      Result.Code := Self.IntegerFromJsonValue(JValue);
    if Json.ObjContains(Source, 'type', JValue) then
      Result.&Type := Self.stringFromJsonValue(JValue);
    if Json.ObjContains(Source, 'message', JValue) then
      Result.Message := Self.stringFromJsonValue(JValue);
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TApiResponseFromJson(Source: string): TApiResponse;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TApiResponseFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TPetListToJsonValue(Source: TPetList): TJSONValue;
var
  Index: Integer;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateArray;
  try
    for Index := 0 to Source.Count - 1 do
      Json.ArrayAdd(Result, Self.TPetToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TPetListToJson(Source: TPetList): string;
var
  JValue: TJSONValue;
begin
  JValue := TPetListToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TPetListFromJsonValue(Source: TJSONValue): TPetList;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TPetList.Create;
  try
    for Index := 0 to Json.ArrayLength(Source) - 1 do
      Result.Add(Self.TPetFromJsonValue(Json.ArrayGet(Source, Index)));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TPetListFromJson(Source: string): TPetList;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TPetListFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.stringArrayToJsonValue(Source: stringArray): TJSONValue;
var
  Index: Integer;
begin
  Result := Json.CreateArray;
  try
    for Index := 0 to Length(Source) - 1 do
      Json.ArrayAdd(Result, Self.stringToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.stringArrayToJson(Source: stringArray): string;
var
  JValue: TJSONValue;
begin
  JValue := stringArrayToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.stringArrayFromJsonValue(Source: TJSONValue): stringArray;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  SetLength(Result, Json.ArrayLength(Source));
  for Index := 0 to Json.ArrayLength(Source) - 1 do
    Result[Index] := Self.stringFromJsonValue(Json.ArrayGet(Source, Index));
end;

function TJsonConverter.stringArrayFromJson(Source: string): stringArray;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := stringArrayFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TGetInventoryOutputToJsonValue(Source: TGetInventoryOutput): TJSONValue;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateObject;
  try
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TGetInventoryOutputToJson(Source: TGetInventoryOutput): string;
var
  JValue: TJSONValue;
begin
  JValue := TGetInventoryOutputToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TGetInventoryOutputFromJsonValue(Source: TJSONValue): TGetInventoryOutput;
begin
  if not Json.IsObject(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGetInventoryOutput.Create;
  try
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TGetInventoryOutputFromJson(Source: string): TGetInventoryOutput;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TGetInventoryOutputFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TUserListToJsonValue(Source: TUserList): TJSONValue;
var
  Index: Integer;
begin
  if not Assigned(Source) then
  begin
    Result := Json.CreateNull;
    Exit;
  end;
  Result := Json.CreateArray;
  try
    for Index := 0 to Source.Count - 1 do
      Json.ArrayAdd(Result, Self.TUserToJsonValue(Source[Index]));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TUserListToJson(Source: TUserList): string;
var
  JValue: TJSONValue;
begin
  JValue := TUserListToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TJsonConverter.TUserListFromJsonValue(Source: TJSONValue): TUserList;
var
  Index: Integer;
begin
  if not Json.IsArray(Source) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TUserList.Create;
  try
    for Index := 0 to Json.ArrayLength(Source) - 1 do
      Result.Add(Self.TUserFromJsonValue(Json.ArrayGet(Source, Index)));
  except
    Result.Free;
    raise;
  end;
end;

function TJsonConverter.TUserListFromJson(Source: string): TUserList;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TUserListFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

end.
