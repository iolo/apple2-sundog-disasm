{ library_27 procedure 2, $0000..$0037, attributes $0042. }
procedure read_item_panel_position(var firstpos, secondpos: integer);
var
  coords: wordpair;
begin
  read_input_coordinates(coords);
  coords.first := coords.first + data31.words[5];
  coords.second := coords.second + data31.words[3];
  clamp_word(data31.words[5] + 4, coords.first, data31.words[4] - 4);
  clamp_word(data31.words[3] + 4, coords.second, data31.words[2] - 4);
  firstpos := coords.first;
  secondpos := coords.second
end;
