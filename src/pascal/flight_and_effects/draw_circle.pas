{ library_24 procedure2, $0040..$009A, attributes $00A6.
  Slots3/2/1 are radius/centerx/centery. Retain six local bytes for nested10:
  decision4, edge5, offset6. Native30 supplies16-bit left shifts, including
  the signed (offset-edge) operand. Do not deduplicate axial/diagonal pixels. }
procedure draw_circle(radius, centerx, centery: integer);
var
  decision: integer;
  edge: integer;
  offset: integer;
(*$include src/pascal/flight_and_effects/plot_circle_quadrants.pas*)
begin
  offset := 0;
  edge := radius;
  decision := 3 - left_shift_word(radius, 1);
  while offset < edge do
  begin
    plot_circle_quadrants(offset, edge);
    plot_circle_quadrants(edge, offset);
    if decision < 0 then
      decision := decision + left_shift_word(offset, 2) + 6
    else
    begin
      decision := decision + left_shift_word(offset - edge, 2) + 10;
      edge := edge - 1
    end;
    offset := offset + 1
  end;
  if offset = edge then
  begin
    plot_circle_quadrants(offset, edge);
    plot_circle_quadrants(edge, offset)
  end
end;
