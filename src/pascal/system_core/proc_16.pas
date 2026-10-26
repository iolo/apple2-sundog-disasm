{ system_core0:16 $0456..$047D, attributes$0488. File pointer2,
  VAR result1; local3 file pointer. Read current byte, advancing before it
  when mode3=1 and after it when mode3=0. Reread mode after storing the result:
  the output argument can alias file storage. No early IO-error return. }
procedure sys0_16(var f: sysfile; var value: integer);
var fileptr: sysfptr;
begin
  fileptr := @f;
  sy0e.state^.words[0] := 0;
  if fileptr^.words[3] = 1 then sys0_7(f);
  value := fileptr^.current.bytes^[0];
  if fileptr^.words[3] = 0 then sys0_7(f)
  else fileptr^.words[3] := 1
end;
