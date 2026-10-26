{ utility_disk1:26 $0D0A..$0D81, attributes$0D8C. One local pointer word.
  Duplicate five attributes, write one data block, read ten blocks for checksum,
  then update the selected64-byte utility slot in the original store order. }
procedure commit_new_game;
var slot: utilptr;
begin
  require_utility_side(true);
  moveleft(data29.bytes[94], data29.bytes[99], 5);
  disk_blocks_io(word_address(data29.words[36]), 1,
            10 * u1.picked_slot + data29.words[31], false);
  disk_blocks_io(16384, 10, 10 * u1.picked_slot + data29.words[31], true);
  slot := @u1.slots[u1.picked_slot];
  slot^.caption := data29.name255;
  slot^.words[8] := 1;
  moveleft(data29.bytes[94], slot^.stored_attributes, 10);
  slot^.words[9] := data29.bytes[178 + 194];
  slot^.saved_clock := data29.clock42;
  slot^.saved_location := data29.pos36;
  slot^.words[15] := even_odd_checksum(16384, 10)
end;
