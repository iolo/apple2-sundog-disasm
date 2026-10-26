{ game_12 procedure22, $1272..$1349, attributes $1356; nested in1.
  Transition packet byte stores truncate to8 bits. Flag47 with a target
  present produces no message or transition. }
procedure hail_target_ship;
begin
  if data29.flags82[40] and not data29.flags82[47] then
  begin
    g12.exit_requested := 1;
    data29.nibbles45[2] := 9;
    data29.nibbles45[1] := 1;
    apply_bounds(data29.bnd339, 0);
    set_glyph_mode(1);
    data29.bytes[540 + 8] := 0;
    data29.bytes[540 + 9] := 0;
    data29.bytes[540 + 11] := data29.target_class + 1;
    data29.flags82[35] := true;
    data29.flags82[44] := true;
    data29.flags82[48] := false;
    data29.flags82[49] := false;
    data29.flags82[50] := false;
    if odd(g12.radar_visible) then
    begin
      move_pen(g12.left_x, g12.left_y);
      draw_glyph(g12.radar_glyph);
      move_pen(g12.right_x, g12.right_y);
      draw_glyph(g12.radar_glyph)
    end;
    data29.bytes[540 + 16] := g12.back_x_offset;
    data29.bytes[540 + 17] := g12.back_y_offset
  end
  else if not data29.flags82[40] then
  begin
    swap_tactical_buffers;
    clear_text_window;
    write_wrapped_text('No ship to hail');
    swap_tactical_buffers
  end
end;
