{ game_19 procedure13, $06C8..$0703, attributes $070C; nested in12.
  Parent work at24 selects city/planet/system; placename occupies8..15. }
procedure write_transport_place(caption: text15; place_index: integer);
var
  row: integer;
begin
  lookup_place_caption(selector_or_cost, place_index, destination_name);
  row := 5 + 2 * selector_or_cost;
  set_text_grid_position(0, row);
  write_wrapped_text(caption);
  set_text_grid_position(22 - length(destination_name), row);
  write_wrapped_text(destination_name);
  selector_or_cost := selector_or_cost + 1
end;
