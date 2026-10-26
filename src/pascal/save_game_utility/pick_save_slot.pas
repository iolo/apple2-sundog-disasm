{ utility_disk1:46 $1EF2..$1F38, attributes$1F42. Slot1 VAR choice,
  slot2 second coordinate,3 first. Locals4 y,5 x,6..9 bounds (12 bytes).
  Division/modulo and selection are not clamped; reread aliased choice. }
procedure pick_save_slot(pointer_x, pointer_y: integer; var slot_index: integer);
var
  y: integer;
  x: integer;
  bounds: bounds4;
begin
  slot_index := (pointer_y - 39) div 76 + 2 * (pointer_x div 140);
  x := 140 * (slot_index div 2);
  y := 39 + 76 * (slot_index mod 2);
  play_sound(30, 50, 10, 0, 0, 0, 0);
  assign_bounds(bounds, 6 + x, 135 + x, 5 + y, 71 + y);
  apply_bounds(bounds, 3)
end;
