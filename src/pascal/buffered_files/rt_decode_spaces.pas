{ system2:3 $00E0..$0116, attributes$0120. Boolean result1, VAR file3;
  locals4 count,5 file pointer. Core0:7 advances this file. Its call may alter
  current-buffer pointer0, which must be read again afterward. }
function rt_decode_spaces(var f: sysfile): boolean;
var
  count: integer;
  fileptr: sysfptr;
begin
  rt_decode_spaces := false;
  fileptr := @f;
  if fileptr^.current.bytes^[0] = 16 then
  begin
    rt_get_file_element(f);
    count := fileptr^.current.bytes^[0] - 32;
    if odd(ord(count > 0) and ord(count <= 127)) then
    begin
      fileptr^.current.bytes^[0] := 32;
      fileptr^.words[14] := count;
      rt_decode_spaces := true
    end
    else rt_get_file_element(f)
  end
end;
