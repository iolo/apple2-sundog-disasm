{ game_16 procedure12, $0584..$05AB, attributes $05B8.
  Add256 for each crossed threshold in parent47 onward. Preserve the scan
  without an invented upper bound; thresholds share the parent's raw frame. }
function phrase_offset(phrase_index: integer): integer;
var
  page_index: integer;
  byte_offset: integer;
begin
  byte_offset := g16.phrase_bytes.bytes^[phrase_index];
  page_index := 0;
  while phrase_index >= g16.words[47 + page_index] do
  begin
    byte_offset := byte_offset + 256;
    page_index := page_index + 1
  end;
  phrase_offset := byte_offset
end;
