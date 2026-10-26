{ startup_7 procedure5, $0142..$02B4, attributes $02BE; nested in1.
  Retain three unused local words. Library26 is recovered source; load of
  raw transform precedes switching to the play disk and graphics setup. }
procedure setup_play_graphics;
var unused: array[1..3] of integer;
begin
  data29.words[32] := 26;
  data29.words[30] := data29.words[32] + 16;
  data29.words[29] := data29.words[30] + 10;
  data29.words[28] := data29.words[29] + 9;
  data29.words[27] := data29.words[28] + 15;
  data29.words[26] := data29.words[27] + 9;
  assign_bounds(data29.bounds7, 0, 279, 0, 191);
  assign_bounds(data29.bounds3, 0, 139, 0, 95);
  use_linear_row_tables(true);
  apply_bounds(data29.bounds3, 8);
  use_linear_row_tables(false);
  data29.words[1] := 0;
  set_line_mode(0);
  move_pen(0, 0);
  set_glyph_mode(0);
  set_window_image_origin(0, 0);
  disk_blocks_io(s7.words[7], 1, s7.words[4], true);
  data29.words[16] := 4096;
  load_buffer_pair(0, 0, data29.words[16]);
  run_title_menu(true);
  request_disk_side(false);
  pop_text_window;
  assign_bounds(data29.bnd299, 72, 235, 0, 7);
  assign_bounds(data29.bnd343, 84, 223, 8, 103);
  assign_bounds(data29.bnd339, 4, 274, 120, 187);
  assign_bounds(data29.bnd335, 4, 71, 18, 115);
  assign_bounds(data29.bnd331, 236, 274, 18, 115);
  assign_bounds(data29.bnd307, 245, 265, 4, 13);
  assign_bounds(data29.bnd303, 14, 62, 4, 13);
  assign_bounds(data29.bounds327, 0, 0, 0, 0);
  assign_bounds(data29.fuel_gauge_bounds, data29.words[334] + 2, data29.words[334] + 8,
              data29.words[331] - 97, data29.words[331] - 33);
  assign_bounds(data29.weapon_gauge_bounds, data29.words[334] + 12, data29.words[334] + 18,
              data29.words[331] - 97, data29.words[331] - 33);
  assign_bounds(data29.shield_gauge_bounds, data29.words[334] + 22, data29.words[334] + 28,
              data29.words[331] - 97, data29.words[331] - 33);
  assign_bounds(data29.warp_gauge_bounds, data29.words[334] + 32, data29.words[334] + 38,
              data29.words[331] - 97, data29.words[331] - 33)
end;
