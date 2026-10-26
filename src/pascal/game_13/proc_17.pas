{ game_13 procedure17, $0A02..$0A21, attributes $0A2C; nested in16.
  Slots4/3 are inputs,2/1 are VAR outputs. The first input's low bit controls
  the extra three units; preserve native shift semantics and output order,
  including when both result addresses alias. }
procedure proc13_17(first, second: integer; var outx, outy: integer);
begin
  outx := 6 * proc22_31(first + 1, 1);
  if odd(first) then outx := outx + 3;
  outy := proc22_30(second, 2)
end;
