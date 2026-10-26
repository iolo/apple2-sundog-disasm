{ game_21 procedure15, $06D8..$0775, attributes $077E.
  Both distance calls execute before the combined rejection. The adjusted
  saved parent15 value is retained even though this body never reads it again. }
procedure try_board_ship(var changed: integer);
var
  xpos, ypos, saved, xradius, yradius: integer;
  nearx, neary: boolean;
begin
  changed := 0;
  project_map_location(xpos, ypos, data29.pos72);
  saved := g21.ship_x_offset;
  if not data29.flags45[13] then
  begin
    if g21.even_glyph <> 16 then exit(try_board_ship);
    xpos := xpos + 7;
    saved := saved + 7;
    xradius := 6;
    yradius := 4
  end
  else
  begin
    xradius := 4;
    yradius := 4
  end;
  nearx := within_axis_radius(g21.player_x, xpos, xradius);
  neary := within_axis_radius(g21.player_y, ypos, yradius);
  if not nearx or not neary then exit(try_board_ship);
  changed := 1;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.flags45[12] := data29.flags45[13];
  if data29.flags45[13] then data29.nibbles45[2] := 2
  else
  begin
    data29.nibbles45[2] := 2;
    data29.flags82[7] := true;
    data29.words[294] := data29.words[296]
  end
end;
