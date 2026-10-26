{ system_core0:34 $0A3E..$0A7C, attributes$0A86. Selector2, code1;
  local3 configuration pointer. For nonzero code, optionally emit the prefix
  selected by control word5's bit selector, then code, then ancestor name25.
  The original11>0 test at$0A6B is always true, independent of string length.
  Every output call has its own explicit CSP0 check. }
procedure rt_send_control(selector, code: integer);
var config: ^s4config;
begin
  config := sy0e.state;
  if code <> 0 then
  begin
    if config^.control.flags5[selector] then
    begin
      rt_write_character(sy0e.files2[1]^.words[0], config^.control.bytes[0], 0);
      rtiochk
    end;
    rt_write_character(sy0e.files2[1]^.words[0], code, 0);
    rtiochk;
    rt_write_string(sy0e.files2[1]^.words[0], sy0e.name25.text, 0);
    rtiochk
  end
end;
