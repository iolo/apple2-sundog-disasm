{ library_24 procedure10, $0000..$0034, attributes $003E.
  Nested in2: parent slots2/1 are the center; local parameter slots2/1
  are the offsets. Preserve all four plot calls, including coincident points. }
procedure proc24_10(dx, dy: integer);
begin
  proc22_8(centerx + dx, centery + dy);
  proc22_8(centerx + dx, centery - dy);
  proc22_8(centerx - dx, centery - dy);
  proc22_8(centerx - dx, centery + dy)
end;
