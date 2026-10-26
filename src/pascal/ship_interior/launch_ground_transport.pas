{ game_15 procedure7, $027A..$02DB, attributes $02E6.
  Byte507 then506 are word254's high/low packed fields. Preserve the order
  and the complete six-word location copy from228 to36. }
procedure launch_ground_transport;
begin
  data29.nibbles45[2] := 3;
  data29.nibbles45[1] := 2;
  data29.flags45[13] := false;
  data29.flags45[12] := true;
  data29.words[294] := data29.words[295];
  data29.flags82[7] := false;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  data29.bytes[507] := 16;
  data29.bytes[506] := 17;
  data29.words[292] := 8;
  data29.pos36 := data29.pos228;
  g15.selected_action := 0
end;
