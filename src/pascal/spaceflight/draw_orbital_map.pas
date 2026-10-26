{ game_13 procedure15, $07FC..$09F2, attributes $0A00; nested in13.
  System planet range is written into grandparent12 slots8(start)/7(end).
  Preserve both loops, the captured planet row and all drawing mode changes.
  The one-word row temporary15 also supplies raw system-row views before
  the planet loop; its extra private assignments have no external observer. }
procedure draw_orbital_map(var system_place: g19loc);
var
  index: integer;  {2}
  planet: integer; {3}
  system_index: integer; {4}
  yoffset: integer; {5}
  xoffset: integer; {6}
  ycenter: integer; {7}
  xcenter: integer; {8}
  marker_heading: integer; {9}
  marker_radius: integer;  {10}
  ypos: integer;   {11}
  xpos: integer;   {12}
  same: boolean;   {13}
  last: integer;   {14}
  world_row: g13rowptr;  {15}
begin
  reset_menu;
  system_index := system_place.fields.system;
  if odd(redraw_flag) then
  begin
    apply_bounds(data29.bnd343, 8);
    set_line_mode(0);
    set_glyph_mode(0)
  end;
  xcenter := right_shift_word(data29.words[345] - data29.words[346], 1);
  ycenter := right_shift_word(data29.words[343] - data29.words[344], 1);
  same := data29.loc73.low4 = system_index;
  if odd(redraw_flag) then
  begin
    move_pen(data29.words[346] + xcenter - 3,
              data29.words[344] + ycenter + 3);
    draw_glyph(0)
  end;
  world_row.word := data29.words[23] + 20 * (system_index - 1);
  mapstate[8] := world_row.sysrow^.bits5.mid5;
  world_row.word := data29.words[23] + 20 * (system_index - 1);
  mapstate[7] := mapstate[8] + world_row.sysrow^.bits5.low2 - 1;
  index := 1;
  planet := mapstate[8];
  last := mapstate[7];
  while planet <= last do
  begin
    world_row.word := data29.words[24] + 16 * (planet - 1);
    project_polar_point(world_row.planetrow^.coords6.low, world_row.planetrow^.coords6.high,
              xpos, ypos);
    xpos := xcenter + xpos - 3;
    ypos := ycenter + ypos + 3;
    if odd(redraw_flag) then
    begin
      set_line_mode(1);
      draw_circle(world_row.planetrow^.coords6.high,
                data29.words[346] + xcenter, data29.words[344] + ycenter);
      set_line_mode(0);
      set_glyph_mode(0);
      move_pen(data29.words[346] + xpos, data29.words[344] + ypos);
      draw_glyph(1)
    end;
    add_menu_sprite(index, 1, xpos, ypos);
    index := index + 1;
    planet := planet + 1
  end;
  marker_radius := 43;
  marker_heading := 0;
  set_glyph_mode(1);
  index := 1;
  last := 16;
  while index <= last do
  begin
    project_polar_point(marker_heading, marker_radius, xoffset, yoffset);
    if odd(redraw_flag) then
    begin
      move_pen(data29.words[346] + xcenter + xoffset - 3,
                data29.words[344] + ycenter + yoffset + 3);
      draw_glyph(43)
    end;
    add_menu_sprite(marker_heading, 43, xcenter + xoffset - 3, ycenter + yoffset + 3);
    marker_heading := marker_heading + 16;
    index := index + 1
  end;
  if same and odd(redraw_flag) then
  begin
    project_polar_point(data29.pos72.fields.w0low, data29.pos72.fields.w0high,
              xpos, ypos);
    xpos := xcenter + xpos;
    ypos := ycenter + ypos;
    move_pen(data29.words[346] + xpos - 3, data29.words[344] + ypos + 3);
    set_glyph_mode(1);
    draw_glyph(data29.words[294]);
    move_pen(data29.words[346] + xpos - 3, data29.words[344] + ypos + 3);
    if data29.loc73.mid5 > 0 then draw_glyph(1)
    else if (data29.pos72.fields.w0high = 43) and
            (data29.pos72.fields.w0low mod 16 = 0) then draw_glyph(43)
  end;
  set_line_mode(0);
  set_glyph_mode(0)
end;
