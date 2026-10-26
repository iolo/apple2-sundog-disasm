{ library_22 procedure20, $022C..$0247, attributes $0252.
  Slots3/2/1 are block-pair index, low-bit buffer selector, raw address.
  Store the selected buffer address before reading two blocks at pair*2+3
  through53. Preserve native23's store even when a later read fails. }
procedure load_buffer_pair(pair, primary, buffer: integer);
begin
  if odd(primary) then store_word(buffer, data29.primary_buffer)
  else store_word(buffer, data29.secondary_buffer);
  disk_blocks_io(buffer, 2, pair * 2, true)
end;
