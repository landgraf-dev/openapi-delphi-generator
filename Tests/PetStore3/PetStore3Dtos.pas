unit PetStore3Dtos;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  Generics.Collections, 
  SysUtils;

type
  stringArray = array of string;
  
  TOrder = class;
  TAddress = class;
  TAddressList = class;
  TCustomer = class;
  TCategory = class;
  TUser = class;
  TTag = class;
  stringList = class;
  TTagList = class;
  TPet = class;
  TApiResponse = class;
  TPetList = class;
  TGetInventoryOutput = class;
  TUserList = class;
  
  TOrder = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FPetId: Int64;
    FPetIdHasValue: Boolean;
    FQuantity: Integer;
    FQuantityHasValue: Boolean;
    FShipDate: TDateTime;
    FShipDateHasValue: Boolean;
    FStatus: string;
    FStatusHasValue: Boolean;
    FComplete: Boolean;
    FCompleteHasValue: Boolean;
    procedure SetId(const Value: Int64);
    procedure SetPetId(const Value: Int64);
    procedure SetQuantity(const Value: Integer);
    procedure SetShipDate(const Value: TDateTime);
    procedure SetStatus(const Value: string);
    procedure SetComplete(const Value: Boolean);
  public
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property PetId: Int64 read FPetId write SetPetId;
    property PetIdHasValue: Boolean read FPetIdHasValue write FPetIdHasValue;
    property Quantity: Integer read FQuantity write SetQuantity;
    property QuantityHasValue: Boolean read FQuantityHasValue write FQuantityHasValue;
    property ShipDate: TDateTime read FShipDate write SetShipDate;
    property ShipDateHasValue: Boolean read FShipDateHasValue write FShipDateHasValue;
    /// <summary>
    /// Order Status
    /// </summary>
    property Status: string read FStatus write SetStatus;
    property StatusHasValue: Boolean read FStatusHasValue write FStatusHasValue;
    property Complete: Boolean read FComplete write SetComplete;
    property CompleteHasValue: Boolean read FCompleteHasValue write FCompleteHasValue;
  end;
  
  TAddress = class
  private
    FStreet: string;
    FStreetHasValue: Boolean;
    FCity: string;
    FCityHasValue: Boolean;
    FState: string;
    FStateHasValue: Boolean;
    FZip: string;
    FZipHasValue: Boolean;
    procedure SetStreet(const Value: string);
    procedure SetCity(const Value: string);
    procedure SetState(const Value: string);
    procedure SetZip(const Value: string);
  public
    property Street: string read FStreet write SetStreet;
    property StreetHasValue: Boolean read FStreetHasValue write FStreetHasValue;
    property City: string read FCity write SetCity;
    property CityHasValue: Boolean read FCityHasValue write FCityHasValue;
    property State: string read FState write SetState;
    property StateHasValue: Boolean read FStateHasValue write FStateHasValue;
    property Zip: string read FZip write SetZip;
    property ZipHasValue: Boolean read FZipHasValue write FZipHasValue;
  end;
  
  TAddressList = class(TObjectList<TAddress>)
  end;
  
  TCustomer = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FUsername: string;
    FUsernameHasValue: Boolean;
    FAddress: TAddressList;
    procedure SetId(const Value: Int64);
    procedure SetUsername(const Value: string);
    procedure SetAddress(const Value: TAddressList);
  public
    destructor Destroy; override;
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property Username: string read FUsername write SetUsername;
    property UsernameHasValue: Boolean read FUsernameHasValue write FUsernameHasValue;
    property Address: TAddressList read FAddress write SetAddress;
  end;
  
  TCategory = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FName: string;
    FNameHasValue: Boolean;
    procedure SetId(const Value: Int64);
    procedure SetName(const Value: string);
  public
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property Name: string read FName write SetName;
    property NameHasValue: Boolean read FNameHasValue write FNameHasValue;
  end;
  
  TUser = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FUsername: string;
    FUsernameHasValue: Boolean;
    FFirstName: string;
    FFirstNameHasValue: Boolean;
    FLastName: string;
    FLastNameHasValue: Boolean;
    FEmail: string;
    FEmailHasValue: Boolean;
    FPassword: string;
    FPasswordHasValue: Boolean;
    FPhone: string;
    FPhoneHasValue: Boolean;
    FUserStatus: Integer;
    FUserStatusHasValue: Boolean;
    procedure SetId(const Value: Int64);
    procedure SetUsername(const Value: string);
    procedure SetFirstName(const Value: string);
    procedure SetLastName(const Value: string);
    procedure SetEmail(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetPhone(const Value: string);
    procedure SetUserStatus(const Value: Integer);
  public
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property Username: string read FUsername write SetUsername;
    property UsernameHasValue: Boolean read FUsernameHasValue write FUsernameHasValue;
    property FirstName: string read FFirstName write SetFirstName;
    property FirstNameHasValue: Boolean read FFirstNameHasValue write FFirstNameHasValue;
    property LastName: string read FLastName write SetLastName;
    property LastNameHasValue: Boolean read FLastNameHasValue write FLastNameHasValue;
    property Email: string read FEmail write SetEmail;
    property EmailHasValue: Boolean read FEmailHasValue write FEmailHasValue;
    property Password: string read FPassword write SetPassword;
    property PasswordHasValue: Boolean read FPasswordHasValue write FPasswordHasValue;
    property Phone: string read FPhone write SetPhone;
    property PhoneHasValue: Boolean read FPhoneHasValue write FPhoneHasValue;
    /// <summary>
    /// User Status
    /// </summary>
    property UserStatus: Integer read FUserStatus write SetUserStatus;
    property UserStatusHasValue: Boolean read FUserStatusHasValue write FUserStatusHasValue;
  end;
  
  TTag = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FName: string;
    FNameHasValue: Boolean;
    procedure SetId(const Value: Int64);
    procedure SetName(const Value: string);
  public
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property Name: string read FName write SetName;
    property NameHasValue: Boolean read FNameHasValue write FNameHasValue;
  end;
  
  stringList = class(TList<string>)
  end;
  
  TTagList = class(TObjectList<TTag>)
  end;
  
  TPet = class
  private
    FId: Int64;
    FIdHasValue: Boolean;
    FName: string;
    FCategory: TCategory;
    FPhotoUrls: stringList;
    FTags: TTagList;
    FStatus: string;
    FStatusHasValue: Boolean;
    procedure SetId(const Value: Int64);
    procedure SetCategory(const Value: TCategory);
    procedure SetPhotoUrls(const Value: stringList);
    procedure SetTags(const Value: TTagList);
    procedure SetStatus(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Int64 read FId write SetId;
    property IdHasValue: Boolean read FIdHasValue write FIdHasValue;
    property Name: string read FName write FName;
    property Category: TCategory read FCategory write SetCategory;
    property PhotoUrls: stringList read FPhotoUrls write SetPhotoUrls;
    property Tags: TTagList read FTags write SetTags;
    /// <summary>
    /// pet status in the store
    /// </summary>
    property Status: string read FStatus write SetStatus;
    property StatusHasValue: Boolean read FStatusHasValue write FStatusHasValue;
  end;
  
  TApiResponse = class
  private
    FCode: Integer;
    FCodeHasValue: Boolean;
    FType: string;
    FTypeHasValue: Boolean;
    FMessage: string;
    FMessageHasValue: Boolean;
    procedure SetCode(const Value: Integer);
    procedure SetType(const Value: string);
    procedure SetMessage(const Value: string);
  public
    property Code: Integer read FCode write SetCode;
    property CodeHasValue: Boolean read FCodeHasValue write FCodeHasValue;
    property &Type: string read FType write SetType;
    property &TypeHasValue: Boolean read FTypeHasValue write FTypeHasValue;
    property Message: string read FMessage write SetMessage;
    property MessageHasValue: Boolean read FMessageHasValue write FMessageHasValue;
  end;
  
  TPetList = class(TObjectList<TPet>)
  end;
  
  TGetInventoryOutput = class
  end;
  
  TUserList = class(TObjectList<TUser>)
  end;
  
implementation

{ TOrder }

procedure TOrder.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TOrder.SetPetId(const Value: Int64);
begin
  FPetId := Value;
  FPetIdHasValue := True;
end;

procedure TOrder.SetQuantity(const Value: Integer);
begin
  FQuantity := Value;
  FQuantityHasValue := True;
end;

procedure TOrder.SetShipDate(const Value: TDateTime);
begin
  FShipDate := Value;
  FShipDateHasValue := True;
end;

procedure TOrder.SetStatus(const Value: string);
begin
  FStatus := Value;
  FStatusHasValue := True;
end;

procedure TOrder.SetComplete(const Value: Boolean);
begin
  FComplete := Value;
  FCompleteHasValue := True;
end;

{ TAddress }

procedure TAddress.SetStreet(const Value: string);
begin
  FStreet := Value;
  FStreetHasValue := True;
end;

procedure TAddress.SetCity(const Value: string);
begin
  FCity := Value;
  FCityHasValue := True;
end;

procedure TAddress.SetState(const Value: string);
begin
  FState := Value;
  FStateHasValue := True;
end;

procedure TAddress.SetZip(const Value: string);
begin
  FZip := Value;
  FZipHasValue := True;
end;

{ TCustomer }

destructor TCustomer.Destroy;
begin
  FAddress.Free;
  inherited;
end;

procedure TCustomer.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TCustomer.SetUsername(const Value: string);
begin
  FUsername := Value;
  FUsernameHasValue := True;
end;

procedure TCustomer.SetAddress(const Value: TAddressList);
begin
  if Value <> FAddress then
  begin
    FAddress.Free;
    FAddress := Value;
  end;
end;

{ TCategory }

procedure TCategory.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TCategory.SetName(const Value: string);
begin
  FName := Value;
  FNameHasValue := True;
end;

{ TUser }

procedure TUser.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TUser.SetUsername(const Value: string);
begin
  FUsername := Value;
  FUsernameHasValue := True;
end;

procedure TUser.SetFirstName(const Value: string);
begin
  FFirstName := Value;
  FFirstNameHasValue := True;
end;

procedure TUser.SetLastName(const Value: string);
begin
  FLastName := Value;
  FLastNameHasValue := True;
end;

procedure TUser.SetEmail(const Value: string);
begin
  FEmail := Value;
  FEmailHasValue := True;
end;

procedure TUser.SetPassword(const Value: string);
begin
  FPassword := Value;
  FPasswordHasValue := True;
end;

procedure TUser.SetPhone(const Value: string);
begin
  FPhone := Value;
  FPhoneHasValue := True;
end;

procedure TUser.SetUserStatus(const Value: Integer);
begin
  FUserStatus := Value;
  FUserStatusHasValue := True;
end;

{ TTag }

procedure TTag.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TTag.SetName(const Value: string);
begin
  FName := Value;
  FNameHasValue := True;
end;

{ TPet }

constructor TPet.Create;
begin
  inherited;
  FPhotoUrls := stringList.Create;
end;

destructor TPet.Destroy;
begin
  FTags.Free;
  FPhotoUrls.Free;
  FCategory.Free;
  inherited;
end;

procedure TPet.SetId(const Value: Int64);
begin
  FId := Value;
  FIdHasValue := True;
end;

procedure TPet.SetCategory(const Value: TCategory);
begin
  if Value <> FCategory then
  begin
    FCategory.Free;
    FCategory := Value;
  end;
end;

procedure TPet.SetPhotoUrls(const Value: stringList);
begin
  if Value <> FPhotoUrls then
  begin
    FPhotoUrls.Free;
    FPhotoUrls := Value;
  end;
end;

procedure TPet.SetTags(const Value: TTagList);
begin
  if Value <> FTags then
  begin
    FTags.Free;
    FTags := Value;
  end;
end;

procedure TPet.SetStatus(const Value: string);
begin
  FStatus := Value;
  FStatusHasValue := True;
end;

{ TApiResponse }

procedure TApiResponse.SetCode(const Value: Integer);
begin
  FCode := Value;
  FCodeHasValue := True;
end;

procedure TApiResponse.SetType(const Value: string);
begin
  FType := Value;
  FTypeHasValue := True;
end;

procedure TApiResponse.SetMessage(const Value: string);
begin
  FMessage := Value;
  FMessageHasValue := True;
end;

end.
