{ game_12 procedure11, $09BE..$09E8, attributes $09F2; nested in1. }
procedure flash_target_hit;
begin
  if odd(g12.target_visible) and (g12.display_level > 1) then
  begin
    move_pen(g12.view_x_origin + g12.target_x_offset + 1, g12.view_y_origin + g12.target_y_offset);
    set_glyph_mode(0);
    swap_tactical_buffers;
    draw_glyph(42);
    swap_tactical_buffers
  end
end;
