{ system2:3 $00E0..$0116, attributes$0120. Boolean result1, VAR file3;
  locals4 count,5 file pointer. Core0:7 advances this file. Its call may alter
  current-buffer pointer0, which must be read again afterward. }
function sys2_3(var f: sysfile): boolean;
var
  count: integer;
  fileptr: sysfptr;
begin
  sys2_3 := false;
  fileptr := @f;
  if fileptr^.current.bytes^[0] = 16 then
  begin
    sys0_7(f);
    count := fileptr^.current.bytes^[0] - 32;
    if odd(ord(count > 0) and ord(count <= 127)) then
    begin
      fileptr^.current.bytes^[0] := 32;
      fileptr^.words[14] := count;
      sys2_3 := true
    end
    else sys0_7(f)
  end
end;
