{ game_16 procedure32, $0ED8..$0F69, attributes $0F7A.
  Header16 skips all work. Copy each record leftward before storing its next
  byte offset; odd source positions advance to the next even byte. Preserve
  forward propagation through table64 and rebuild the six raw thresholds. }
procedure merge_dialog_phrases;
var
  patch_block: address16;
  dest_offset: integer;
  phrase_length: integer;
  phrase_index: integer;
  source_offset: integer;
  record_count: integer;
begin
  store_word(18432, patch_block.word);
  if patch_block.bytes^[0] <> 16 then
  begin
    record_count := patch_block.bytes^[16];
    source_offset := patch_block.bytes^[17];
    source_offset := source_offset + source_offset;
    phrase_index := g16.phrase_insert_index;
    while record_count > 0 do
    begin
      phrase_length := patch_block.bytes^[source_offset];
      dest_offset := phrase_offset(phrase_index);
      moveleft(patch_block.bytes^[source_offset + 1], g16.phrase_bytes.bytes^[dest_offset], phrase_length);
      g16.phrase_bytes.bytes^[phrase_index + 1] := (dest_offset + phrase_length) mod 256;
      source_offset := source_offset + 1 + phrase_length;
      if odd(source_offset) then source_offset := source_offset + 1;
      phrase_index := phrase_index + 1;
      record_count := record_count - 1
    end;
    while phrase_index < 64 do
    begin
      g16.phrase_bytes.bytes^[phrase_index + 1] := g16.phrase_bytes.bytes^[phrase_index];
      phrase_index := phrase_index + 1
    end;
    g16.words[47] := 0;
    index_phrase_pages(0, 0, 0)
  end
end;
