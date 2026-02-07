unit OpenApiJson;

{$IFDEF FPC}
  {$MODE Delphi}
{$ELSE}
  {$IF CompilerVersion < 30}
    {$DEFINE NOJSONBOOL}
  {$IFEND}
  {$IF CompilerVersion < 28}
    {$DEFINE USEDBX}
  {$IFEND}
{$ENDIF}


interface

uses
{$IFDEF FPC}
  fpjson, jsonparser,
{$ELSE}
  Generics.Collections,
  {$IFDEF USEDBX}
    Data.DBXJSON,
  {$ELSE}
    {$IFDEF USEJDO}
      JsonDataObjects,
    {$ELSE}
      System.JSON,
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
  SysUtils;

type
{$IFDEF FPC}
  TJSONValue = fpjson.TJSONData;
  TJSONBool = fpjson.TJSONBoolean;
{$ELSE}
  {$IFDEF USEDBX}
    TJSONValue = Data.DBXJSON.TJSONValue;
  {$ELSE}
    {$IFDEF USEJDO}
      // TJsonBaseObject can be TJsonObject or JsonArray or TJsonPrimitiveValue
      // TJsonPrimitiveValue is just used as transport-wrapper around TJsonDataValueHelper (released after use)
      // TJsonDataValueHelper can handle pointer existing instance of dataobjects within FIntern, so it should be pretty fast but confusing on debugging
      TJSONValue = JsonDataObjects.TJsonBaseObject;
    {$ELSE}
      TJSONValue = System.JSON.TJSONValue;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

  TJsonWrapper = class
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

procedure TJsonWrapper.ArrayAdd(JArr: TJSONValue; Value: TJSONValue);
begin
{$IFDEF FPC}
  TJSONArray(JArr).Add(Value);
{$ELSE}
  {$IFDEF USEJDO}
  if Value is TJsonObject then
    TJSONArray(JArr).Add(TJsonObject(Value));
  if Value is TJsonArray then
    TJSONArray(JArr).Add(TJsonArray(Value));
  if JArr is TJsonPrimitiveValue then
  begin
    TJSONArray(JArr).Add(TJsonPrimitiveValue(Value).Value.VariantValue);
    Value.Free;
  end;
  {$ELSE}
  TJSONArray(JArr).AddElement(Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.ArrayGet(JArr: TJSONValue; Index: Integer): TJSONValue;
begin
{$IFDEF USEDBX}
  Result := TJSONArray(JArr).Get(Index);
{$ELSE}
{$IFDEF USEJDO}
  if (TJSONArray(JArr).Types[Index] = TJsonDataType.jdtObject) then
    Result:= TJSONArray(JArr).O[Index]
  else
    if (TJSONArray(JArr).types[Index] = TJsonDataType.jdtArray) then
      Result:= TJSONArray(JArr).A[Index]
    else
    begin
      Result:= TJsonPrimitiveValue.Create;
      TJsonPrimitiveValue(Result).Value:= TJSONArray(JArr).Values[Index];
    end;
{$ELSE}
  Result := TJSONArray(JArr).Items[Index];
{$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.ArrayLength(JArr: TJSONValue): Integer;
begin
{$IFDEF USEDBX}
  Result := TJSONArray(JArr).Size;
{$ELSE}
  Result := TJSONArray(JArr).Count;
{$ENDIF}
end;

function TJsonWrapper.BooleanFromJsonValue(Value: TJSONValue): Boolean;
begin
  if IsBoolean(Value) then
  begin
{$IFDEF NOJSONBOOL}
    Result := Value is TJSONTrue;
{$ELSE}
  {$IFDEF USEJDO}
    Result:= TJsonPrimitiveValue(Value).Value;
    Value.Free;
  {$ELSE}
    Result := TJSONBool(Value).AsBoolean
  {$ENDIF}
{$ENDIF}
  end
  else
    Result := False;
end;

function TJsonWrapper.BooleanToJsonValue(const Value: Boolean): TJSONValue;
begin
{$IFDEF FPC}
  if Value then
    Result := TJSONBool.Create(True)
  else
    Result := TJSONBool.Create(False);
{$ELSE}
  {$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create;
  TJsonPrimitiveValue(Result).Value := Value;
  {$ELSE}
  if Value then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.CreateArray: TJSONValue;
begin
  Result := TJSONArray.Create;
end;

function TJsonWrapper.CreateNull: TJSONValue;
begin
{$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create; // no content, type none
{$ELSE}
  Result := TJSONNull.Create;
{$ENDIF}
end;

function TJsonWrapper.CreateObject: TJSONValue;
begin
  Result := TJSONObject.Create;
end;

function TJsonWrapper.DoubleFromJsonValue(Value: TJSONValue): Double;
begin
  Result := 0;
  if IsNumber(Value) then
{$IFDEF FPC}
    Result := TJSONNumber(Value).AsFloat;
{$ELSE}
  {$IFDEF USEJDO}
    Result:= TJsonPrimitiveValue(Value).Value;
    Value.Free;
  {$ELSE}
    Result := TJSONNumber(Value).AsDouble;
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.DoubleToJsonValue(const Value: Double): TJSONValue;
begin
{$IFDEF FPC}
  Result := TJSONFloatNumber.Create(Value);
{$ELSE}
  {$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create;
  TJsonPrimitiveValue(Result).Value:= Value;
  {$ELSE}
  Result := TJSONNumber.Create(Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.Int64FromJsonValue(Value: TJSONValue): Int64;
begin
  Result := 0;
{$IFDEF FPC}
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsInt64;
{$ELSE}
  {$IFDEF USEJDO}
  Result:= TJsonPrimitiveValue(Value).Value;
  Value.Free;
  {$ELSE}
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt64;
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.Int64ToJsonValue(const Value: Int64): TJSONValue;
begin
{$IFDEF FPC}
  Result := TJSONInt64Number.Create(Value);
{$ELSE}
  {$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create;
  TJsonPrimitiveValue(Result).Value:= Value;
  {$ELSE}
  Result := TJSONNumber.Create(Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.IntegerFromJsonValue(Value: TJSONValue): Integer;
begin
  Result := 0;
{$IFDEF FPC}
  if IsNumber(Value) then
    Result := TJSONNumber(Value).AsInteger;
{$ELSE}
  {$IFDEF USEJDO}
  Result:= TJsonPrimitiveValue(Value).Value;
  Value.Free;
  {$ELSE}
  if IsNumber(Value) and not IsFloatingPoint(TJSONNumber(Value).Value) then
    Result := TJSONNumber(Value).AsInt;
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.IntegerToJsonValue(const Value: Integer): TJSONValue;
begin
{$IFDEF FPC}
  Result := TJSONIntegerNumber.Create(Value);
{$ELSE}
  {$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create;
  TJsonPrimitiveValue(Result).Value:= Value;
  {$ELSE}
  Result := TJSONNumber.Create(Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.IsArray(Value: TJSONValue): Boolean;
begin
  Result := Value is TJSONArray;
end;

function TJsonWrapper.IsBoolean(Value: TJSONValue): Boolean;
begin
{$IFDEF NOJSONBOOL}
  Result := (Value is TJSONTrue) or (Value is TJSONFalse);
{$ELSE}
  {$IFDEF USEJDO}
  Result := (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtBool);
  {$ELSE}
  Result := Value is TJSONBool;
  {$ENDIF}
{$ENDIF}
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
{$IFDEF USEJDO}
  Result:= (Value = nil) or (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtNone);
{$ELSE}
  Result := Value is TJSONNull;
{$ENDIF}
end;

function TJsonWrapper.IsNumber(Value: TJSONValue): Boolean;
begin
{$IFDEF USEJDO}
  Result := (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtInt) or
            (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtLong) or
            (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtULong) or
            (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtFloat);
{$ELSE}
  Result := Value is TJSONNumber;
{$ENDIF}
end;

function TJsonWrapper.IsObject(Value: TJSONValue): Boolean;
begin
{$IFDEF USEJDO}
  Result := Value is TJSONObject;
{$ELSE}
  Result := Value is TJSONObject;
{$ENDIF}
end;

function TJsonWrapper.IsString(Value: TJSONValue): Boolean;
begin
{$IFDEF USEJDO}
  Result := (TJsonPrimitiveValue(Value).Value.Typ = TJsonDataType.jdtString);
{$ELSE}
  Result := Value is TJSONString;
{$ENDIF}
end;

function TJsonWrapper.JsonToJsonValue(const Value: string): TJSONValue;
begin
{$IFDEF FPC}
  Result := fpjson.GetJSON(Value);
{$ELSE}
  {$IFDEF USEJDO}
  Result:= TJsonObject.Parse(Value);
  {$ELSE}
  Result := TJSONObject.ParseJSONValue(Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.JsonValueToJson(Value: TJSONValue): string;
begin
{$IFDEF FPC}
  Result := Value.AsJSON;
{$ELSE}
  {$IFDEF USEJDO}
  if Value is TJsonObject then
    Result:= TJsonObject(Value).ToJSON;
  if Value is TJsonArray then
    Result:= TJsonArray(Value).ToJSON;
  if Value is TJsonPrimitiveValue then
  begin
    Result:= TJsonPrimitiveValue(Value).ToJSON;
    Value.Free;
  end;
  {$ELSE}
  Result := Value.ToString;
  {$ENDIF}
{$ENDIF}
end;

procedure TJsonWrapper.ObjAddProp(JObj: TJSONValue; const Name: string; Value: TJSONValue);
begin
{$IFDEF FPC}
  TJSONObject(JObj).Add(Name, Value);
{$ELSE}
  {$IFDEF USEJDO}
  if Value is TJsonObject then
   TJSONObject(JObj).Values[Name] := TJsonObject(Value);
  if Value is TJsonArray then
   TJSONObject(JObj).Values[Name] := TJsonArray(Value);
  if Value is TJsonPrimitiveValue then
  begin
   TJSONObject(JObj).Values[Name] := TJsonPrimitiveValue(Value).Value.VariantValue;
   Value.Free
  end;
  {$ELSE}
  TJSONObject(JObj).AddPair(Name, Value);
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.ObjContains(JObj: TJSONValue; const Name: string; out Value: TJSONValue): Boolean;
{$IFDEF USEDBX}
var
  Pair: TJSONPair;
{$ENDIF}
{$IFDEF USEJDO}
var
  i: integer;
{$ENDIF}
begin
{$IFDEF FPC}
  Value := TJSONObject(JObj).Find(Name);
  Result := Value <> nil;
{$ELSE}
  {$IFDEF USEJDO}
  Value:= nil;
  i:= TJSONObject(JObj).indexof(name);
  if (i > 0) and (TJSONObject(JObj).types[name] = TJsonDataType.jdtObject) then
    Value:= TJSONObject(JObj).O[name]
  else
    if (i > 0) and (TJSONObject(JObj).types[name] = TJsonDataType.jdtArray) then
      Value:= TJSONObject(JObj).A[name]
    else
    begin
      Result:= TJSONObject(JObj).IndexOf(name)>-1;
      Value:= nil;
      if Result then
      begin
        Value:= TJsonPrimitiveValue.Create;
        TJsonPrimitiveValue(Value).Value:= TJSONObject(JObj).Values[name];
      end;
    end;
  Result := Value <> nil;
  {$ELSE}
  {$IFDEF USEDBX}
  Pair := TJSONObject(JObj).Get(Name);
  if Assigned(Pair) then
  begin
    Value := Pair.JsonValue;
    {$IFDEF OPENAPI_NULLVALUES_WORKAROUND}
      //With this define active (default: inactive) null is treated as not ...HasValue.
      //This is a workaround for issue #28
      if Value.Null then
	    Value := nil;
    {$ENDIF}
  end
  else
    Value := nil;
  {$ELSE}
  Value := TJSONObject(JObj).GetValue(Name);
  {$ENDIF}
  Result := Value <> nil;
  {$ENDIF}
{$ENDIF}
end;

function TJsonWrapper.StringFromJsonValue(Value: TJSONValue): string;
begin
{$IFDEF USEJDO}
  Result:= TJsonPrimitiveValue(Value).Value;
  Value.Free;
{$ELSE}
  if IsString(Value) then
    Result := TJSONString(Value).Value
  else
    Result := '';
{$ENDIF}
end;

function TJsonWrapper.StringToJsonValue(const Value: string): TJSONValue;
begin
{$IFDEF USEJDO}
  Result := TJsonPrimitiveValue.Create;
  TJsonPrimitiveValue(Result).Value:= Value;
{$ELSE}
  Result := TJSONString.Create(Value);
{$ENDIF}
end;

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
  _Json := TJsonWrapper.Create;
finalization
  _Json.Free;
end.
