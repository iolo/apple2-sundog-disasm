{ system5:1 $05A6..$0664, attributes$066E. Integer result1, mode3;
  original lexical level0, parameter bytes6, local bytes4. Slot4 is unused;
  status occupies original slot5. No child accesses that local by offset.
  This function expresses the segment entry's RBP1 behavior; an ordinary
  Pascal host compiles it as a nested RNP1 function, so the original segment
  entry ABI and runtime ancestor link remain binding requirements.
  sy5e aliases that ancestor: depth1 here, depth2 in children.
  Successful attach returns4; startup/named code returns3; otherwise0.
  The three self-EXITs target$0664, with no extra cleanup. }
function sys5_1(mode: integer): integer;
var outcome: integer;
(*$include src/pascal/system_5/proc_02.pas*)
(*$include src/pascal/system_5/proc_03.pas*)
(*$include src/pascal/system_5/proc_04.pas*)
(*$include src/pascal/system_5/proc_05.pas*)
(*$include src/pascal/system_5/proc_07.pas*)
(*$include src/pascal/system_5/proc_08.pas*)
(*$include src/pascal/system_5/proc_09.pas*)
(*$include src/pascal/system_5/proc_10.pas*)
begin
  sys5_1 := 0;
  sy5e.common.file9^.words[2] := 0;
  sy5e.common.file8^.words[2] := 0;
  sy5e.common.file7^.words[2] := 0;
  sy5e.common.files2[0] := sy5e.common.file9;
  sy5e.common.files2[1] := sy5e.common.file8;
  if mode = 0 then
    if odd(sy5e.common.words[229]) then
    begin
      sy5e.common.words[229] := 0;
      if sys5_10('*SYSTEM.ATTACH', 0, 0, false, outcome, true) then
      begin
        sys5_1 := 4;
        exit(sys5_1)
      end
    end;
  if mode = 4 then mode := 0;
  if mode = 0 then
    if sys5_10('*SYSTEM.STARTUP', 0, 0, true, outcome, false) then
    begin
      sys0_31;
      sys5_1 := 3;
      exit(sys5_1)
    end;
  if length(sy5e.common.name173) > 0 then
  begin
    sys5_2(sy5e.common.words[173], false, 23);
    if sys5_10(sy5e.common.name173, 0, 0, true, outcome, false) then
    begin
      sys5_1 := 3;
      exit(sys5_1)
    end
  end
end;
