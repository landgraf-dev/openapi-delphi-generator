unit OpenApiJsonWrapper;

//Json Wrapper for Delphi XE7+

interface

uses
  Generics.Collections,
  System.JSON,
  System.SysUtils;

type
  TJsonWrapper = class
  public
    type  TJSONValue = System.TJSONValue;
  private
    function IsFloatingPoint(const Value: string): Boolean;
  public
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

    // methods for JSON object manipulation
    procedure ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue); virtual;
    function ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean; virtual;

    // methods for JSON array manipulation
    procedure ArrayAdd(JArr: TJSONValue; Value: TJSONValue); virtual;
    function ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue; virtual;
    function ArrayLength(JArr: TJSONValue): Integer; virtual;

    // JSON value constructors
    function CreateObject: TJSONValue; virtual;
    function CreateArray: TJSONValue; virtual;
    function CreateNull: TJSONValue; virtual;

    // Check for JSON types
    function IsObject(Value: TJSONValue): Boolean; virtual;
    function IsArray(Value: TJSONValue): Boolean; virtual;
    function IsString(Value: TJSONValue): Boolean; virtual;
    function IsNumber(Value: TJSONValue): Boolean; virtual;
    function IsBoolean(Value: TJSONValue): Boolean; virtual;
    function IsNull(Value: TJSONValue): Boolean; virtual;

    // Json generating and parsing
    function JsonValueToJson(Value: TJSONValue): string; virtual;
    function JsonToJsonValue(const Value: string): TJSONValue; virtual;
  end;


implementation

uses
  OpenApiUtils;

{ TJsonWrapper }

procedure TJsonWrapper.ArrayAdd(JArr: TJSONValue; Value: TJSONValue);
begin
  TJSONArray(JArr).AddElement(Value);
end;

function TJsonWrapper.ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue;
begin
  Result := TJSONArray(JArr).Items[Index];
end;

function TJsonWrapper.ArrayLength(JArr: TJSONValue): Integer;
begin
  Result := TJSONArray(JArr).Count;
end;

function TJsonWrapper.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  if IsBoolean(Value) then
    Result := TJSONBool(Value).AsBoolean
  else
    Result := False;
end;

function TJsonWrapper.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
  if Value then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

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

function TJsonWrapper.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := 0;
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsDouble;
end;

function TJsonWrapper.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapper.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt64;
end;

function TJsonWrapper.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapper.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := 0;
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt;
end;

function TJsonWrapper.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

function TJsonWrapper.IsArray(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONArray;
end;

function TJsonWrapper.IsBoolean(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONBool;
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

function TJsonWrapper.JsonToJsonValue(const Value: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(Value);
end;

function TJsonWrapper.JsonValueToJson(Value: TJSONValue): string;
begin
  Result := Value.ToString;
end;

procedure TJsonWrapper.ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue);
begin
  TJSONObject(JObj).AddPair(Name, Value);
end;

function TJsonWrapper.ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean;
begin
  Value := TJSONObject(JObj).GetValue(Name);
  Result := Value <> nil;
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

end.
