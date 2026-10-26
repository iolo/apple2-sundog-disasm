{ library_27 procedure 8, $01E2..$0241, attributes $024E.
  Both distance calls execute before testing the combined result. }
procedure proc27_8(firstpos, secondpos: integer; var itemcode, found: integer);
var
  index: integer;
  firstok, secondok: boolean;
begin
  found := 0;
  itemcode := -1;
  index := 1;
  firstpos := firstpos - data29.words[14];
  secondpos := secondpos - data29.words[12];
  while (index <= data31.words[16]) and (found = 0) do
  begin
    with data31.items[index] do
    begin
      firstok := proc22_35(firstpos - firstoff) < 10;
      secondok := proc22_35(secondpos - secondoff) < 8;
      if firstok and secondok then
      begin
        found := index;
        itemcode := code
      end
      else index := index + 1
    end
  end
end;
