{ game_21 procedure40, $1B9C..$1DF0, attributes $1DFC.
  Retain map-byte write then modulo write through arg2, low-bit counter gate,
  cursor erase/retry/redraw order, and conditional second random call.
  The original48-byte local frame is retained; unused slot5 holds randomv. }
procedure evade_street_pursuer;
var
  deltay: integer;       {1}
  deltax: integer;
  oldy: integer;
  oldx: integer;
  random_value: integer;
  unused6: integer;
  chase_count: integer;        {7}
  pursuer_y: integer;
  pursuer_x: integer;
  cursor_y: integer;
  cursor_x: integer;
  player_y: integer;
  player_x_or_mode: integer;        {13}
  top: integer;
  left: integer;
  view_y: integer;
  view_x: integer;
  pursuer_glyph: integer;
  mask: integer;
  player_glyph: integer;    {20}
  move_every_tick: boolean;
  unused22: integer;
  unused23: integer;
  caught: boolean;       {24}
begin
  tile_or_action := g21.map_buffer.rows^[(map_y_origin + (g21.player_y - 3) div g21.tile_height_pixels) mod 24]
                        [(map_x_origin + (g21.player_x + 3) div 28) mod 40];
  tile_or_action := tile_or_action mod 16;
  if tile_or_action < 2 then exit(evade_street_pursuer);
  view_x := g21.player_x div 7 - 10;
  clamp_word(0, view_x, 20);
  view_y := g21.player_y - 48;
  clamp_word(0, view_y, 96);
  set_window_image_origin(view_y, view_x);
  window_image_transfer(2);
  left := g21.player_x - 40;
  clamp_word(10, left, 199);
  top := g21.player_y - 30;
  clamp_word(10, top, 131);
  set_clip_bounds(left, left + 80, top, top + 60);
  draw_clip_pattern(11);
  set_clip_bounds(left + 2, left + 78, top + 1, top + 59);
  draw_clip_pattern(8);
  initialize_pointer(cursor_x, cursor_y, data29.words[298], g21.pointer_bounds);
  player_x_or_mode := left + 37;
  player_y := top + 33;
  pursuer_x := player_x_or_mode;
  pursuer_y := player_y;
  random_value := random_word;
  case random_value mod 4 of
    0: pursuer_x := left + 3;
    1: pursuer_y := top + 10;
    2: pursuer_x := left + 70;
    3: pursuer_y := top + 55
  end;
  player_glyph := 22;
  mask := 24;
  pursuer_glyph := 23;
  chase_count := 32767;
  set_glyph_mode(1);
  move_pen(player_x_or_mode, player_y);
  draw_glyph(player_glyph);
  move_pen(pursuer_x, pursuer_y);
  draw_glyph(pursuer_glyph);
  data29.words[2] := 8;
  caught := false;
  random_value := random_word;
  move_every_tick := random_value mod 3 = 0;
  repeat
    update_pointer(cursor_x, cursor_y);
    if odd(poll_input(4)) then
      step_glyph_pair(player_glyph, mask, word_sign(cursor_x - player_x_or_mode),
                  word_sign(cursor_y - player_y), player_x_or_mode, player_y);
    chase_count := chase_count - 1;
    if odd(chase_count) or move_every_tick then
    begin
      oldx := pursuer_x;
      oldy := pursuer_y;
      deltax := player_x_or_mode - pursuer_x;
      deltay := player_y - pursuer_y;
      step_glyph_pair(pursuer_glyph, mask, word_sign(deltax), word_sign(deltay), pursuer_x, pursuer_y);
      if (oldx = pursuer_x) and (oldy = pursuer_y) then
      begin
        toggle_pointer_glyph(cursor_x, cursor_y);
        step_glyph_pair(pursuer_glyph, mask, word_sign(deltax), word_sign(deltay), pursuer_x, pursuer_y);
        if (oldx = pursuer_x) and (oldy = pursuer_y) then caught := true;
        toggle_pointer_glyph(cursor_x, cursor_y)
      end
    end
  until (player_x_or_mode < left + 3) or (player_x_or_mode > left + 71) or
        (player_y < top + 9) or (player_y > top + 57) or caught;
  toggle_pointer_glyph(cursor_x, cursor_y);
  window_image_transfer(0);
  data29.words[2] := 9;
  if caught then
  begin
    data29.nibbles45[2] := 5;
    data29.nibbles45[1] := 3;
    data29.words[292] := 4 + 3 * word_sign((pursuer_x - player_x_or_mode) div 3) +
                                  word_sign((pursuer_y - player_y) div 3);
    random_value := random_word;
    if (random_value mod 16 > g21.chase_threshold) and (tile_or_action < 12) then player_x_or_mode := 16
    else
    begin
      random_value := random_word;
      if random_value mod 3 = 0 then player_x_or_mode := 22 else player_x_or_mode := 18
    end;
    data29.ground_encounter_mode := player_x_or_mode;
    tile_or_action := 255
  end
end;
