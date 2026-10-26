{ game_15 procedure1, $0970..$0A29, attributes $0A3A.
  Load8/14/27 before setup. Preserve every input poll and the low-bit NEQ6
  transition test. Normal return writes nibble1 then releases27/14/8;
  the original exit attribute points at $0A13 and skips that nibble write.
  Nonlocal EXIT requires a binding to this release epilogue. }
procedure proc15_1;
var
(*$include src/pascal/game_15/locals.pas*)
(*$include src/pascal/game_15/proc_02.pas*)
(*$include src/pascal/game_15/proc_03.pas*)
(*$include src/pascal/game_15/proc_05.pas*)
(*$include src/pascal/game_15/proc_06.pas*)
(*$include src/pascal/game_15/proc_07.pas*)
(*$include src/pascal/game_15/proc_12.pas*)
(*$include src/pascal/game_15/proc_13.pas*)
(*$include src/pascal/game_15/proc_14.pas*)
(*$include src/pascal/game_15/proc_15.pas*)
(*$include src/pascal/game_15/proc_04.pas*)
(*$include src/pascal/game_15/proc_08.pas*)
(*$include src/pascal/game_15/proc_09.pas*)
(*$include src/pascal/game_15/proc_10.pas*)
(*$include src/pascal/game_15/proc_11.pas*)
(*$include src/pascal/game_15/proc_16.pas*)
begin
  rtldseg(8);
  rtldseg(14);
  rtldseg(27);
  g15.words[13] := 30;
  g15.text18 := 'SHIP';
  proc15_11;
  while (data29.nibbles45[2] = 2) or (data29.nibbles45[2] = 10) do
  begin
    if odd(proc22_2(4)) then proc15_13;
    proc22_43(g15.words[3], g15.words[2]);
    if odd(proc22_2(1)) or (data29.nibbles45[2] = 10) then
    begin
      proc15_15;
      proc8_1(0, 0);
      if data29.nibbles45[2] < 11 then proc15_11
    end;
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc24_9;
    if odd(proc22_2(4)) then proc15_13;
    if odd(proc22_2(4)) <> odd(g15.words[12]) then
    begin
      g15.words[12] := proc22_2(4);
      if not odd(g15.words[12]) then proc15_16
      else g15.words[4] := 0
    end
  end;
  data29.nibbles45[1] := 2;
  rtrlseg(27);
  rtrlseg(14);
  rtrlseg(8)
end;
