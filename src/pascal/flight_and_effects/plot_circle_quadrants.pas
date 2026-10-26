{ library_24 procedure10, $0000..$0034, attributes $003E.
  Nested in2: parent slots2/1 are the center; local parameter slots2/1
  are the offsets. Preserve all four plot calls, including coincident points. }
procedure plot_circle_quadrants(dx, dy: integer);
begin
  plot_pixel(centerx + dx, centery + dy);
  plot_pixel(centerx + dx, centery - dy);
  plot_pixel(centerx - dx, centery - dy);
  plot_pixel(centerx - dx, centery + dy)
end;
