{ game_14 procedure7, $04E4..$058A, attributes $0596.
  Normalize only bytes greater than144 in the selected20-byte component span. }
procedure next_component_page;
var
  index: integer;
  width: integer;
  last: integer;
begin
  if not odd(g14.inventory_mode) then
  begin
    g14.selected_page := (g14.selected_page + 1) mod 3;
    if panel_action >= 11 then g14.selected_page := g14.selected_page + 3;
    g14.group_byte_base := 28 * g14.selected_page
  end;
  if g14.selected_page < 6 then
  begin
    data29.bytes[178 + (g14.group_byte_base + 25)] := 31;
    index := g14.group_byte_base;
    last := g14.group_byte_base + 19;
    while index <= last do
    begin
      if data29.bytes[178 + index] > 144 then data29.bytes[178 + index] := 7;
      index := index + 1
    end
  end;
  if odd(g14.cargo_mode) then draw_cargo_origin_list
  else
  begin
    apply_bounds(g14.caption_bounds, 8);
    width := 6 * length(g14.captions[g14.selected_page]);
    move_pen((g14.words[84] + g14.words[85] - width) div 2, g14.words[82]);
    draw_text(g14.captions[g14.selected_page])
  end;
  draw_component_grid;
  if not odd(g14.inventory_mode) then paint_component_status
end;
