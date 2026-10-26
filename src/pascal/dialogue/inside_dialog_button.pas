{ game_16 procedure36, $118A..$11A7, attributes $11B2.
  Nested in35; capture the grandparent's selected bounds address once. }
function inside_dialog_button(x, y, bounds_index: integer): boolean;
begin
  with g16.dialog_buttons[bounds_index] do
    inside_dialog_button := (lower_first <= x) and (x <= upper_first) and
                 (lower_second <= y) and (y <= upper_second)
end;
