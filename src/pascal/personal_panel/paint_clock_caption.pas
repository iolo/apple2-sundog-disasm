{ game_8 procedure12, $0510..$0545, attributes $0550. }
procedure paint_clock_caption;
begin
  write_item_caption('');
  data29.bounds327 := data31.bounds6;
  move_pen(data29.words[330] + 3, data29.words[327]);
  draw_clock(data29.clock42);
  wait_personal_input;
  write_item_caption('');
  assign_bounds(data29.bounds327, 0, 0, 0, 0)
end;
