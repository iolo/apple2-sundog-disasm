{ utility_disk1:8 $0000..$0198, attributes$01A8. Locals1 unused,2 address/
  index,3 header pointer,4 limit,5 selected slot. Preserve checksum timing,
  the copy order and header invalidation. Buffer269 is512 bytes through524;
  word504+byte2 equals root byte1004. Parent word278 holds state nibbles. }
procedure util1_8;
var
  unused: integer;
  index: integer;
  header: address16;
  limit: integer;
  selected: utilptr;
begin
  data29.flags82[122] := false;
  proc22_18(data29.bounds7, 0, 279, 0, 191);
  proc22_18(data29.bounds3, 0, 139, 0, 95);
  proc22_17(true);
  proc22_19(data29.bounds3, 8);
  proc22_17(false);
  data29.words[1] := 0;
  proc22_13(0);
  proc22_12(0, 0);
  proc22_11(0);
  proc22_16(0, 0);
  data29.words[16] := 2048;
  proc22_20(0, 0, data29.words[16]);
  proc26_6(false);
  data29.words[16] := 4096;
  proc22_20(0, 0, data29.words[16]);
  data29.words[30] := 19;
  data29.words[31] := 24;
  u1.words[268] := 0;
  index := -5887;
  proc22_23(index, data29.words[23]);
  index := index + 240;
  proc22_23(index, data29.words[24]);
  index := index + 288;
  proc22_23(index, data29.words[25]);
  util1_7(true);
  proc22_53(16384, 3, data29.words[30] + 1, true);
  proc26_4(16384, -5887, 1440);
  header.word := 2048;
  proc22_53(proc22_24(u1.words[12]), 1, data29.words[31] - 1, true);
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    selected := @u1.slots[index];
    if (selected^.words[8] > 0) and (selected^.words[8] <= 6) then
    begin
      proc22_53(16384, 10, data29.words[31] + 10 * index, true);
      proc26_4(16384, proc22_24(u1.words[269]), 512);
      selected^.words[9] := u1.bytes[1004];
      selected^.place18 := u1.place269;
      selected^.stamp16 := u1.stamp275;
      if selected^.words[15] <> proc26_3(16384, 10) then
      begin
        selected^.words[8] := 6;
        if index = header.bytes^[1] then
        begin
          header.bytes^[1] := 255;
          proc22_53(2048, 1, 80, false)
        end
      end
      else if (selected^.words[8] < 4) or (selected^.words[8] = 6) then
      begin
        if u1.state278[2] = 12 then selected^.words[8] := 4
        else if u1.state278[2] = 13 then selected^.words[8] := 5
        else if selected^.words[8] = 6 then selected^.words[8] := 2
      end
    end;
    index := index + 1
  end;
  util1_6
end;
