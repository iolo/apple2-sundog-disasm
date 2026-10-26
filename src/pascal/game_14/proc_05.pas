{ game_14 procedure5, $0356..$0400, attributes $040C.
  For a value outside0..4, mode retains its previous (possibly uninitialized)
  word. The assembly supplies no default; do not invent one. }
procedure proc14_5;
var
  value: integer;
  edge: integer;
  index: integer;
  base: integer;
  mode: integer;
  last: integer;
begin
  base := g14.words[4] + 4;
  index := 0;
  last := 3;
  while index <= last do
  begin
    value := data29.bytes[178 + (base + 5 * index)];
    case value of
      0: mode := 4;
      1,2,3: mode := 9;
      4: mode := 5
    end;
    proc22_19(g14.lamps86[index], mode);
    index := index + 1
  end;
  value := data29.bytes[178 + (base + 20)];
  if value = 16 then proc22_19(g14.meter74, 5)
  else if value = 0 then proc22_19(g14.meter74, 4)
  else
  begin
    edge := g14.words[74] - 4 * value;
    proc22_14(g14.words[77], g14.words[76], edge, g14.words[74]);
    proc22_7(9);
    proc22_14(g14.words[77], g14.words[76], g14.words[75], edge - 1);
    proc22_7(8)
  end;
  proc22_19(data29.bounds11, 0)
end;
