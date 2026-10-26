{ library_25 procedure9, $00C6..$016F, attributes $0178.
  Nested in6; parent slots6/7 are offsets and8/9 are caption coordinates. }
procedure paint_menu_button(item_index: integer);
begin
  with data30.items[item_index] do
  begin
    set_glyph_mode(3);
    set_clip_bounds(origin_x + bounds.lower_first - 2,
              origin_x + bounds.upper_first + 2,
              origin_y + bounds.lower_second - 2,
              origin_y + bounds.upper_second + 2);
    draw_clip_pattern(10);
    set_clip_bounds(origin_x + bounds.lower_first,
              origin_x + bounds.upper_first,
              origin_y + bounds.lower_second,
              origin_y + bounds.upper_second);
    draw_clip_pattern(8);
    caption_x := bounds.lower_first +
      (1 + bounds.upper_first - bounds.lower_first
       - 6 * length(data30.captions[tag.caption])) div 2;
    caption_y := bounds.upper_second -
      (1 + bounds.upper_second - bounds.lower_second - 8) div 2;
    move_pen(origin_x + caption_x, origin_y + caption_y);
    draw_text(data30.captions[tag.caption])
  end
end;
