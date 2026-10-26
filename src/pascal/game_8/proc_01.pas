{ game_8 procedure1, $0B54..$0C05, attributes $0C12.
  Complete enclosing scope and entry body. Child3/16 may EXIT this procedure,
  intentionally bypassing the normal final call to18. Arguments occupy2/1. }
procedure proc8_1(arg2, arg1: integer);
var
(*$include src/pascal/game_8/locals.pas*)
(*$include src/pascal/game_8/proc_02.pas*)
(*$include src/pascal/game_8/proc_05.pas*)
(*$include src/pascal/game_8/proc_06.pas*)
(*$include src/pascal/game_8/proc_07.pas*)
(*$include src/pascal/game_8/proc_08.pas*)
(*$include src/pascal/game_8/proc_09.pas*)
(*$include src/pascal/game_8/proc_18.pas*)
(*$include src/pascal/game_8/proc_03.pas*)
(*$include src/pascal/game_8/proc_10.pas*)
(*$include src/pascal/game_8/proc_11.pas*)
(*$include src/pascal/game_8/proc_12.pas*)
(*$include src/pascal/game_8/proc_13.pas*)
(*$include src/pascal/game_8/proc_14.pas*)
(*$include src/pascal/game_8/proc_15.pas*)
(*$include src/pascal/game_8/proc_16.pas*)
(*$include src/pascal/game_8/proc_17.pas*)
begin
  proc8_8;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc8_3(false, true);
    proc22_43(g8a3[13], g8a3[12]);
    if odd(proc22_2(0)) then begin
      proc22_41(g8a3[13], g8a3[12]);
      proc27_8(g8a3[13], g8a3[12], g8a3[11], g8a3[10]);
      if g8a3[10] = data31.words[13] then proc8_14
      else if g8a3[11] = 1 then proc8_16(g8a3[19])
      else if g8a3[11] = 4 then proc8_12
      else if g8a3[11] = 5 then proc8_13
      else if g8a3[11] = 6 then proc8_15
      else if g8a3[11] > 6 then begin
        proc27_10(g8a3[11]);
        proc8_10(g8a3[10])
      end else if proc8_5(g8a3[13], g8a3[12], g8b26) then proc8_17;
      proc22_42(g8a3[13], g8a3[12], 2, data31.bounds2)
    end;
    if data29.nibbles45[2] = 10 then begin
      proc22_41(g8a3[13], g8a3[12]);
      proc8_17;
      proc22_41(g8a3[13], g8a3[12])
    end
  until odd(proc22_2(1)) or odd(g8a3[19]);
  proc8_18
end;
