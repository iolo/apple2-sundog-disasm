{ game_15 procedure2, $0000..$001E, attributes $0028.
  Bounds are copied by value into slots3..6 before any external write. }
procedure draw_framed_bounds(bounds: bounds4; mode: integer);
begin
  set_clip_bounds(bounds.lower_first - 2, bounds.upper_first + 2,
            bounds.lower_second - 1, bounds.upper_second + 1);
  draw_clip_pattern(11);
  apply_bounds(bounds, mode)
end;
