{ game_8 procedure9, $0378..$039E, attributes $03A8. }
procedure lift_inventory_item(index: integer);
begin
  draw_empty_item_marker(index);
  select_drawing_buffer(0, false);
  personal_state[5] := 0;
  personal_state[4] := index;
  replace_panel_item(personal_state[5], index, personal_state[3], personal_state[7], personal_state[6]);
  select_drawing_buffer(0, false)
end;
