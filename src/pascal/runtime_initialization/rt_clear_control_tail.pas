{ system4:4 $0060..$008C, attributes$0096; nested in3. VAR name1,
  local pointer2. Clamp ancestor control byte7 to11, write the length byte,
  then clear exactly that many characters, leaving the tail untouched. }
procedure rt_clear_control_tail(var name: s4str11);
var control: ^s4ctrl;
begin
  control := @syse.state^.control;
  if control^.bytes[7] > 11 then control^.bytes[7] := 11;
  name.bytes[0] := control^.bytes[7];
  fillchar(name.bytes[1], control^.bytes[7], 0)
end;
