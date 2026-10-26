{ library_24 procedure17, $0B5A..$0BD6, attributes $0BE0; nested in15.
  Copy bounds before subtracting the parent's VAR amount or updating value. }
procedure adjust_resource_and_gauge(var value: integer; change, cost, marker: integer;
                    bounds: bounds4; mode1, mode2, linecode: integer);
var
  next: integer;
  edge: integer;
begin
  amount := amount - cost;
  consume_reserve_resource;
  if amount >= 0 then
  begin
    next := value + change;
    if next > 255 then value := 255
    else if next < 0 then value := 0
    else value := next
  end;
  draw_vertical_gauge(bounds, value, mode1, mode2);
  if (data29.nibbles45[2] <= 1) and (marker > 0) then
  begin
    apply_bounds(bounds, 0);
    edge := bounds.upper_second - right_shift_word(marker, 2);
    move_pen(bounds.lower_first, edge);
    set_line_mode(linecode);
    move_pen(bounds.upper_first - 1, edge);
    set_line_mode(0);
    apply_bounds(data29.bounds7, 0)
  end
end;
