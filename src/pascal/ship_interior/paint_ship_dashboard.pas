{ game_15 procedure4, $0080..$020D, attributes $0218.
  Retain drawing/state-update order and the four original label literals. }
procedure paint_ship_dashboard;
var
  value: integer;
begin
  clear_hires_page1;
  use_linear_row_tables(false);
  apply_bounds(data29.bounds7, 10);
  assign_bounds(data29.bounds327, 128, 186, 107, 116);
  assign_bounds(data29.bnd307, 245, 265, 4, 13);
  assign_bounds(data29.bnd303, 14, 62, 4, 13);
  draw_framed_bounds(data29.bnd331, 8);
  write_vertical_label(data29.fuel_gauge_bounds, 'FUEL');
  write_vertical_label(data29.weapon_gauge_bounds, 'GUNS');
  write_vertical_label(data29.shield_gauge_bounds, 'SHLD');
  write_vertical_label(data29.warp_gauge_bounds, 'WARP');
  draw_framed_bounds(data29.bnd335, 8);
  set_clip_bounds(data29.words[346] - 7, data29.words[345] + 7,
            data29.words[344] - 8, data29.words[343] + 8);
  draw_clip_pattern(9);
  draw_framed_bounds(data29.bnd343, 8);
  draw_framed_bounds(data29.bnd339, 8);
  if data29.flags82[40] then apply_bounds(data29.bnd303, 9)
  else apply_bounds(data29.bnd303, 5);
  set_clip_bounds(data29.words[330] - 7, data29.words[329] + 9,
            data29.words[328], data29.words[335] + 1);
  draw_clip_pattern(8);
  set_clip_bounds(data29.words[330] - 7, data29.words[329] + 7,
            data29.words[328], data29.words[327]);
  draw_clip_pattern(8);
  move_pen(data29.words[330] + 3, data29.words[327]);
  draw_clock(data29.clock42);
  draw_vertical_gauge(data29.fuel_gauge_bounds, data29.fuel_amount, 8, 10);
  draw_vertical_gauge(data29.weapon_gauge_bounds, data29.weapon_charge, 4, 6);
  draw_vertical_gauge(data29.shield_gauge_bounds, data29.shield_charge, 4, 5);
  draw_vertical_gauge(data29.warp_gauge_bounds, data29.warp_charge, 8, 9);
  apply_bounds(data29.bnd307, 8);
  if not data29.flags82[1] then
  begin
    if data29.loc73.mid5 > 0 then value := 0
    else value := left_shift_word(data29.bytes[143] + 7, 1);
    set_glyph_mode(3);
    move_pen(data29.words[310] + 2, data29.words[307]);
    draw_integer(value, 3, true)
  end;
  update_flight_state
end;
