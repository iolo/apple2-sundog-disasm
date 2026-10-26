{ game_14 procedure1, $08DA..$09C5, attributes $09D4.
  VAR action is slot3; two value words are slots2/1. Retain204 local bytes.
  The outer loop changes the selected page; the inner loop polls input and
  updates the clock. No segment-load or release epilogue occurs here. }
procedure proc14_1(var action: integer; arg2, arg1: integer);
var
  g14: g14frame;
(*$include src/pascal/game_14/proc_02.pas*)
(*$include src/pascal/game_14/proc_03.pas*)
(*$include src/pascal/game_14/proc_04.pas*)
(*$include src/pascal/game_14/proc_05.pas*)
(*$include src/pascal/game_14/proc_06.pas*)
(*$include src/pascal/game_14/proc_07.pas*)
(*$include src/pascal/game_14/proc_08.pas*)
(*$include src/pascal/game_14/proc_09.pas*)
(*$include src/pascal/game_14/proc_11.pas*)
(*$include src/pascal/game_14/proc_12.pas*)
begin
  proc14_3(action);
  proc27_6(0);
  repeat
    proc14_7;
    g14.words[105] := 0;
    proc22_42(g14.words[8], g14.words[7], 2, data31.bounds2);
    repeat
      data29.words[354] := data29.words[354] + 1;
      if data29.words[354] >= data29.words[353] then
      begin
        proc22_41(g14.words[8], g14.words[7]);
        proc14_9(0, 0, 0, false);
        proc22_42(g14.words[8], g14.words[7], 2, data31.bounds2)
      end;
      proc22_43(g14.words[8], g14.words[7]);
      if odd(proc22_2(0)) then
      begin
        proc22_41(g14.words[8], g14.words[7]);
        proc27_8(g14.words[8], g14.words[7], g14.words[6], g14.words[5]);
        if g14.words[6] = 3 then g14.words[105] := 1
        else if g14.words[6] > 6 then
        begin
          proc27_10(g14.words[6]);
          proc14_12(g14.words[5], 0)
        end;
        proc22_42(g14.words[8], g14.words[7], 2, data31.bounds2)
      end;
      g14.words[102] := proc22_2(1)
    until odd(g14.words[102]) or odd(g14.words[105]) or odd(data29.words[347]);
    proc22_41(g14.words[8], g14.words[7])
  until odd(g14.words[102]) or odd(data29.words[347]);
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    if data29.nibbles45[2] = 5 then data29.nibbles45[1] := data29.nibbles45[0]
    else data29.nibbles45[1] := 8;
    data29.nibbles45[0] := 11
  end;
  proc22_52;
  if action >= 8 then action := 8 + g14.words[9]
end;
