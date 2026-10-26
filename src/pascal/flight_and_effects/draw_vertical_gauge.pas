{ library_24 procedure7, $00F8..$013F, attributes $014A.
  Four-word value copy occurs even when the mode gate suppresses drawing. }
procedure draw_vertical_gauge(bounds: bounds4; value, mode1, mode2: integer);
var
  edge: integer;
begin
  if data29.nibbles45[2] <= 1 then
  begin
    edge := bounds.upper_second - right_shift_word(value + 3, 2);
    if edge > bounds.lower_second then
    begin
      set_clip_bounds(bounds.lower_first, bounds.upper_first, bounds.lower_second, edge);
      draw_clip_pattern(mode1)
    end;
    if edge + 1 < bounds.upper_second then
    begin
      set_clip_bounds(bounds.lower_first, bounds.upper_first, edge + 1, bounds.upper_second);
      draw_clip_pattern(mode2)
    end;
    apply_bounds(data29.bounds7, 0)
  end
end;
