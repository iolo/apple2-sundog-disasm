{ system_core0:30 $08AC..$08CB, attributes$08D6. No parameters/locals.
  Control selector4 takes the high byte of configuration word31. Then emit
  characters5 and14 to the ancestor console, each followed by CSP0. }
procedure rt_emit_console_setup;
begin
  rt_send_control(4, sy0e.state^.control.bytes[1]);
  rt_write_character(sy0e.files2[1]^.words[0], 5, 0); rtiochk;
  rt_write_character(sy0e.files2[1]^.words[0], 14, 0); rtiochk
end;
