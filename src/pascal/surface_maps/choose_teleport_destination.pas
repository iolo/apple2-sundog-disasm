{ game_21 procedure33, $17B4..$1843, attributes $1850.
  Nested34 uses the bases at slots5/4. Input1 must execute even when input0
  chose a cell. Snapshot chosen before input1, then reread it after the loop. }
procedure choose_teleport_destination(var chosen: integer);
var
  picked_row: integer;         {2}
  picked_column: integer;      {3}
  view_y_base: integer;       {4}
  view_x_base: integer;       {5}
  selection_snapshot: integer;
  input1: integer;
(*$include src/pascal/surface_maps/toggle_teleport_cursor.pas*)
(*$include src/pascal/surface_maps/read_teleport_cursor.pas*)
begin
  chosen := 0;
  picked_column := 0;
  picked_row := 0;
  view_x_base := 7 * (data29.words[14] div 7) + 10;
  view_y_base := 8 * (data29.words[12] div 8) + 12;
  data29.bits38.low6 := map_x_origin + g21.player_x div 28;
  data29.bits39.low5 := map_y_origin + g21.player_y div g21.tile_height_pixels;
  paint_city_overview(view_x_base, view_y_base, data29.bits38.low6, data29.bits39.low5);
  toggle_teleport_cursor(picked_column, picked_row);
  repeat
    read_teleport_cursor(picked_column, picked_row);
    chosen := poll_input(0);
    selection_snapshot := chosen;
    input1 := poll_input(1)
  until odd(selection_snapshot) or odd(input1);
  if odd(chosen) then
  begin
    data29.words[40] := 0;
    data29.bytes[80] := 13;
    data29.bits38.low6 := picked_column + 10;
    data29.bits39.low5 := picked_row + 6
  end
end;
