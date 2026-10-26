{ system_core0:31 $08D8..$0905, attributes$0910. No parameters;
  locals1 configuration,2 control pointer. Capture configuration AFTER30,
  clear unit3 without an extra IO check, then choose control selector3 with
  word32's low byte or selector6 with word35's high byte. }
(*$I-*)
procedure rt_reset_console;
var config: ^s4config;
    control: ^s4ctrl;
begin
  rt_emit_console_setup;
  config := sy0e.state;
  control := @config^.control;
  unitclear(3);
  if control^.bytes[2] <> 0 then rt_send_control(3, control^.bytes[2])
  else rt_send_control(6, control^.bytes[9])
end;
(*$I+*)
