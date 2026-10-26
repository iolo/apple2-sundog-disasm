{ system_core0:8 $0228..$0269, attributes$0274. File pointer1; original
  local7 file pointer; unused2..6 omitted. Clear IO first. Buffered system2:5
  supplies its own failure result; only direct UNITWRITE is followed by
  IORESULT here. Failure flags are written2 then1. Declaration: io_forwards.pas. }
(*$I-*)
procedure sys0_8;
label 900, 999;
var fileptr: sysfptr;
begin
  sy0e.state^.words[0] := 0;
  fileptr := @f;
  if not odd(fileptr^.words[5]) then
  begin
    sy0e.state^.words[0] := 13;
    goto 900
  end;
  if odd(fileptr^.words[29]) then
  begin
    if sys2_5(f) then goto 900
  end
  else
  begin
    unitwrite(fileptr^.words[7], fileptr^.current.bytes^[0],
              fileptr^.words[4], 0, 0);
    if ioresult <> 0 then goto 900
  end;
  goto 999;
900:
  fileptr^.words[2] := 1;
  fileptr^.words[1] := 1;
999:
end;
(*$I+*)
