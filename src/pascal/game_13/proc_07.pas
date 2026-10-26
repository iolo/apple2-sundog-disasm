{ game_13 procedure7, $016E..$01F3, attributes $0200; nested in3.
  Seven bars use raw row bytes at word90+28*index+24. Keep both gaps after
  indices2/5, including the independent upper/lower fill operations. }
procedure proc13_7;
var
  x: integer;
  bottom: integer;
  edge: integer;
  top: integer;
  index: integer;
  last: integer;
begin
  bottom := g13s.words[2];
  top := bottom - 8;
  x := g13s.words[3];
  index := 0;
  last := 6;
  while index <= last do
  begin
    edge := bottom - proc22_31(data29.bytes[178 + (28 * index + 24)], 1);
    if edge > top then
    begin
      proc22_14(x, x + 6, top, edge - 1);
      proc22_7(8)
    end;
    proc22_14(x, x + 6, edge, bottom);
    if edge = bottom then proc22_7(8)
    else if edge = top then proc22_7(5)
    else proc22_7(9);
    x := x + 7;
    if (index = 2) or (index = 5) then x := x + 7;
    index := index + 1
  end;
  proc22_19(data29.bounds11, 0)
end;
