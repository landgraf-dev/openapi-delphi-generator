unit OpenApiJson;

{$IFDEF FPC}
  {$MODE Delphi}
{$ELSE}
  //TODO use Delphiversions.inc
  {$IF CompilerVersion >= 28}
    {$DEFINE DelphiXE7}
    {$DEFINE DelphiXE7_UP}
  {$ENDIF}
{$ENDIF}


interface

uses
{$IFDEF FPC}
  fpjson, jsonparser,
{$ELSE}
  Generics.Collections,
  {$IFDEF DELPHIXE7_UP}
    System.JSON,
  {$ELSE}
    Data.DBXJSON,
  {$ENDIF}
{$ENDIF}
  SysUtils;

type
{$IFDEF FPC}
  TJSONValue = fpjson.TJSONData;
  TJSONBool = fpjson.TJSONBoolean;
{$ELSE}
  {$IFDEF DELPHIXE7_UP}
    TJSONValue = System.JSON.TJSONValue;
  {$ELSE}
    TJSONValue = Data.DBXJSON.TJSONValue;
  {$ENDIF}
{$ENDIF}

  TJsonWrapper = class abstract
  protected
    function IsFloatingPoint(const Value: string): Boolean;
  public
    // method to convert basic types to/from TJSONValue
    function StringToJsonValue(const Value: string): TJSONValue; virtual;
    function StringFromJsonValue(Value: TJSONValue): string; virtual;
    function IntegerToJsonValue(const Value: Integer): TJSONValue; virtual; abstract;
    function IntegerFromJsonValue(Value: TJSONValue): Integer; virtual; abstract;
    function Int64ToJsonValue(const Value: Int64): TJSONValue; virtual; abstract;
    function Int64FromJsonValue(Value: TJSONValue): Int64; virtual; abstract;
    function DoubleToJsonValue(const Value: Double): TJSONValue; virtual; abstract;
    function DoubleFromJsonValue(Value: TJSONValue): Double; virtual; abstract;
    function BooleanToJsonValue(const Value: Boolean): TJSONValue; virtual; abstract;
    function BooleanFromJsonValue(Value: TJSONValue): Boolean; virtual; abstract;

    // methods for JSON object manipulation
    procedure ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue); virtual; abstract;
    function ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean; virtual; abstract;

    // methods for JSON array manipulation
    procedure ArrayAdd(JArr: TJSONValue; Value: TJSONValue); virtual; abstract;
    function ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue; virtual; abstract;
    function ArrayLength(JArr: TJSONValue): Integer; virtual; abstract;

    // JSON value constructors
    function CreateObject: TJSONValue; virtual;
    function CreateArray: TJSONValue; virtual;
    function CreateNull: TJSONValue; virtual;

    // Check for JSON types
    function IsObject(Value: TJSONValue): Boolean; virtual;
    function IsArray(Value: TJSONValue): Boolean; virtual;
    function IsString(Value: TJSONValue): Boolean; virtual;
    function IsNumber(Value: TJSONValue): Boolean; virtual;
    function IsBoolean(Value: TJSONValue): Boolean; virtual; abstract;
    function IsNull(Value: TJSONValue): Boolean; virtual;

    // Json generating and parsing
    function JsonValueToJson(Value: TJSONValue): string; virtual; abstract;
    function JsonToJsonValue(const Value: string): TJSONValue; virtual; abstract;
  end;

{$IFDEF DELPHIXE7_UP}
  //Implementation for Delphi XE7+
  TJsonWrapperSystem = class(TJsonWrapper)
  public
    function IntegerToJsonValue(const Value: Integer): TJSONValue; override;
    function IntegerFromJsonValue(Value: TJSONValue): Integer; override;
    function Int64ToJsonValue(const Value: Int64): TJSONValue; override;
    function Int64FromJsonValue(Value: TJSONValue): Int64; override;
    function DoubleToJsonValue(const Value: Double): TJSONValue; override;
    function DoubleFromJsonValue(Value: TJSONValue): Double; override;
    function BooleanToJsonValue(const Value: Boolean): TJSONValue; override;
    function BooleanFromJsonValue(Value: TJSONValue): Boolean; override;

    // methods for JSON object manipulation
    procedure ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue); override;
    function ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean; override;

    // methods for JSON array manipulation
    procedure ArrayAdd(JArr: TJSONValue; Value: TJSONValue); override;
    function ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue; override;
    function ArrayLength(JArr: TJSONValue): Integer; override;

    // Check for JSON types
    function IsBoolean(Value: TJSONValue): Boolean; override;

    // Json generating and parsing
    function JsonValueToJson(Value: TJSONValue): string; override;
    function JsonToJsonValue(const Value: string): TJSONValue; override;
  end;
{$ENDIF}


{$IFDEF FPC}
  //Implementation for FPC
  TJsonWrapperFpc = class(TJsonWrapper)
  public
    // method to convert basic types to/from TJSONValue
    function IntegerToJsonValue(const Value: Integer): TJSONValue; override;
    function IntegerFromJsonValue(Value: TJSONValue): Integer; override;
    function Int64ToJsonValue(const Value: Int64): TJSONValue; override;
    function Int64FromJsonValue(Value: TJSONValue): Int64; override;
    function DoubleToJsonValue(const Value: Double): TJSONValue; override;
    function DoubleFromJsonValue(Value: TJSONValue): Double; override;
    function BooleanToJsonValue(const Value: Boolean): TJSONValue; override;
    function BooleanFromJsonValue(Value: TJSONValue): Boolean; override;

    // methods for JSON object manipulation
    procedure ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue); override;
    function ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean; override;

    // methods for JSON array manipulation
    procedure ArrayAdd(JArr: TJSONValue; Value: TJSONValue); override;
    function ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue; override;
    function ArrayLength(JArr: TJSONValue): Integer; override;

    // Check for JSON types
    function IsBoolean(Value: TJSONValue): Boolean; override;

    // Json generating and parsing
    function JsonValueToJson(Value: TJSONValue): string; override;
    function JsonToJsonValue(const Value: string): TJSONValue; override;
  end;
{$ENDIF}

{$IFNDEF FPC}
{$IFNDEF DELPHIXE7_UP}
  //Implementation for DBX (Delphi <XE7)
  TJsonWrapperDbx = class(TJsonWrapper)
  public
    // method to convert basic types to/from TJSONValue
    function IntegerToJsonValue(const Value: Integer): TJSONValue; override;
    function IntegerFromJsonValue(Value: TJSONValue): Integer; override;
    function Int64ToJsonValue(const Value: Int64): TJSONValue; override;
    function Int64FromJsonValue(Value: TJSONValue): Int64; override;
    function DoubleToJsonValue(const Value: Double): TJSONValue; override;
    function DoubleFromJsonValue(Value: TJSONValue): Double; override;
    function BooleanToJsonValue(const Value: Boolean): TJSONValue; override;
    function BooleanFromJsonValue(Value: TJSONValue): Boolean; override;

    // methods for JSON object manipulation
    procedure ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue); override;
    function ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean; override;

    // methods for JSON array manipulation
    procedure ArrayAdd(JArr: TJSONValue; Value: TJSONValue); override;
    function ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue; override;
    function ArrayLength(JArr: TJSONValue): Integer; override;

    // Check for JSON types
    function IsBoolean(Value: TJSONValue): Boolean; override;

    // Json generating and parsing
    function JsonValueToJson(Value: TJSONValue): string; override;
    function JsonToJsonValue(const Value: string): TJSONValue; override;
  end;
{$ENDIF}
{$ENDIF}


  TCustomJsonConverter = class
  private
    FJson: TJsonWrapper;
  protected
    function JsonValueToJson(Value: TJSONValue): string;
    function JsonToJsonValue(const Value: string): TJSONValue;
    property Json: TJsonWrapper read FJson;
  public
    constructor Create; overload;
    constructor Create(AJson: TJsonWrapper); overload;

    // method to convert basic types to/from TJSONValue
    function StringToJsonValue(const Value: string): TJSONValue; virtual;
    function StringFromJsonValue(Value: TJSONValue): string; virtual;
    function IntegerToJsonValue(const Value: Integer): TJSONValue; virtual;
    function IntegerFromJsonValue(Value: TJSONValue): Integer; virtual;
    function Int64ToJsonValue(const Value: Int64): TJSONValue; virtual;
    function Int64FromJsonValue(Value: TJSONValue): Int64; virtual;
    function DoubleToJsonValue(const Value: Double): TJSONValue; virtual;
    function DoubleFromJsonValue(Value: TJSONValue): Double; virtual;
    function BooleanToJsonValue(const Value: Boolean): TJSONValue; virtual;
    function BooleanFromJsonValue(Value: TJSONValue): Boolean; virtual;
    function TDateTimeToJsonValue(const Value: TDateTime): TJSONValue; virtual;
    function TDateTimeFromJsonValue(Value: TJSONValue): TDateTime; virtual;
    function TDateToJsonValue(const Value: TDate): TJSONValue; virtual;
    function TDateFromJsonValue(Value: TJSONValue): TDate; virtual;
    function TBytesToJsonValue(const Value: TBytes): TJSONValue; virtual;
    function TBytesFromJsonValue(Value: TJSONValue): TBytes; virtual;

    // method to convert basic types to/from JSON
    function StringToJson(const Source: string): string; virtual;
    function StringFromJson(Source: string): string; virtual;
    function IntegerToJson(const Source: Integer): string; virtual;
    function IntegerFromJson(Source: string): Integer; virtual;
    function Int64ToJson(const Source: Int64): string; virtual;
    function Int64FromJson(Source: string): Int64; virtual;
    function DoubleToJson(const Source: Double): string; virtual;
    function DoubleFromJson(const Source: string): Double; virtual;
    function BooleanToJson(const Source: Boolean): string; virtual;
    function BooleanFromJson(Source: string): Boolean; virtual;
    function TDateTimeToJson(const Source: TDateTime): string; virtual;
    function TDateTimeFromJson(Source: string): TDateTime; virtual;
    function TDateToJson(const Source: TDate): string; virtual;
    function TDateFromJson(Source: string): TDate; virtual;
    function TBytesToJson(const Source: TBytes): string; virtual;
    function TBytesFromJson(Source: string): TBytes; virtual;
  end;

function JsonWrapper: TJsonWrapper;

implementation

uses
  OpenApiUtils;

var
  _Json: TJsonWrapper;

function JsonWrapper: TJsonWrapper;
begin
  Result := _Json;
end;

{ TJsonWrapper }

function TJsonWrapper.CreateArray: TJSONValue;
begin
  Result := TJSONArray.Create;
end;

function TJsonWrapper.CreateNull: TJSONValue;
begin
  Result := TJSONNull.Create;
end;

function TJsonWrapper.CreateObject: TJSONValue;
begin
  Result := TJSONObject.Create;
end;

function TJsonWrapper.IsArray(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONArray;
end;

function TJsonWrapper.IsFloatingPoint(const Value: string): Boolean;
var
  DotPos: Integer;
  DotMinus: Integer;
begin
  DotPos := Pos('.', Value);
  DotMinus := Pos('-', Value);
  Result := (DotPos > 0) or (DotMinus > 2);
  // TODO: There might be numbers with minus and still integer, e.g. 100e-1
end;

function TJsonWrapper.IsNull(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONNull;
end;

function TJsonWrapper.IsNumber(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONNumber;
end;

function TJsonWrapper.IsObject(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONObject;
end;

function TJsonWrapper.IsString(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONString;
end;

function TJsonWrapper.StringFromJsonValue(Value: TJSONValue): string;
begin
  if IsString(Value) then
    Result := TJSONString(Value).Value
  else
    Result := '';
end;

function TJsonWrapper.StringToJsonValue(const Value: string): TJSONValue;
begin
  Result := TJSONString.Create(Value);
end;


{$IFDEF DELPHIXE7_UP}
{ TJsonWrapperSystem }

procedure TJsonWrapperSystem.ArrayAdd(JArr: TJSONValue; Value: TJSONValue);
begin
  TJSONArray(JArr).AddElement(Value);
end;

function TJsonWrapperSystem.ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue;
begin
  Result := TJSONArray(JArr).Items[Index];
end;

function TJsonWrapperSystem.ArrayLength(JArr: TJSONValue): Integer;
begin
  Result := TJSONArray(JArr).Count;
end;

function TJsonWrapperSystem.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  if IsBoolean(Value) then
    Result := TJSONBool(Value).AsBoolean
  else
    Result := False;
end;

function TJsonWrapperSystem.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
  if Value then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

function TJsonWrapperSystem.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsDouble;
end;

function TJsonWrapperSystem.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperSystem.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt64;
end;

function TJsonWrapperSystem.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperSystem.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt;
end;

function TJsonWrapperSystem.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperSystem.IsBoolean(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONBool;
end;

function TJsonWrapperSystem.JsonToJsonValue(const Value: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(Value);
end;

function TJsonWrapperSystem.JsonValueToJson(Value: TJSONValue): string;
begin
  Result := Value.ToString;
end;

procedure TJsonWrapperSystem.ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue);
begin
  TJSONObject(JObj).AddPair(Name, Value);
end;

function TJsonWrapperSystem.ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean;
begin
  Value := TJSONObject(JObj).GetValue(Name);
  Result := Value <> nil;
end;

{$ENDIF}


{$IFDEF FPC}
{ TJsonWrapperFpc }

procedure TJsonWrapperFpc.ArrayAdd(JArr: TJSONValue; Value: TJSONValue);
begin
  TJSONArray(JArr).Add(Value);
end;

function TJsonWrapperFpc.ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue;
begin
  Result := TJSONArray(JArr).Items[Index];
end;

function TJsonWrapperFpc.ArrayLength(JArr: TJSONValue): Integer;
begin
  Result := TJSONArray(JArr).Count;
end;

function TJsonWrapperFpc.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  if IsBoolean(Value) then
    Result := TJSONBool(Value).AsBoolean
  else
    Result := False;
end;

function TJsonWrapperFpc.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
  if Value then
    Result := TJSONBool.Create(True)
  else
    Result := TJSONBool.Create(False);
end;

function TJsonWrapperFpc.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsFloat;
end;

function TJsonWrapperFpc.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
  Result := TJSONFloatNumber.Create(Value);
end;

function TJsonWrapperFpc.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsInt64;
end;

function TJsonWrapperFpc.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
  Result := TJSONInt64Number.Create(Value);
end;

function TJsonWrapperFpc.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsInteger;
end;

function TJsonWrapperFpc.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
  Result := TJSONIntegerNumber.Create(Value);
end;

function TJsonWrapperFpc.IsBoolean(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONBool;
end;

function TJsonWrapperFpc.JsonToJsonValue(const Value: string): TJSONValue;
begin
  Result := fpjson.GetJSON(Value);
end;

function TJsonWrapperFpc.JsonValueToJson(Value: TJSONValue): string;
begin
  Result := Value.AsJSON;
end;

procedure TJsonWrapperFpc.ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue);
begin
  TJSONObject(JObj).Add(Name, Value);
end;

function TJsonWrapperFpc.ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean;
begin
  Value := TJSONObject(JObj).Find(Name);
  Result := Value <> nil;
end;

{$ENDIF}

{$IFNDEF FPC}
{$IFNDEF DELPHIXE7_UP}
{ TJsonWrapperDbx }

procedure TJsonWrapperDbx.ArrayAdd(JArr: TJSONValue; Value: TJSONValue);
begin
  TJSONArray(JArr).AddElement(Value);
end;

function TJsonWrapperDbx.ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue;
begin
  Result := TJSONArray(JArr).Get(Index);
end;

function TJsonWrapperDbx.ArrayLength(JArr: TJSONValue): Integer;
begin
  Result := TJSONArray(JArr).Size;
end;

function TJsonWrapperDbx.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  if IsBoolean(Value) then
  begin
      if Value is TJSONTrue then
        Result := True
      else
        Result := False;    //Assert(Value is TJSONFalse)
  end
  else
    Result := False;
end;

function TJsonWrapperDbx.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
  if Value then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

function TJsonWrapperDbx.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsDouble;
end;

function TJsonWrapperDbx.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperDbx.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt64;
end;

function TJsonWrapperDbx.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperDbx.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt;
end;

function TJsonWrapperDbx.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapperDbx.IsBoolean(Value: TJSONValue): Boolean;
begin
  Result := (Value is TJSONTrue) or (Value is TJSONFalse);
end;

function TJsonWrapperDbx.JsonToJsonValue(const Value: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(Value);
end;

function TJsonWrapperDbx.JsonValueToJson(Value: TJSONValue): string;
begin
  Result := Value.ToString;
end;

procedure TJsonWrapperDbx.ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue);
begin
  TJSONObject(JObj).AddPair(Name, Value);
end;

function TJsonWrapperDbx.ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean;
var
  Pair: TJSONPair;
begin
  Pair := TJSONObject(JObj).Get(Name);
  if Assigned(Pair) then
    Value := Pair.JsonValue
  else
    Value := nil;
  Result := Value <> nil;
end;

{$ENDIF}
{$ENDIF}


{ TCustomJsonConverter }

function TCustomJsonConverter.BooleanFromJson(Source: string): Boolean;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := BooleanFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  Result := Json.BooleanFromJsonValue(Value);
end;

function TCustomJsonConverter.BooleanToJson(const Source: Boolean): string;
var
  JValue: TJSONValue;
begin
  JValue := BooleanToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
  Result := Json.BooleanToJsonValue(Value);
end;

constructor TCustomJsonConverter.Create(AJson: TJsonWrapper);
begin
  inherited Create;
  FJson := AJson;
end;

function TCustomJsonConverter.DoubleFromJson(const Source: string): Double;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := DoubleFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := Json.DoubleFromJsonValue(Value);
end;

function TCustomJsonConverter.DoubleToJson(const Source: Double): string;
var
  JValue: TJSONValue;
begin
  JValue := DoubleToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
  Result := Json.DoubleToJsonValue(Value);
end;

function TCustomJsonConverter.TBytesFromJson(Source: string): TBytes;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TBytesFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TBytesFromJsonValue(Value: TJSONValue): TBytes;
begin
  Result := OpenApiUtils.DecodeBase64(StringFromJsonValue(Value));
end;

function TCustomJsonConverter.TBytesToJson(const Source: TBytes): string;
var
  JValue: TJSONValue;
begin
  JValue := TBytesToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TBytesToJsonValue(const Value: TBytes): TJSONValue;
begin
  Result := StringToJsonValue(OpenApiUtils.EncodeBase64(Value));
end;

function TCustomJsonConverter.TDateFromJson(Source: string): TDate;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TDateFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TDateFromJsonValue(Value: TJSONValue): TDate;
begin
  Result := OpenApiUtils.ISOToDate(StringFromJsonValue(Value));
end;

function TCustomJsonConverter.TDateTimeFromJson(Source: string): TDateTime;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := TDateTimeFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TDateTimeFromJsonValue(Value: TJSONValue): TDateTime;
begin
  Result := OpenApiUtils.ISOToDateTime(StringFromJsonValue(Value));
end;

function TCustomJsonConverter.TDateTimeToJson(const Source: TDateTime): string;
var
  JValue: TJSONValue;
begin
  JValue := TDateTimeToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TDateTimeToJsonValue(const Value: TDateTime): TJSONValue;
begin
  Result := StringToJsonValue(OpenApiUtils.DateTimeToISO(Value));
end;

function TCustomJsonConverter.TDateToJson(const Source: TDate): string;
var
  JValue: TJSONValue;
begin
  JValue := TDateToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.TDateToJsonValue(const Value: TDate): TJSONValue;
begin
  Result := StringToJsonValue(OpenApiUtils.DateToISO(Value));
end;

function TCustomJsonConverter.Int64FromJson(Source: string): Int64;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := Int64FromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := Json.Int64FromJsonValue(Value);
end;

function TCustomJsonConverter.Int64ToJson(const Source: Int64): string;
var
  JValue: TJSONValue;
begin
  JValue := Int64ToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
  Result := Json.Int64ToJsonValue(Value);
end;

function TCustomJsonConverter.IntegerFromJson(Source: string): Integer;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := IntegerFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := Json.IntegerFromJsonValue(Value);
end;

function TCustomJsonConverter.IntegerToJson(const Source: Integer): string;
var
  JValue: TJSONValue;
begin
  JValue := IntegerToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
  Result := Json.IntegerToJsonValue(Value);
end;

function TCustomJsonConverter.JsonToJsonValue(const Value: string): TJSONValue;
begin
  Result := Json.JsonToJsonValue(Value);
end;

function TCustomJsonConverter.JsonValueToJson(Value: TJSONValue): string;
begin
  Result := Json.JsonValueToJson(Value);
end;

function TCustomJsonConverter.StringFromJson(Source: string): string;
var
  JValue: TJSONValue;
begin
  JValue := JsonToJsonValue(Source);
  try
    Result := StringFromJsonValue(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.StringFromJsonValue(Value: TJSONValue): string;
begin
  Result := Json.StringFromJsonValue(Value);
end;

function TCustomJsonConverter.StringToJson(const Source: string): string;
var
  JValue: TJSONValue;
begin
  JValue := StringToJsonValue(Source);
  try
    Result := JsonValueToJson(JValue);
  finally
    JValue.Free;
  end;
end;

function TCustomJsonConverter.StringToJsonValue(const Value: string): TJSONValue;
begin
  Result := Json.StringToJsonValue(Value);
end;

constructor TCustomJsonConverter.Create;
begin
  Create(_Json);
end;

initialization
{$IFDEF FPC}
  _Json := TJsonWrapperFpc.Create;
{$ELSE}
  {$IFDEF DELPHIXE7_UP}
    _Json := TJsonWrapperSystem.Create;
  {$ELSE}
    _Json := TJsonWrapperDbx.Create;
  {$ENDIF}
{$ENDIF}

finalization
  _Json.Free;
end.
