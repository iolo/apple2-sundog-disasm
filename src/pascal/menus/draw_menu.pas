{ library_25 procedure6, $017A..$01D4, attributes $01E0.
  Preserve slots6..9 for its nested child. The value-copy bounds occupy2..5. }
procedure draw_menu(area: bounds4);
var
  origin_y: integer; {6}
  origin_x: integer;  {7}
  caption_y: integer; {8}
  caption_x: integer;  {9}
  index: integer;      {10}
  item_count: integer;       {11}
(*$include src/pascal/menus/paint_menu_button.pas*)
begin
  apply_bounds(area, 0);
  set_line_mode(0);
  origin_x := area.lower_first;
  origin_y := area.lower_second;
  index := 1;
  item_count := data30.nitems;
  while index <= item_count do
  begin
    if data30.items[index].tag.button then paint_menu_button(index)
    else
      with data30.items[index] do
      begin
        set_glyph_mode(0);
        move_pen(origin_x + words[3], origin_y + words[2]);
        draw_glyph(words[1])
      end;
    index := index + 1
  end
end;
