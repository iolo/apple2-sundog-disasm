{ utility_disk1:40 $172C..$1825, attributes$1836. Locals1 header pointer,
  2 block,3 unused,4 index,5 unused,6 limit. Reject state>=4; otherwise update
  slot states, header and seed, then write the selected boot block TWICE.
  Preserve four-byte MOVELEFT and every disk operation before boot26:2. }
procedure util1_40;
var
  header: address16;
  block: integer;
  unused3: integer;
  index: integer;
  unused5: integer;
  limit: integer;
begin
  if u1.slots[u1.words[6]].words[8] >= 4 then
  begin
    proc22_44;
    proc22_48('This game is over -- please select another game.');
    repeat until odd(proc22_2(0) or proc22_2(1))
  end
  else
  begin
    util1_7(true);
    proc22_52;
    index := 0;
    limit := 3;
    while index <= limit do
    begin
      if (u1.slots[index].words[8] = 3) and (index <> u1.words[6]) then
      begin
        u1.slots[index].words[8] := 2;
        util1_3(index, true)
      end;
      index := index + 1
    end;
    u1.slots[u1.words[6]].words[8] := 3;
    util1_3(u1.words[6], true);
    proc22_53(proc22_24(u1.words[12]), 1, data29.words[31] - 1, false);
    header.word := 2048;
    proc22_53(header.word, 1, 80, true);
    header.bytes^[0] := 255;
    header.bytes^[1] := u1.words[6];
    block := header.bytes^[7] - 3;
    moveleft(data29.seed21, header.bytes^[2], 4);
    proc22_53(header.word, 1, 80, false);
    proc22_53(2048, 1, 78, true);
    proc22_53(2048, 1, block, false);
    proc22_53(2048, 1, block, false);
    proc26_2('DUST')
  end
end;
