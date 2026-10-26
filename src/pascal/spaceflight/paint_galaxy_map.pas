{ game_13 procedure14, $06BE..$07EA, attributes $07FA; nested in13.
  Twelve system markers; the unused VAR parameter still occupies slot1.
  Capture each row pointer before drawing, retain the loop bound and all
  intervening mode/position calls. Every row adds a selection entry. }
procedure paint_galaxy_map(var unusedloc: g19loc);
var
  radius: integer; {2}
  unused3: integer;
  system_index: integer;  {4}
  unused5: array[5..8] of integer;
  ypos: integer;   {9}
  xpos: integer;   {10}
  unused11: integer;
  last: integer;   {12}
  world_row: g13rowptr;  {13}
begin
  reset_menu;
  if odd(redraw_flag) then
  begin
    apply_bounds(data29.bnd343, 8);
    set_line_mode(0)
  end;
  system_index := 1;
  last := 12;
  while system_index <= last do
  begin
    world_row.word := data29.words[23] + 20 * (system_index - 1);
    xpos := world_row.sysrow^.nibbles8[0] * 10 + 10;
    ypos := left_shift_word(world_row.sysrow^.nibbles8[1], 3) + 8;
    radius := 5 - right_shift_word(world_row.sysrow^.nibbles8[2], 1);
    if odd(redraw_flag) then
    begin
      set_line_mode(1);
      draw_circle(radius, data29.words[346] + xpos, data29.words[344] + ypos)
    end;
    if ((system_index = data29.loc73.low4) and odd(redraw_flag)) or
       (system_index = data29.warp_destination_system) then
    begin
      radius := radius + 4;
      set_line_mode(0);
      move_pen(data29.words[346] + xpos - radius,
                data29.words[344] + ypos - radius);
      if system_index = data29.warp_destination_system then
      begin
        if data29.flags82[0] then set_line_mode(9) else set_line_mode(8)
      end
      else set_line_mode(10);
      move_pen(data29.words[346] + xpos - radius,
                data29.words[344] + ypos + radius);
      move_pen(data29.words[346] + xpos + radius,
                data29.words[344] + ypos + radius);
      move_pen(data29.words[346] + xpos + radius,
                data29.words[344] + ypos - radius);
      move_pen(data29.words[346] + xpos - radius,
                data29.words[344] + ypos - radius)
    end;
    set_line_mode(0);
    add_menu_sprite(system_index, data29.words[298], xpos - 3, ypos + 3);
    system_index := system_index + 1
  end
end;
