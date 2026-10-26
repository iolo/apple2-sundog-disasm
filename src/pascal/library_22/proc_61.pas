{ library_22 procedure 61, $071A..$0768, attributes $0772.
  Local words 3/4 form the four-byte output buffer passed to native 5. }
procedure proc22_61(var firstpos, secondpos: integer);
var
  coords: wordpair;
begin
  proc22_5(coords);
  if odd(data29.words[380]) then coords.first := proc22_30(coords.first, 1);
  if odd(data29.words[379]) then coords.second := proc22_30(coords.second, 1);
  coords.first := coords.first + data29.words[369];
  coords.second := coords.second + data29.words[368];
  proc22_37(data29.words[378], coords.first, data29.words[377]);
  proc22_37(data29.words[376], coords.second, data29.words[375]);
  firstpos := coords.first;
  secondpos := coords.second
end;
