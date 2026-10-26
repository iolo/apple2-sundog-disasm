{ game_8 procedure 5, $010A..$0120, attributes $012A.
  Four-word value copy and signed inclusive bounds, as in game_18:2. }
function point_in_item_area(x, y: integer; bounds: bounds4): boolean;
begin
  point_in_item_area := (bounds.lower_first <= x) and
              (x <= bounds.upper_first) and
              (bounds.lower_second <= y) and
              (y <= bounds.upper_second)
end;
