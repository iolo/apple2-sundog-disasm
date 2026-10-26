{ game_21 procedure14, $06C0..$06CD, attributes $06D6. }
function within_axis_radius(left, right, radius: integer): boolean;
begin
  within_axis_radius := word_abs(left - right) <= radius
end;
