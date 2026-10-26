{ game_16 procedure1, $1BB8..$1C9F, attributes $1CB2.
  Load27/28 before setup; normal return cleans up then releases28/27. The
  original exit attribute targets $1C8F, skipping47 on nonlocal EXIT; binding
  must preserve that release epilogue. Unused slots25/142 hold both initial
  input results so neither call is short-circuited; the278-byte frame remains. }
procedure proc16_1(arg3, arg2, arg1: integer);
var
(*$include src/pascal/game_16/locals.pas*)
(*$include src/pascal/game_16/proc_02.pas*)
(*$include src/pascal/game_16/proc_03.pas*)
(*$include src/pascal/game_16/proc_04.pas*)
(*$include src/pascal/game_16/proc_05.pas*)
(*$include src/pascal/game_16/proc_06.pas*)
(*$include src/pascal/game_16/proc_07.pas*)
(*$include src/pascal/game_16/proc_12.pas*)
(*$include src/pascal/game_16/proc_15.pas*)
(*$include src/pascal/game_16/proc_30.pas*)
(*$include src/pascal/game_16/proc_31.pas*)
(*$include src/pascal/game_16/proc_32.pas*)
(*$include src/pascal/game_16/proc_35.pas*)
(*$include src/pascal/game_16/proc_40.pas*)
(*$include src/pascal/game_16/proc_44.pas*)
(*$include src/pascal/game_16/proc_45.pas*)
(*$include src/pascal/game_16/proc_46.pas*)
(*$include src/pascal/game_16/proc_47.pas*)
(*$include src/pascal/game_16/proc_48.pas*)
(*$include src/pascal/game_16/proc_08.pas*)
(*$include src/pascal/game_16/proc_11.pas*)
(*$include src/pascal/game_16/proc_13.pas*)
(*$include src/pascal/game_16/proc_16.pas*)
(*$include src/pascal/game_16/proc_17.pas*)
(*$include src/pascal/game_16/proc_23.pas*)
(*$include src/pascal/game_16/proc_33.pas*)
(*$include src/pascal/game_16/proc_34.pas*)
(*$include src/pascal/game_16/proc_37.pas*)
(*$include src/pascal/game_16/proc_41.pas*)
begin
  rtldseg(27);
  rtldseg(28);
  proc16_37;
  repeat
    g16.words[25] := proc22_2(0);
    g16.words[142] := proc22_2(1)
  until not (odd(g16.words[25]) or odd(g16.words[142]));
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      proc16_30;
      g16.words[43] := g16.words[43] - 1;
      if g16.words[43] <= 0 then proc16_34(g16.words[99], 1)
    end;
    proc22_43(g16.words[13], g16.words[12]);
    if odd(proc22_2(0)) then
    begin
      g16.words[23] := 0;
      if odd(g16.words[22]) then
      begin
        proc16_35(g16.words[13], g16.words[12], g16.words[44], g16.words[23]);
        if odd(g16.words[23]) then proc16_34(g16.words[44], 1)
      end;
      if not (odd(g16.words[24]) or odd(g16.words[23])) then
      begin
        proc27_8(g16.words[13], g16.words[12], g16.words[11], g16.words[10]);
        if g16.words[11] = 4 then proc16_45
        else if g16.words[11] = 5 then proc16_46
        else if g16.words[11] > 6 then
        begin
          if odd(g16.words[19]) and
             ((g16.words[10] > data31.words[10]) or odd(g16.words[18])) then
          begin
            proc27_10(g16.words[11]);
            g16.words[41] := g16.words[11];
            proc16_34(g16.words[95 + ord(proc16_48)], 1)
          end
          else
          begin
            proc16_5(g16.words[11], g16.words[10]);
            proc16_41(g16.words[10], 0)
          end
        end
      end
    end
    else if odd(proc22_2(1)) then proc16_34(g16.words[98], 1)
  until odd(g16.words[24]) or odd(data29.words[347]);
  proc16_47;
  rtrlseg(28);
  rtrlseg(27)
end;
