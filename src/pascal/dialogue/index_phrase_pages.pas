{ game_16 procedure31, $0E6E..$0EC6, attributes $0ED6.
  The inner comparison reads table[index] before testing index<65. After
  reaching65 it reads that byte again and stores a threshold; do not reorder
  the limit test or add a sentinel. The unused original local is omitted. }
procedure index_phrase_pages(page_index, previous_offset, record_index: integer);
begin
  while (record_index < 65) and (page_index < 6) do
  begin
    while (previous_offset <= g16.phrase_bytes.bytes^[record_index]) and (record_index < 65) do
    begin
      previous_offset := g16.phrase_bytes.bytes^[record_index];
      record_index := record_index + 1
    end;
    previous_offset := g16.phrase_bytes.bytes^[record_index];
    g16.words[47 + page_index] := record_index;
    record_index := record_index + 1;
    page_index := page_index + 1
  end;
  while page_index < 6 do
  begin
    g16.words[47 + page_index] := record_index - 1;
    page_index := page_index + 1
  end
end;
