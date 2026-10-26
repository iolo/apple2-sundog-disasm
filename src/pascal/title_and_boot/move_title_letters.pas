{ Both library26 variants: procedure16, $007E..$01AC, attributes $01BE;
  nested in13. Preserve animation/sound calls and the two independent flag
  updates: the second can clear the flag set by the first. }
procedure move_title_letters;
var
  border_index: integer; {1}
  frame_ticks: integer; {2}
  tone_step: integer; {3}
  restore_x: integer; {4}
  letter_x: integer; {5}
  anim_phase: integer; {6}
  letter_index: integer; {7}
  unused: integer; {8}
  restore_active: integer; {9}
  moving_left: integer; {10}
  last_index: integer; {11}
begin
  border_index := 0;
  last_index := 13;
  while border_index <= last_index do
  begin
    paint_title_border_column(border_index * 2 * 7, 44 - 12, 170);
    paint_title_border_column((border_index * 2 + 1) * 7, 44 - 12, 213);
    border_index := border_index + 1
  end;
  paint_title_border_column(28 * 7, 44 - 12, 170);
  paint_title_border_column(29 * 7, 44 - 12, 0);
  save_title_strip(left_x, right_x, top_y, bottom_y, saved_strip);
  letter_index := 0;
  last_index := 5;
  while letter_index <= last_index do
  begin
    anim_phase := 0;
    letter_x := letter_path[letter_index].second;
    restore_x := letter_x + 21;
    tone_step := 0;
    frame_ticks := 0;
    moving_left := 1;
    restore_active := 0;
    unused := 0;
    repeat
      tone_step := tone_step + 1;
      play_sound(1, 10 + (7 - letter_index) * 30 - tone_step * 2, 10, 0, 0, 1, 0);
      if odd(moving_left) or (anim_phase < 8) then
      begin
        if anim_phase = 8 then blit_title_letter(letter_index, 7, letter_x, 44)
        else blit_title_letter(letter_index, anim_phase, letter_x, 44);
        if letter_x > letter_path[letter_index].first then letter_x := letter_x - 14
        else moving_left := 0
      end;
      if odd(restore_active) then
      begin
        restore_title_column(left_x, right_x, top_y, bottom_y, saved_strip, restore_x);
        restore_x := restore_x - 7
      end;
      if letter_x = letter_path[letter_index].second - 28 then restore_active := 1;
      if restore_x = letter_path[letter_index].first + 21 then restore_active := 0;
      frame_ticks := frame_ticks + 1;
      if (anim_phase < 8) and (frame_ticks = 2) then
      begin
        frame_ticks := 0;
        anim_phase := anim_phase + 1
      end
    until (restore_x = letter_path[letter_index].first + 21) and (anim_phase = 8);
    letter_index := letter_index + 1
  end
end;
