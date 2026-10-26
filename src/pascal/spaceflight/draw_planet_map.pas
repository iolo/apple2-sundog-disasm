{ game_13 procedure16, $0A2E..$0C19, attributes $0C28; nested in13.
  The value location occupies copied slots2..7; the full16-byte planet row
  is copied to16..23 after the initial calls. City count and loop index are
  grandparent12 slots7/6. Special final entry60 retains its original code
  calculation relative to the planet's first city, even outside the count.
  Temporary25 supplies the initial row copy, then the captured city pointer. }
procedure draw_planet_map(planet_place: g19loc);
var
  city: integer;   {8}
  ypos: integer;   {9}
  xpos: integer;   {10}
  visible: boolean; {11}
  special: boolean; {12}
  flag31: boolean;  {13}
  known: boolean;   {14}
  same: boolean;    {15}
  planet_row: g19planet; {16..23}
  last: integer;    {24}
  world_row: g13rowptr;   {25}
(*$include src/pascal/spaceflight/planet_grid_to_pixel.pas*)
begin
  reset_menu;
  set_window_image_origin(data29.words[344], data29.words[346] div 7);
  world_row.word := data29.words[24] + 16 * (planet_place.fields.planet - 1);
  planet_row := world_row.planetrow^;
  if odd(redraw_flag) then
  begin
    apply_bounds(data29.bnd343, 8);
    set_line_mode(10);
    draw_circle(45, data29.words[346] + 50, data29.words[344] + 48);
    set_line_mode(0);
    set_line_mode(10);
    draw_circle(45, data29.words[346] + 91, data29.words[344] + 48);
    set_line_mode(0);
    set_clip_bounds(data29.words[346] + 40, data29.words[346] + 100,
              data29.words[344] + 8, data29.words[344] + 88);
    draw_clip_pattern(8)
  end;
  same := (data29.loc73.low4 = planet_place.fields.system) and
          (data29.loc73.mid5 = planet_place.fields.planet);
  flag31 := data29.flags82[31];
  known := same and data29.flags82[21] and (not flag31);
  special := (planet_place.fields.planet = 1) and known and data29.flags82[113];
  planet_grid_to_pixel(41, 3, xpos, ypos);
  if odd(redraw_flag) then
  begin
    xpos := xpos + data29.words[346];
    ypos := ypos + data29.words[344];
    apply_bounds(data29.bnd343, 0);
    if (data29.pos72.fields.city = 0) and same then
    begin
      move_pen(word_and(xpos - 2, 254), ypos + 4);
      draw_glyph(data29.words[294])
    end
  end;
  set_glyph_mode(1);
  set_line_mode(0);
  city := planet_row.place7.mid6;
  mapstate[7] := planet_row.place7.low9 mod 8;
  if special then mapstate[7] := mapstate[7] + 1;
  mapstate[6] := 1;
  last := mapstate[7];
  while mapstate[6] <= last do
  begin
    if (mapstate[6] = mapstate[7]) and special then city := 60;
    visible := (city = planet_row.place7.mid6) or known or flag31;
    world_row.word := data29.words[25] + 12 * (city - 1);
    planet_grid_to_pixel(world_row.cityrow^.coords5.low6, world_row.cityrow^.coords5.mid5,
                xpos, ypos);
    if odd(redraw_flag) then
    begin
      move_pen(word_and(data29.words[346] + xpos, 254),
                data29.words[344] + ypos);
      if visible then draw_glyph(30) else draw_glyph(32);
      if (city = data29.pos72.fields.city) and same then
        draw_glyph(data29.words[294])
    end;
    if visible then
      add_menu_sprite(city - planet_row.place7.mid6 + 1, 30, xpos, ypos);
    city := city + 1;
    mapstate[6] := mapstate[6] + 1
  end;
  apply_bounds(data29.bnd343, 0)
end;
