{ game_20 procedure1, $1A12..$1A64, attributes $1A70.
  Load25/28 before setup. The original exit attribute targets the release
  epilogue at $1A53, which requires explicit binding in the game runtime. }
procedure proc20_1(arg1: integer);
var
(*$include src/pascal/game_20/locals.pas*)
(*$include src/pascal/game_20/proc_02.pas*)
(*$include src/pascal/game_20/proc_03.pas*)
(*$include src/pascal/game_20/proc_04.pas*)
(*$include src/pascal/game_20/proc_05.pas*)
(*$include src/pascal/game_20/proc_07.pas*)
(*$include src/pascal/game_20/proc_08.pas*)
(*$include src/pascal/game_20/proc_09.pas*)
(*$include src/pascal/game_20/proc_10.pas*)
(*$include src/pascal/game_20/proc_11.pas*)
(*$include src/pascal/game_20/proc_12.pas*)
(*$include src/pascal/game_20/proc_13.pas*)
(*$include src/pascal/game_20/proc_32.pas*)
(*$include src/pascal/game_20/proc_16.pas*)
(*$include src/pascal/game_20/proc_20.pas*)
(*$include src/pascal/game_20/proc_21.pas*)
(*$include src/pascal/game_20/proc_23.pas*)
(*$include src/pascal/game_20/proc_24.pas*)
(*$include src/pascal/game_20/proc_25.pas*)
(*$include src/pascal/game_20/proc_26.pas*)
(*$include src/pascal/game_20/proc_27.pas*)
(*$include src/pascal/game_20/proc_28.pas*)
begin
  rtldseg(25);
  rtldseg(28);
  proc20_32;
  proc20_28(arg1 = 4);
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := 6;
    data29.nibbles45[0] := 11
  end;
  data29.words[353] := g20.words[11];
  data29.words[351] := g20.words[4];
  if data29.nibbles45[2] <> 13 then proc22_52;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(28);
  rtrlseg(25)
end;
