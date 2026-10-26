{ game_21 procedure20, $09BA..$09DE, attributes $09E8; nested in19.
  Both proximity calls run even when enabled is false. }
procedure proc21_20(enabled: boolean; targetx, targety, mode, value: integer);
var
  nearx, neary: boolean;
begin
  nearx := proc21_14(xpos, targetx, 4);
  neary := proc21_14(ypos, targety, 4);
  if enabled and nearx and neary then
  begin
    data29.nibbles45[2] := mode;
    arg2 := value
  end
end;
