{ game_17 procedure3, $001E..$003B, attributes $0044. }
procedure toggle_fighter_glyph(index: integer);
begin
  with g17.items[index] do
  begin
    set_glyph_mode(1);
    move_pen(first, second);
    draw_glyph(draw)
  end
end;
