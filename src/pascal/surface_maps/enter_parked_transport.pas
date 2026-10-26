{ game_21 procedure16, $0780..$07D8, attributes $07E2.
  Both proximity calls run; copy their combined output through parent arg1,
  then reread it. These VAR references may alias. }
procedure enter_parked_transport(var changed: integer);
var
  xpos, ypos: integer;
  nearx, neary: boolean;
begin
  changed := 0;
  project_map_location(xpos, ypos, data29.pos228);
  nearx := within_axis_radius(g21.player_x, xpos, 4);
  neary := within_axis_radius(g21.player_y, ypos, 4);
  changed := ord(nearx and neary);
  exit_requested := changed;
  if odd(exit_requested) then
  begin
    toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
    data29.nibbles45[1] := 5;
    data29.flags45[12] := false;
    data29.flags45[13] := false;
    toggle_surface_player;
    data29.rec36 := data29.rec228
  end
end;
