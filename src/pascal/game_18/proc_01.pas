{ game_18 procedure1, $17F2..$183D, attributes $184C.
  Raw argument words4/3/2 denote caller-owned addresses; argument1 is a selector.
  Locals retain the original298-byte layout for nested access and frame copies.
  Runtime segment operations require the bindings in runtime_interfaces.pas. }
procedure proc18_1(arg4, arg3, arg2, arg1: integer);
var
(*$include src/pascal/game_18/locals.pas*)
(*$include src/pascal/game_18/proc_02.pas*)
(*$include src/pascal/game_18/proc_03.pas*)
(*$include src/pascal/game_18/proc_04.pas*)
(*$include src/pascal/game_18/proc_05.pas*)
(*$include src/pascal/game_18/proc_06.pas*)
(*$include src/pascal/game_18/proc_08.pas*)
(*$include src/pascal/game_18/proc_09.pas*)
(*$include src/pascal/game_18/proc_10.pas*)
(*$include src/pascal/game_18/proc_11.pas*)
(*$include src/pascal/game_18/proc_12.pas*)
(*$include src/pascal/game_18/proc_13.pas*)
(*$include src/pascal/game_18/proc_14.pas*)
(*$include src/pascal/game_18/proc_15.pas*)
(*$include src/pascal/game_18/proc_16.pas*)
(*$include src/pascal/game_18/proc_18.pas*)
(*$include src/pascal/game_18/proc_19.pas*)
(*$include src/pascal/game_18/proc_20.pas*)
(*$include src/pascal/game_18/proc_21.pas*)
(*$include src/pascal/game_18/proc_22.pas*)
(*$include src/pascal/game_18/proc_24.pas*)
(*$include src/pascal/game_18/proc_25.pas*)
(*$include src/pascal/game_18/proc_23.pas*)
(*$include src/pascal/game_18/proc_26.pas*)
(*$include src/pascal/game_18/proc_27.pas*)
(*$include src/pascal/game_18/proc_28.pas*)
begin
  rtldseg(8);
  rtldseg(27);
  proc18_21;
  repeat
    proc18_26;
    proc18_27;
    proc18_28;
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc22_29;
    if odd(data29.words[347]) then proc18_23(false)
  until odd(g18a133[143]);
  proc22_41(g18a133[134], g18a133[133]);
  proc18_22;
  { Original exit-attribute target $182D begins this release epilogue.
    A runtime binding must preserve that target for nonlocal EXIT as well. }
  rtrlseg(27);
  rtrlseg(8)
end;
