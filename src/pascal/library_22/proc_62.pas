{ library_22 procedure 62, $0774..$078E, attributes $0798, lexical level 2.
  Nested in 42. Keep writes/reads through both VAR arguments in order. }
procedure proc22_62(origin, span, extent: integer; var doubled, offset: integer);
begin
  doubled := ord(span > extent);
  if odd(doubled) then extent := 2 * extent;
  offset := origin - proc22_31(extent - span, 1)
end;
