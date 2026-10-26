{ game_16 procedure31, $0E6E..$0EC6, attributes $0ED6.
  The inner comparison reads table[index] before testing index<65. After
  reaching65 it reads that byte again and stores a threshold; do not reorder
  the limit test or add a sentinel. The unused original local is omitted. }
procedure proc16_31(band, previous, index: integer);
begin
  while (index < 65) and (band < 6) do
  begin
    while (previous <= g16.table141.bytes^[index]) and (index < 65) do
    begin
      previous := g16.table141.bytes^[index];
      index := index + 1
    end;
    previous := g16.table141.bytes^[index];
    g16.words[47 + band] := index;
    index := index + 1;
    band := band + 1
  end;
  while band < 6 do
  begin
    g16.words[47 + band] := index - 1;
    band := band + 1
  end
end;
