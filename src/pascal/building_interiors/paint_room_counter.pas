{ game_18 procedure 18, $0CD0..$0D50, attributes $0D5C. }
procedure paint_room_counter;
var
  rightedge, leftedge, column: integer;
begin
  fillchar(counter_slots, 6, data29.words[293]);
  column := 0;
  while column <= 2 do
  begin
    leftedge := room_left + (column * (room_layout_state[130] - room_left)) div 3;
    rightedge := room_left + ((column + 1) * (room_layout_state[130] - room_left)) div 3;
    set_clip_bounds(leftedge + 10, rightedge - 10,
              room_layout_state[128] - 6, room_layout_state[128]);
    draw_clip_pattern(9);
    if column < 2 then
    begin
      { $0D2B..$0D32: FJP examines bit zero of the edge coordinate. }
      if odd(rightedge) then rightedge := rightedge + 1;
      set_clip_bounds(rightedge - 1, rightedge,
                room_layout_state[128] - 9, room_layout_state[128]);
      draw_clip_pattern(10)
    end;
    column := column + 1
  end
end;
