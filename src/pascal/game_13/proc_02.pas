{ game_13 procedure2, $0000..$0063, attributes $0070.
  Save exactly four RNG bytes in external words64/65, seed from system bits,
  write256 masked random bytes at2816, then restore the saved bytes. The byte
  destination and index are evaluated before each random-producing call. }
procedure proc13_2;
var
  target: address16;
  index: integer;
  last: integer;
begin
  moveleft(data29.words[21], data29.words[64], 4);
  data29.bytes[40] := 0;
  data29.bytes[42] := 1;
  data29.bytes[41] := 17 * data29.loc73.low4;
  data29.bytes[43] := 23 * data29.loc73.low4;
  target.word := 2048 + 768;
  index := 0;
  last := 255;
  while index <= last do
  begin
    target.bytes^[index] := proc22_32(proc22_3, 255);
    index := index + 1
  end;
  moveleft(data29.words[64], data29.words[21], 4)
end;
