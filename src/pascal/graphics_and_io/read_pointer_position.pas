{ library_22 procedure 61, $071A..$0768, attributes $0772.
  Local words 3/4 form the four-byte output buffer passed to native 5. }
procedure read_pointer_position(var firstpos, secondpos: integer);
var
  coords: wordpair;
begin
  read_input_coordinates(coords);
  if odd(data29.words[380]) then coords.first := left_shift_word(coords.first, 1);
  if odd(data29.words[379]) then coords.second := left_shift_word(coords.second, 1);
  coords.first := coords.first + data29.words[369];
  coords.second := coords.second + data29.words[368];
  clamp_word(data29.words[378], coords.first, data29.words[377]);
  clamp_word(data29.words[376], coords.second, data29.words[375]);
  firstpos := coords.first;
  secondpos := coords.second
end;
