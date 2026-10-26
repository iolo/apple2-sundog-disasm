{ system_core0:35 $0A88..$0AFE, attributes$0B0A. Character5, VAR index4,
  string pointer3, result1/2; locals6 configuration,7 controls. Extra s aliases
  the string. Config key word44 low byte clears the line; word43 low byte
  removes one character. Both consume the key even at index1. Decrement index
  before reading the removed byte; only bytes>=32 emit the erase sequence.
  Clear-line always finishes with control selector2, even for an empty line. }
function sys0_35(code: integer; var index: integer; var source: integer): boolean;
var config: ^s4config;
    control: ^s4ctrl;
    s: s0strptr;
begin
  sys0_35 := false;
  config := sy0e.state;
  control := @config^.control;
  s.word := @source;
  if code = config^.keys.bytes[14] then
  begin
    sys0_35 := true;
    while index > 1 do
    begin
      index := index - 1;
      if s.bytes^[index] >= 32 then
      begin
        sys0_19(sy0e.files2[1]^.words[0], sy0e.short521.text, 0);
        rtiochk
      end
    end;
    sys0_34(2, control^.bytes[3])
  end
  else if code = config^.keys.bytes[12] then
  begin
    sys0_35 := true;
    if index > 1 then
    begin
      index := index - 1;
      if s.bytes^[index] >= 32 then
      begin
        sys0_19(sy0e.files2[1]^.words[0], sy0e.short525.text, 0);
        rtiochk
      end
    end
  end
end;
