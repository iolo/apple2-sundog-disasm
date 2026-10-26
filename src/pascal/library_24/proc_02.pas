{ library_24 procedure2, $0040..$009A, attributes $00A6.
  Slots3/2/1 are radius/centerx/centery. Retain six local bytes for nested10:
  decision4, edge5, offset6. Native30 supplies16-bit left shifts, including
  the signed (offset-edge) operand. Do not deduplicate axial/diagonal pixels. }
procedure proc24_2(radius, centerx, centery: integer);
var
  decision: integer;
  edge: integer;
  offset: integer;
(*$include src/pascal/library_24/proc_10.pas*)
begin
  offset := 0;
  edge := radius;
  decision := 3 - proc22_30(radius, 1);
  while offset < edge do
  begin
    proc24_10(offset, edge);
    proc24_10(edge, offset);
    if decision < 0 then
      decision := decision + proc22_30(offset, 2) + 6
    else
    begin
      decision := decision + proc22_30(offset - edge, 2) + 10;
      edge := edge - 1
    end;
    offset := offset + 1
  end;
  if offset = edge then
  begin
    proc24_10(offset, edge);
    proc24_10(edge, offset)
  end
end;
