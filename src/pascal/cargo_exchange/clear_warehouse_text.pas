{ game_20 procedure14, $0822..$084B, attributes $0854; nested in13.
  Reads enclosing row/column slots6/7, not procedure15's unused arguments. }
procedure clear_warehouse_text;
begin
  set_clip_bounds(data29.words[14], data29.words[13], text_row - 8, data29.words[11]);
  draw_clip_pattern(8);
  apply_bounds(data29.bounds11, 0);
  data29.text_x := text_column;
  data29.text_y := text_row
end;
