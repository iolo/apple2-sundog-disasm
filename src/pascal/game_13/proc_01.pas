{ game_13 procedure1, entry $2586, body $2588..$2759, load $2762..$2768,
  release epilogue $275A..$2760, return $276A; attributes $277A.
  Load12/25 before setup and release25/12 on normal return. The original exit
  attribute targets the release epilogue, so nonlocal EXIT needs that runtime
  binding. The reference compiler's external segment calls do not supply it.
  Eight local words retain the frame shared by all52 procedures.
  Tactical proc12_1 has no arguments/result (game_12 attributes $1578).
  Include its recovered entry and children before this scope. }
procedure proc13_1;
var raw13: array[1..8] of integer;
(*$include src/pascal/game_13/proc_02.pas*)
(*$include src/pascal/game_13/proc_03.pas*)
(*$include src/pascal/game_13/proc_12.pas*)
(*$include src/pascal/game_13/proc_27.pas*)
(*$include src/pascal/game_13/proc_42.pas*)
(*$include src/pascal/game_13/proc_43.pas*)
(*$include src/pascal/game_13/proc_44.pas*)
(*$include src/pascal/game_13/proc_45.pas*)
(*$include src/pascal/game_13/proc_46.pas*)
(*$include src/pascal/game_13/proc_47.pas*)
(*$include src/pascal/game_13/proc_50.pas*)
(*$include src/pascal/game_13/proc_51.pas*)
(*$include src/pascal/game_13/proc_52.pas*)
begin
  rtldseg(12);
  rtldseg(25);
  proc24_9;
  if not data29.flags82[35] then
    proc13_12(data29.words[203], data29.pos72, raw13[4], 1, 1);
  raw13[4] := ord(data29.nibbles45[1] <> 9);
  if data29.flags82[51] and data29.flags82[34] then
  begin
    proc13_52;
    raw13[4] := 1
  end;
  data29.flags82[34] := false;
  if data29.nibbles45[2] <> 1 then data29.flags82[35] := false;
  data29.flags82[51] := false;
  proc22_53(2048, 2, data29.words[27] + 2, true);
  proc13_2;
  data29.flags82[118] := false;
  data29.flags82[119] := false;
  if data29.nibbles45[2] = 1 then
  begin
    raw13[3] := 3;
    data29.nibbles45[2] := 0
  end
  else raw13[3] := 0;
  data29.words[353] := 5;
  repeat
    if odd(raw13[4]) then proc22_19(data29.bnd335, 8)
    else proc22_19(data29.bnd335, 0);
    raw13[4] := 0;
    proc22_50(data29.words[342], data29.words[341],
                data29.words[340], data29.words[339]);
    if raw13[3] = 0 then
    begin
      proc13_51;
      proc13_45(raw13[3], raw13[2], data29.words[297], data29.bnd335, raw13[4])
    end;
    if (not odd(raw13[4])) and (not odd(data29.words[347])) then
      data29.nibbles45[2] := 2;
    case raw13[3] of
      1: proc13_3;
      2: proc13_47;
      3: begin
           data29.nibbles45[0] := data29.nibbles45[1];
           data29.nibbles45[1] := 0;
           proc12_1;
           if data29.nibbles45[2] <> 9 then
             proc13_12(data29.words[203], data29.pos72, raw13[4], 1, 1)
         end;
      4: begin
           data29.nibbles45[2] := 9;
           proc22_4(10, 100, 40, 252, 1, 7, 0);
           data29.flags82[34] := true
         end
    end;
    raw13[3] := 0
  until (data29.nibbles45[2] <> 0) or odd(data29.words[347]);
  if not data29.flags82[35] then data29.nibbles45[1] := 0;
  if data29.nibbles45[2] <> 9 then data29.flags82[5] := false;
  data29.nibbles45[0] := 11;
  data29.flags45[12] := true;
  proc22_20(1, 1, 2048);
  if (data29.nibbles45[2] <> 1) and (data29.nibbles45[2] <> 9) then
    if (data29.nibbles45[2] = 10) and odd(data29.words[347]) then
      data29.nibbles45[2] := 2;
  rtrlseg(25);
  rtrlseg(12)
end;
