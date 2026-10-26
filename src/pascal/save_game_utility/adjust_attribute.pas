{ utility_disk1:29 $0E04..$1007, attributes$101C. VAR selection1,32 local
  bytes. Locals2 direction,3/4 cursor y/x,5 saved points,6 candidate points,
  7 rejected value,8 edited value,9 next selection,10 minimum,11..14 arrow
  coordinates,15 unused poll result,16 selection-found flag,17 bar pointer.
  Direction2 is initially unspecified and may be read when input1 is set.
  Integer masks retain the eager poll4 in the adjustment test and all full-word
  input results. Keep the unused poll at$0FA6 and reject candidate points <=0. }
procedure adjust_attribute(var stat_index: integer);
var stat_adjustment: u29frame;
begin
  if stat_index < 4 then stat_adjustment.minimum_value := 30
  else stat_adjustment.minimum_value := 0;
  stat_adjustment.candidate_points := data29.bytes[94 + stat_index];
  stat_adjustment.selection_found := 0;
  stat_editor.done_poll := 0;
  stat_adjustment.edited_value := stat_adjustment.candidate_points;
  stat_adjustment.next_stat := 0;
  stat_adjustment.saved_points := stat_editor.unspent_points;
  draw_attribute_bar(stat_index, 9);
  stat_adjustment.bar := @stat_editor.bars[stat_index];
  apply_bounds(data29.bounds11, 0);
  move_pen(stat_adjustment.bar^.lower_first - 7, stat_adjustment.bar^.upper_second + 1);
  draw_glyph(38);
  stat_adjustment.minus_x := stat_adjustment.bar^.lower_first - 7 + 3;
  stat_adjustment.minus_y := stat_adjustment.bar^.upper_second + 1 - 3;
  move_pen(stat_adjustment.bar^.upper_first + 2, stat_adjustment.bar^.upper_second + 2);
  draw_glyph(96);
  stat_adjustment.plus_x := stat_adjustment.bar^.upper_first + 2 + 3;
  stat_adjustment.plus_y := stat_adjustment.bar^.upper_second + 1 - 3;
  draw_integer(stat_adjustment.edited_value, 3, false);
  while not odd(poll_input(4)) do begin end;
  repeat
    initialize_pointer(stat_adjustment.cursor_x, stat_adjustment.cursor_y, 2, data29.bounds11);
    repeat
      update_pointer(stat_adjustment.cursor_x, stat_adjustment.cursor_y);
      stat_editor.done_poll := poll_input(1)
    until odd(poll_input(4) or stat_editor.done_poll);
    toggle_pointer_glyph(stat_adjustment.cursor_x, stat_adjustment.cursor_y);
    if not odd(stat_editor.done_poll) then
    begin
      if word_abs(stat_adjustment.cursor_x - stat_adjustment.minus_x) +
         word_abs(stat_adjustment.cursor_y - stat_adjustment.minus_y) < 10 then
        stat_adjustment.step := -1
      else if word_abs(stat_adjustment.cursor_x - stat_adjustment.plus_x) +
              word_abs(stat_adjustment.cursor_y - stat_adjustment.plus_y) < 10 then
        stat_adjustment.step := 1
      else
      begin
        stat_adjustment.step := 0;
        pick_attribute_row(stat_adjustment.cursor_x, stat_adjustment.cursor_y, stat_adjustment.next_stat);
        stat_adjustment.selection_found := ord(stat_adjustment.next_stat >= 0)
      end
    end;
    while odd(ord(stat_adjustment.edited_value + stat_adjustment.step >= stat_adjustment.minimum_value)
              and ord(stat_adjustment.step <> 0)
              and poll_input(4)
              and not (stat_editor.done_poll or stat_adjustment.selection_found)) do
    begin
      stat_adjustment.edited_value := stat_adjustment.edited_value + stat_adjustment.step;
      if stat_adjustment.step < 0 then
        stat_adjustment.candidate_points := stat_editor.unspent_points + attribute_point_cost(stat_adjustment.edited_value + 1)
      else
        stat_adjustment.candidate_points := stat_editor.unspent_points - attribute_point_cost(stat_adjustment.edited_value);
      if stat_adjustment.candidate_points <= 0 then
      begin
        stat_adjustment.edited_value := stat_adjustment.edited_value - stat_adjustment.step;
        stat_adjustment.rejected_value := stat_adjustment.edited_value
      end
      else stat_editor.unspent_points := stat_adjustment.candidate_points;
      if stat_adjustment.edited_value > 0 then
      begin
        set_clip_bounds(stat_adjustment.bar^.lower_first,
                  stat_adjustment.bar^.lower_first + stat_adjustment.edited_value,
                  stat_adjustment.bar^.lower_second, stat_adjustment.bar^.upper_second);
        draw_clip_pattern(9)
      end;
      set_clip_bounds(stat_adjustment.bar^.lower_first + stat_adjustment.edited_value,
                stat_adjustment.bar^.upper_first,
                stat_adjustment.bar^.lower_second, stat_adjustment.bar^.upper_second);
      draw_clip_pattern(8);
      apply_bounds(data29.bounds11, 0);
      move_pen(stat_adjustment.bar^.upper_first + 8, stat_adjustment.bar^.upper_second + 2);
      draw_integer(stat_adjustment.edited_value, 3, false);
      draw_unspent_points;
      stat_adjustment.discarded_poll := poll_input(4)
    end
  until odd(stat_editor.done_poll or stat_adjustment.selection_found);
  apply_bounds(data29.bounds11, 0);
  data29.bytes[94 + stat_index] := stat_adjustment.edited_value;
  move_pen(stat_adjustment.bar^.lower_first - 7, stat_adjustment.bar^.upper_second + 1);
  draw_glyph(32);
  move_pen(stat_adjustment.bar^.upper_first + 2, stat_adjustment.bar^.upper_second + 2);
  draw_text('    ');
  draw_attribute_bar(stat_index, 10);
  draw_unspent_points;
  if odd(stat_editor.done_poll or ord(stat_adjustment.next_stat = stat_index)) then
    stat_index := -1
  else stat_index := stat_adjustment.next_stat
end;
