{ system_core0:22 $05DE..$05E6, attributes$05F0. File pointer1, no
  original locals. Store CR before calling8, even for a closed file.
  The extra pointer view accepts callers' raw file-header word0. }
procedure rt_write_newline(var f: integer);
var view: s6fview;
begin
  view.word := @f;
  view.fileptr^.current.bytes^[0] := 13;
  rt_put_file_element(view.fileptr^)
end;
