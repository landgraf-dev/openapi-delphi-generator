unit OpenApiUtils;

interface

uses
  SysUtils;

function PercentEncode(const S: string): string;
procedure AppendQueryParam(var Query: string; const Name, Value: string);

implementation

function PercentEncode(const S: string): string;
var
  Bytes: TBytes;
  B: Byte;
  I: integer;
  L: integer;
  H: string;
begin
  Bytes := TEncoding.UTF8.GetBytes(S);

  SetLength(Result, Length(Bytes) * 3); // final string will be maximum 3 times the original bytes
  L := 1;
  for I := 0 to Length(Bytes) - 1 do
  begin
    B := Bytes[I];

    // Check if is unreserved char
    if ((B >= 65) and (B <= 90)) // A..Z
      or ((B >= 97) and (B <= 122)) // a..z
      or ((B >= 48) and (B <= 57)) //0..9
      or (B in [45, 46, 95, 126]) // - . _ ~
      or (B in [33, 39, 40, 41, 42]) then // ! ' ( ) *
    begin
      Result[L] := Chr(B);
      Inc(L);
    end else
    begin
      Result[L] := '%';
      H := IntToHex(B, 2);
      Result[L + 1] := H[1];
      Result[L + 2] := H[2];
      Inc(L, 3);
    end;
  end;
  SetLength(Result, L - 1);
end;

procedure AppendQueryParam(var Query: string; const Name, Value: string);
begin
  if Query <> '' then
    Query := Query + '&';
  Query := Query + PercentEncode(Name) + '=' + PercentEncode(Value);
end;

end.
