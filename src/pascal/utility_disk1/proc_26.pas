{ utility_disk1:26 $0D0A..$0D81, attributes$0D8C. One local pointer word.
  Duplicate five attributes, write one data block, read ten blocks for checksum,
  then update the selected64-byte utility slot in the original store order. }
procedure util1_26;
var slot: utilptr;
begin
  util1_7(true);
  moveleft(data29.bytes[94], data29.bytes[99], 5);
  proc22_53(proc22_24(data29.words[36]), 1,
            10 * u1.words[6] + data29.words[31], false);
  proc22_53(16384, 10, 10 * u1.words[6] + data29.words[31], true);
  slot := @u1.slots[u1.words[6]];
  slot^.caption := data29.name255;
  slot^.words[8] := 1;
  moveleft(data29.bytes[94], slot^.attrs10, 10);
  slot^.words[9] := data29.bytes[178 + 194];
  slot^.stamp16 := data29.clock42;
  slot^.place18 := data29.pos36;
  slot^.words[15] := proc26_3(16384, 10)
end;
