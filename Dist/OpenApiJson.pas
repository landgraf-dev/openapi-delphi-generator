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
  OpenApiJsonWrapperFpc,
{$ELSE}
  Generics.Collections,
  {$IFDEF DELPHIXE7_UP}
    OpenApiJsonWrapper,
  {$ELSE}
    OpenApiJsonWrapperDbx,
  {$ENDIF}
{$ENDIF}
  SysUtils;

type
  TJSONValue = TJSONWrapper.TJSONValue;

{$IFDEF FPC}
  TJsonWrapper = OpenApiJsonWrapperFpc.TJsonWrapper;
{$ELSE}
  {$IFDEF DELPHIXE7_UP}
    TJsonWrapper = OpenApiJsonWrapper.TJsonWrapper;
  {$ELSE}
    TJsonWrapper = OpenApiJsonWrapperDbx.TJsonWrapper;
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
