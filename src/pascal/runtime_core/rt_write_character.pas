{ system_core0:17 $048A..$04B4, attributes$04C0. File pointer3,
  character2, width1; local4 file pointer. Emit width-1 spaces, then the
  low character byte. The open flag is tested once; padding continues after
  errors, as in the original. Unlike core8, the closed path only sets IO13. }
procedure rt_write_character(var f: integer; code, width: integer);
var view: s6fview;
begin
  view.word := @f;
  if odd(view.fileptr^.words[5]) then
  begin
    while width > 1 do
    begin
      view.fileptr^.current.bytes^[0] := 32;
      rt_put_file_element(view.fileptr^);
      width := width - 1
    end;
    view.fileptr^.current.bytes^[0] := code;
    rt_put_file_element(view.fileptr^)
  end
  else sy0e.state^.words[0] := 13
end;
