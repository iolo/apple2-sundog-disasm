{ utility_disk1:46 $1EF2..$1F38, attributes$1F42. Slot1 VAR choice,
  slot2 second coordinate,3 first. Locals4 y,5 x,6..9 bounds (12 bytes).
  Division/modulo and selection are not clamped; reread aliased choice. }
procedure util1_46(first, second: integer; var choice: integer);
var
  y: integer;
  x: integer;
  bounds: bounds4;
begin
  choice := (second - 39) div 76 + 2 * (first div 140);
  x := 140 * (choice div 2);
  y := 39 + 76 * (choice mod 2);
  proc22_4(30, 50, 10, 0, 0, 0, 0);
  proc22_18(bounds, 6 + x, 135 + x, 5 + y, 71 + y);
  proc22_19(bounds, 3)
end;
