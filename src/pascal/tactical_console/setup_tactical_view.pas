{ game_12 procedure9, $04DA..$085D, attributes $0874; nested in1.
  Setup retains all conditional initialization and raw pointer construction.
  At $06FC..$06FD the original pushes integer45 as a STRING ADDRESS to22:48,
  not a glyph or literal. Preserve that raw read via the otherwise temporary
  loop-bound slot3; do not silently replace it with a character call. }
procedure setup_tactical_view;
var
  column: integer; {1}
  work: integer;   {2}
  limit: g12scratch; {3}
begin
  data29.nibbles45[2] := 1;
  select_drawing_buffer(1024, true);
  swap_tactical_buffers;
  g12.display_level := data29.bytes[178 + 108];
  g12.weapon_base_range := (5 + data29.bytes[94 + 2]) div 10 + 1;
  g12.radar_glyph := 125;
  g12.pointer_glyph := 93;
  g12.menu_mode := 0;
  if data29.flags82[122] then work := 256 else work := 0;
  g12.laser_beam_style := 0 + work;
  g12.cannon_beam_style := 1 + work;
  g12.target_present := ord(data29.flags82[40]);
  if odd(g12.target_present) then apply_bounds(data29.bnd303, 9);
  g12.laser_selected := 1;
  g12.manual_mode := 0;
  g12.target_visible := 0;
  g12.view_x_origin := data29.words[346] + 70 - 4;
  g12.view_y_origin := data29.words[344] + 48 + 3;
  data29.flags82[5] := false;
  g12.saved_flight_mode := data29.map_view_kind;
  data29.map_view_kind := 0;
  g12.target_glyph_base := left_shift_word(data29.target_class, 5);
  g12.words[46] := 96;
  g12.words[47] := 0;
  data29.flags82[36] := false;
  g12.wreck_cargo_present := 0;
  if not data29.flags82[35] then
  begin
    if data29.flags82[19] then
    begin
      data29.words[206] := 448 + word_and(random_word, 127);
      data29.words[205] := 448 + word_and(random_word, 127);
      g12.back_y_offset := right_shift_word(data29.words[206], 2);
      g12.back_x_offset := right_shift_word(data29.words[205], 2)
    end
    else
    begin
      g12.back_y_offset := data29.pos72.fields.w0low;
      g12.back_x_offset := 128
    end;
    store_word(word_address(g12.back_y_offset), g12.background_address);
    if (data29.pos72.fields.xcoord = 0) and (g12.display_level > 1) then
      call_sky_overlay(g12.background_address, 2518)
    else apply_bounds(data29.bnd343, 8);
    if not odd(g12.target_present) then
    begin
      work := 41;
      limit.word := 47;
      while work <= limit.word do
      begin
        data29.flags82[work] := false;
        work := work + 1
      end
    end;
    update_flight_state;
    apply_bounds(data29.bnd339, 8);
    set_line_mode(1);
    draw_circle(28, 42, 152);
    draw_circle(28, 105, 152);
    set_line_mode(0);
    move_pen(42 - 18, 152 - 21);
    set_line_mode(10);
    move_pen(42, 152);
    move_pen(42 + 18 + 1, 152 - 21);
    set_line_mode(0);
    move_pen(105 - 23, 152 - 16);
    set_line_mode(9);
    move_pen(105, 152);
    move_pen(105 - 23, 152 + 16);
    set_line_mode(0);
    update_flight_state;
    set_text_window(105 + 28 + 4, data29.words[341], data29.words[340], data29.words[339]);
    clear_text_window;
    set_glyph_mode(3);
    write_text_glyph(43);
    column := 1;
    limit.word := 20;
    while column <= limit.word do
    begin
      write_text_glyph(44);
      column := column + 1
    end;
    limit.word := 45;
    write_wrapped_text(limit.caption^);
    work := 1;
    limit.word := 6;
    while work <= limit.word do
    begin
      set_text_grid_position(0, 1 + 2 * work);
      write_text_glyph(75);
      set_text_grid_position(21, 1 + 2 * work);
      write_text_glyph(77);
      work := work + 1
    end;
    set_text_grid_position(0, 15);
    write_text_glyph(107);
    column := 1;
    limit.word := 20;
    while column <= limit.word do
    begin
      write_text_glyph(108);
      column := column + 1
    end;
    draw_glyph(109);
    update_flight_state
  end
  else
  begin
    data29.flags82[35] := false;
    data29.flags82[44] := false;
    if data29.flags82[49] then
    begin
      data29.flags82[49] := false;
      data29.target_motion_ticks := 128;
      data29.words[207] := 2
    end
    else if data29.flags82[51] then
    begin
      g12.words[28] := 1;
      g12.words[14] := 6;
      data29.flags82[51] := false
    end
    else data29.flags82[44] := true;
    data29.flags82[41] := false;
    data29.flags82[47] := true;
    g12.back_x_offset := data29.bytes[540 + 16];
    g12.back_y_offset := data29.bytes[540 + 17];
    store_word(word_address(g12.back_y_offset), g12.background_address)
  end;
  setup_sensor_panel;
  g12.radar_visible := 0;
  g12.radar_interval := right_shift_word(data29.words[353], 1);
  if odd(g12.target_present) then
  begin
    apply_bounds(data29.bnd339, 0);
    set_glyph_mode(1);
    if g12.display_level > 4 then
    begin
      g12.radar_visible := 1;
      work := right_shift_word(data29.target_range, 2);
      draw_radar_contact(data29.words[206] + 256, work, 42, 152, g12.left_x, g12.left_y);
      draw_radar_contact(-data29.words[205], work, 105, 152, g12.right_x, g12.right_y)
    end
  end
  else data29.flags82[41] := false;
  g12.words[11] := 0;
  set_window_image_origin(data29.words[344], data29.words[346] div 7)
end;
