{ game_13 procedure2, $0000..$0063, attributes $0070.
  Save exactly four RNG bytes in external words64/65, seed from system bits,
  write256 masked random bytes at2816, then restore the saved bytes. The byte
  destination and index are evaluated before each random-producing call. }
procedure seed_system_stars;
var
  star_bytes: address16;
  star_index: integer;
  last_star: integer;
begin
  moveleft(data29.words[21], data29.words[64], 4);
  data29.bytes[40] := 0;
  data29.bytes[42] := 1;
  data29.bytes[41] := 17 * data29.loc73.low4;
  data29.bytes[43] := 23 * data29.loc73.low4;
  star_bytes.word := 2048 + 768;
  star_index := 0;
  last_star := 255;
  while star_index <= last_star do
  begin
    star_bytes.bytes^[star_index] := word_and(random_word, 255);
    star_index := star_index + 1
  end;
  moveleft(data29.words[64], data29.words[21], 4)
end;
