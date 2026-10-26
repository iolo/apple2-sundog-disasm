{ game_12 procedure8, $0476..$04CD, attributes $04D8; nested in1.
  Slots6..1: angle, distance, xbase, ybase, VAR xpos/ypos. Preserve output
  aliasing and the distance>=28 self EXIT before any coordinate call. }
procedure proc12_8(angle, distance, xbase, ybase: integer; var xpos, ypos: integer);
begin
  if distance >= 28 then
  begin
    g12.words[33] := 0;
    exit(proc12_8)
  end;
  angle := proc22_31(angle, 2);
  if angle < 0 then angle := 256 + angle
  else angle := proc22_32(angle, 255);
  proc24_4(angle, distance, xpos, ypos);
  xpos := xbase + xpos - 3;
  ypos := ybase + ypos + 3;
  proc22_12(xpos, ypos);
  proc22_11(1);
  proc22_9(g12.words[42])
end;
