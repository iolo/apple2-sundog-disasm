{ game_14 procedure10, $0618..$067F, attributes $068A, nested in9.
  WITH captures the item pointer at local4 before calls. index, savedx and
  savedy are parent9 slots7/6/5; g14 is the grandparent frame. }
procedure proc14_10;
var
  y: integer;
  x: integer;
  item: integer;
begin
  item := (4 * (index div 5) + index mod 5 + data31.words[15]) + 1;
  with data31.items[item] do
  begin
    x := firstoff + savedx;
    y := secondoff + savedy;
    proc27_4(7);
    proc27_3(x, y);
    proc22_4(10, 10, 50, 0, 0, 0, 1);
    proc27_4(code);
    proc27_3(x, y);
    code := 7;
    data29.bytes[178 + (index + g14.words[4])] := 7
  end
end;
