{ library_22 procedure20, $022C..$0247, attributes $0252.
  Slots3/2/1 are block-pair index, low-bit buffer selector, raw address.
  Store the selected buffer address before reading two blocks at pair*2+3
  through53. Preserve native23's store even when a later read fails. }
procedure proc22_20(pair, primary, buffer: integer);
begin
  if odd(primary) then proc22_23(buffer, data29.words[355])
  else proc22_23(buffer, data29.words[356]);
  proc22_53(buffer, 2, pair * 2, true)
end;
