{ game_8 procedure 5, $010A..$0120, attributes $012A.
  Four-word value copy and signed inclusive bounds, as in game_18:2. }
function proc8_5(firstpos, secondpos: integer; bounds: bounds4): boolean;
begin
  proc8_5 := (bounds.lower_first <= firstpos) and
              (firstpos <= bounds.upper_first) and
              (bounds.lower_second <= secondpos) and
              (secondpos <= bounds.upper_second)
end;
