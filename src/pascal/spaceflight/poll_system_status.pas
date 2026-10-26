{ game_13 procedure10, $04D8..$0613, attributes $0620; nested in3.
  First input1 poll may self-EXIT before display updates; second poll always
  runs before the word347 test. Typed NEQ6 comparisons use only flag bit0. }
procedure poll_system_status;
begin
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      update_flight_state;
      draw_system_bars;
      write_location_label(10, 13, data29.pos72)
    end;
    if odd(poll_input(1)) then exit(poll_system_status);
    if (g13s.warp_state > 0) and not data29.flags82[0] then
    begin
      g13s.warp_state := 0;
      apply_bounds(g13s.warp_button_bounds, 8);
      apply_bounds(data29.bounds11, 0);
      set_text_grid_position(13, 6);
      write_wrapped_text('no charge');
      blank_text_row(10, 15);
      write_wrapped_text('(none)')
    end
    else if (g13s.warp_state = 1) and (data29.warp_charge >= data29.warp_setting) then
    begin
      g13s.warp_state := 2;
      apply_bounds(g13s.warp_button_bounds, 8);
      set_text_grid_position(13, 6);
      write_wrapped_text('charged');
      g13s.words[16] := g13s.words[16] - 6;
      apply_bounds(g13s.warp_button_bounds, 3);
      apply_bounds(data29.bounds11, 0)
    end;
    if odd(g13s.sublight_active) <> data29.flags82[1] then
    begin
      g13s.sublight_active := 0;
      apply_bounds(g13s.engine_button_bounds, 8);
      set_text_grid_position(13, 8);
      write_wrapped_text('power off');
      blank_text_row(10, 17);
      write_wrapped_text('(none)')
    end;
    if odd(g13s.rescue_visible) <> data29.flags82[25] then
    begin
      g13s.rescue_visible := 0;
      set_text_grid_position(0, 20);
      set_clip_bounds(data29.text_x, data29.text_x + 126,
                data29.text_y - 7, data29.text_y);
      draw_clip_pattern(8);
      apply_bounds(data29.bounds11, 0)
    end
  until odd(poll_input(1)) or odd(data29.words[347])
end;
