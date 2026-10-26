{ utility_disk1:43 $1ADE..$1B19, attributes$1B24,512-byte local sector.
  Only clear the selected64-byte slot after confirmation. Read block80 and
  replace byte1 with low-byte(-1) iff it names the selected slot, then write.
  The stored255 preserves STB truncation; no signed byte type is introduced. }
procedure erase_save_slot;
var sector: utilsector;
begin
  if confirm_slot_delete then
  begin
    fillchar(u1.slots[u1.picked_slot], 64, 0);
    require_utility_side(true);
    disk_blocks_io(word_address(sector.words[0]), 1, 80, true);
    if sector.bytes[1] = u1.picked_slot then
    begin
      sector.bytes[1] := 255;
      disk_blocks_io(word_address(sector.words[0]), 1, 80, false)
    end
  end
end;
