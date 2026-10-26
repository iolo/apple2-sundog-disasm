{ game_21 procedure1, $1E48..$1F5B, attributes $1F6E.
  Load8/27/23 before setup; release23/27/8 on exit. The original exit
  attribute targets $1F45: nonlocal EXIT needs the same runtime epilogue.
  NEQ6 at $1E96 compares bit0, not full input words. The encounter predicate
  captures mode/flag before the unconditional random call and reads parent35
  afterward. Previously unused parent slot24 holds the random result without
  changing the114-byte parent frame or child lexical offsets. }
procedure proc21_1(var arg8, arg7, arg6, arg5, arg4, arg3, arg2, arg1: integer);
var
(*$include src/pascal/game_21/locals.pas*)
(*$include src/pascal/game_21/proc_02.pas*)
(*$include src/pascal/game_21/proc_03.pas*)
(*$include src/pascal/game_21/proc_05.pas*)
(*$include src/pascal/game_21/proc_06.pas*)
(*$include src/pascal/game_21/proc_07.pas*)
(*$include src/pascal/game_21/proc_08.pas*)
(*$include src/pascal/game_21/proc_09.pas*)
(*$include src/pascal/game_21/proc_10.pas*)
(*$include src/pascal/game_21/proc_11.pas*)
(*$include src/pascal/game_21/proc_12.pas*)
(*$include src/pascal/game_21/proc_13.pas*)
(*$include src/pascal/game_21/proc_14.pas*)
(*$include src/pascal/game_21/proc_15.pas*)
(*$include src/pascal/game_21/proc_16.pas*)
(*$include src/pascal/game_21/proc_17.pas*)
(*$include src/pascal/game_21/proc_18.pas*)
(*$include src/pascal/game_21/proc_19.pas*)
(*$include src/pascal/game_21/proc_21.pas*)
(*$include src/pascal/game_21/proc_22.pas*)
(*$include src/pascal/game_21/proc_23.pas*)
(*$include src/pascal/game_21/proc_25.pas*)
(*$include src/pascal/game_21/proc_26.pas*)
(*$include src/pascal/game_21/proc_27.pas*)
(*$include src/pascal/game_21/proc_28.pas*)
(*$include src/pascal/game_21/proc_29.pas*)
(*$include src/pascal/game_21/proc_30.pas*)
(*$include src/pascal/game_21/proc_31.pas*)
(*$include src/pascal/game_21/proc_32.pas*)
(*$include src/pascal/game_21/proc_33.pas*)
(*$include src/pascal/game_21/proc_36.pas*)
(*$include src/pascal/game_21/proc_37.pas*)
(*$include src/pascal/game_21/proc_38.pas*)
(*$include src/pascal/game_21/proc_40.pas*)
(*$include src/pascal/game_21/proc_41.pas*)
begin
  rtldseg(8);
  rtldseg(27);
  rtldseg(23);
  proc21_30;
  repeat
    proc22_43(g21.words[19], g21.words[18]);
    if odd(proc22_2(1)) then
    begin
      data29.nibbles45[1] := data29.nibbles45[2];
      data29.flags45[12] := data29.flags45[13];
      if data29.flags45[13] then proc21_41 else arg1 := 1
    end
    else
    begin
      g21.words[36] := proc22_2(4);
      if odd(g21.words[36]) then proc21_12;
      if odd(g21.words[38]) <> odd(g21.words[36]) then
      begin
        g21.words[38] := g21.words[36];
        if odd(g21.words[38]) then
        begin
          data29.words[353] := g21.words[58];
          data29.words[351] := g21.words[57]
        end
        else
        begin
          data29.words[351] := 1;
          data29.words[353] := 15;
          proc21_21;
          if odd(g21.words[34]) then proc21_38
        end
      end;
      if (data29.nibbles45[1] <> data29.nibbles45[2]) and
         ((data29.nibbles45[2] = 3) or (data29.nibbles45[2] = 4)) then proc21_30;
      data29.words[354] := data29.words[354] + 1;
      if data29.words[354] >= data29.words[353] then
      begin
        proc22_29;
        if (data29.nibbles45[2] = 3) and data29.flags45[13] then
        begin
          g21.words[24] := proc22_3;
          if (g21.words[24] mod 64 = 21) and not odd(g21.words[35]) then
          begin
            proc22_41(g21.words[19], g21.words[18]);
            proc21_40;
            proc22_41(g21.words[19], g21.words[18])
          end
        end
        else g21.words[24] := proc22_3
      end
    end
  until (data29.nibbles45[2] <> data29.nibbles45[1]) or
        odd(data29.words[347]) or odd(arg1);
  proc21_6;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(23);
  rtrlseg(27);
  rtrlseg(8)
end;
