{ game_21 procedure20, $09BA..$09DE, attributes $09E8; nested in19.
  Both proximity calls run even when enabled is false. }
procedure apply_entrance_mode(enabled: boolean; target_x, target_y, next_mode, next_action: integer);
var
  nearx, neary: boolean;
begin
  nearx := within_axis_radius(local_x, target_x, 4);
  neary := within_axis_radius(local_y, target_y, 4);
  if enabled and nearx and neary then
  begin
    data29.nibbles45[2] := next_mode;
    tile_or_action := next_action
  end
end;
