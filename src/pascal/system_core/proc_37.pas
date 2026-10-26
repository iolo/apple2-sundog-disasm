{ system_core0:37 $0B72..$0B97, attributes$0BA4. No parameters; two unused
  local words omitted. Release the ancestor heap marker before checking the
  configured device name. On mismatch, error2(12) precedes loader6:9; retain
  that call/loop even though the recovered error routine normally never returns.
  Loader result is discarded. Each iteration rereads the configuration pointer. }
procedure sys0_37;
begin
  release(sy0e.heap5);
  while sy0e.units31[sy0e.state^.words[2]].caption <> sy0e.name14 do
  begin
    sys0_2(12);
    if sys6_9(sy0e.state^.words[2]) then begin end
  end
end;
