{ game_17 procedure1, $0D64..$0D9B, attributes $0DA6.
  Startup passes addresses of caller slots4,3,1. VAR declarations retain the
  original six parameter bytes and all caller aliasing. Preserve the196-byte
  parent frame and the physical child11/12 frames used by save/restore. }
procedure proc17_1(var arg3, arg2, arg1: integer);
var
(*$include src/pascal/game_17/locals.pas*)
(*$include src/pascal/game_17/proc_02.pas*)
(*$include src/pascal/game_17/proc_03.pas*)
(*$include src/pascal/game_17/proc_04.pas*)
(*$include src/pascal/game_17/proc_05.pas*)
(*$include src/pascal/game_17/proc_06.pas*)
(*$include src/pascal/game_17/proc_07.pas*)
(*$include src/pascal/game_17/proc_08.pas*)
(*$include src/pascal/game_17/proc_09.pas*)
(*$include src/pascal/game_17/proc_10.pas*)
(*$include src/pascal/game_17/proc_13.pas*)
(*$include src/pascal/game_17/proc_14.pas*)
(*$include src/pascal/game_17/proc_15.pas*)
(*$include src/pascal/game_17/proc_11.pas*)
(*$include src/pascal/game_17/proc_12.pas*)
(*$include src/pascal/game_17/proc_16.pas*)
(*$include src/pascal/game_17/proc_17.pas*)
begin
  proc17_11;
  if arg1 = 0 then proc17_15(true);
  proc22_42(g17.words[98], g17.words[97], 2, data29.bounds11);
  while not odd(g17.words[42]) or odd(data29.words[347]) do
  begin
    proc17_16;
    proc17_17
  end;
  if odd(g17.words[39]) then proc17_15(true);
  proc22_41(g17.words[98], g17.words[97]);
  proc17_12
end;
