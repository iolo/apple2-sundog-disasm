{ game_20 procedure28, $18FE..$19A7, attributes $19B4.
  The early EXIT after setup bypasses procedure7. Nested31 writes suffix. }
procedure proc20_28(haspods: boolean);
var
  mode: integer;       {2}
  choice: integer;     {3}
  suffix: text15;      {4..11}
(*$include src/pascal/game_20/proc_29.pas*)
(*$include src/pascal/game_20/proc_30.pas*)
(*$include src/pascal/game_20/proc_31.pas*)
begin
  g20.words[17] := ord(haspods);
  proc20_5;
  if data29.nibbles45[2] = 13 then exit(proc20_28);
  g20.words[6] := data29.words[14];
  g20.words[5] := data29.words[11];
  if odd(g20.words[17]) then mode := 0 else mode := 1;
  proc20_31;
  for choice := 0 to 7 do proc20_21(choice);
  choice := 0;
  g20.words[7] := 0;
  repeat
    if ((choice > 0) and (choice < 4)) or (choice = 5) then proc20_31;
    proc20_30(mode, choice);
    case choice of
      0: if odd(g20.words[17]) and (mode = 1) then
         begin
           choice := 6;
           mode := 0
         end;
      1: proc20_27(g20.words[7] div 21);
      2: proc20_25;
      3, 5: proc20_13;
      4: mode := 1
    end
  until (choice = 0) or odd(data29.words[347]);
  proc20_7
end;
