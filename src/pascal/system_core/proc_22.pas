{ system_core0:22 $05DE..$05E6, attributes$05F0. File pointer1, no
  original locals. Store CR before calling8, even for a closed file.
  The extra pointer view accepts callers' raw file-header word0. }
procedure sys0_22(var f: integer);
var view: s6fview;
begin
  view.word := @f;
  view.fileptr^.current.bytes^[0] := 13;
  sys0_8(view.fileptr^)
end;
