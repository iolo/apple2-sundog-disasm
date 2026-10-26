{ game_21 procedure14, $06C0..$06CD, attributes $06D6. }
function proc21_14(left, right, radius: integer): boolean;
begin
  proc21_14 := proc22_35(left - right) <= radius
end;
