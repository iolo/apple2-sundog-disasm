{ system_core0:31 $08D8..$0905, attributes$0910. No parameters;
  locals1 configuration,2 control pointer. Capture configuration AFTER30,
  clear unit3 without an extra IO check, then choose control selector3 with
  word32's low byte or selector6 with word35's high byte. }
(*$I-*)
procedure sys0_31;
var config: ^s4config;
    control: ^s4ctrl;
begin
  sys0_30;
  config := sy0e.state;
  control := @config^.control;
  unitclear(3);
  if control^.bytes[2] <> 0 then sys0_34(3, control^.bytes[2])
  else sys0_34(6, control^.bytes[9])
end;
(*$I+*)
