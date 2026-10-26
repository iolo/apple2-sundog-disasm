{ library_27 procedure 2, $0000..$0037, attributes $0042. }
procedure proc27_2(var firstpos, secondpos: integer);
var
  coords: wordpair;
begin
  proc22_5(coords);
  coords.first := coords.first + data31.words[5];
  coords.second := coords.second + data31.words[3];
  proc22_37(data31.words[5] + 4, coords.first, data31.words[4] - 4);
  proc22_37(data31.words[3] + 4, coords.second, data31.words[2] - 4);
  firstpos := coords.first;
  secondpos := coords.second
end;
