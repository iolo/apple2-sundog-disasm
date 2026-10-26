{ game_13 procedure27, $1F94..$1FEF, attributes $1FFA; nested in1.
  Preserve six local bytes: saved flag3, four-byte native packet at4/5.
  Child35's fifth packet byte is outside the declared frame (see its comment).
  CASE uses action-4 in signed16-bit arithmetic. Copies run even for an
  out-of-range action or a child32/36/39 error return. }
procedure proc13_27(action: integer; var targetloc: g19loc);
var
  saved22: integer;
  packet: g13packet;
(*$include src/pascal/game_13/proc_28.pas*)
(*$include src/pascal/game_13/proc_29.pas*)
(*$include src/pascal/game_13/proc_31.pas*)
(*$include src/pascal/game_13/proc_32.pas*)
(*$include src/pascal/game_13/proc_34.pas*)
(*$include src/pascal/game_13/proc_35.pas*)
(*$include src/pascal/game_13/proc_36.pas*)
(*$include src/pascal/game_13/proc_38.pas*)
(*$include src/pascal/game_13/proc_39.pas*)
begin
  proc24_9;
  saved22 := ord(data29.flags82[22]);
  case action - 4 of
    0: proc13_39(targetloc);
    1: proc13_38;
    2: proc13_36(targetloc);
    3: proc13_35;
    4: proc13_32(targetloc);
    5: proc13_34
  end;
  data29.pos36 := data29.pos72;
  if data29.flags82[7] then data29.pos228 := data29.pos72
end;
