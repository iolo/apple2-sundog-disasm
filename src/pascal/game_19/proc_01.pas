{ game_19 procedure1, $13AC..$140C, attributes $1418.
  Segment loads precede setup; normal cleanup precedes releases28/25.
  The original exit attribute targets the release epilogue at $13FB. }
procedure proc19_1(arg1: integer);
var
(*$include src/pascal/game_19/locals.pas*)
(*$include src/pascal/game_19/proc_02.pas*)
(*$include src/pascal/game_19/proc_03.pas*)
(*$include src/pascal/game_19/proc_04.pas*)
(*$include src/pascal/game_19/proc_05.pas*)
(*$include src/pascal/game_19/proc_06.pas*)
(*$include src/pascal/game_19/proc_08.pas*)
(*$include src/pascal/game_19/proc_26.pas*)
(*$include src/pascal/game_19/proc_07.pas*)
(*$include src/pascal/game_19/proc_09.pas*)
(*$include src/pascal/game_19/proc_10.pas*)
(*$include src/pascal/game_19/proc_11.pas*)
(*$include src/pascal/game_19/proc_12.pas*)
(*$include src/pascal/game_19/proc_15.pas*)
(*$include src/pascal/game_19/proc_16.pas*)
(*$include src/pascal/game_19/proc_17.pas*)
(*$include src/pascal/game_19/proc_18.pas*)
(*$include src/pascal/game_19/proc_20.pas*)
(*$include src/pascal/game_19/proc_21.pas*)
(*$include src/pascal/game_19/proc_24.pas*)
(*$include src/pascal/game_19/proc_25.pas*)
begin
  rtldseg(25);
  rtldseg(28);
  proc19_26;
  case arg1 of
    1: proc19_15;
    2: proc19_17;
    3: proc19_25
  end;
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := 6;
    data29.nibbles45[0] := 11
  end;
  data29.words[353] := g19.words[17];
  data29.words[351] := g19.words[16];
  proc22_52;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(28);
  rtrlseg(25)
end;
