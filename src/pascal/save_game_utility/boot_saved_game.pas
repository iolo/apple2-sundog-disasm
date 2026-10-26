{ utility_disk1:40 $172C..$1825, attributes$1836. Locals1 header pointer,
  2 block,3 unused,4 index,5 unused,6 limit. Reject state>=4; otherwise update
  slot states, header and seed, then write the selected boot block TWICE.
  Preserve four-byte MOVELEFT and every disk operation before boot26:2. }
procedure boot_saved_game;
var
  header: address16;
  boot_block: integer;
  unused3: integer;
  index: integer;
  unused5: integer;
  limit: integer;
begin
  if u1.slots[u1.picked_slot].words[8] >= 4 then
  begin
    clear_text_window;
    write_wrapped_text('This game is over -- please select another game.');
    repeat until odd(poll_input(0) or poll_input(1))
  end
  else
  begin
    require_utility_side(true);
    pop_text_window;
    index := 0;
    limit := 3;
    while index <= limit do
    begin
      if (u1.slots[index].words[8] = 3) and (index <> u1.picked_slot) then
      begin
        u1.slots[index].words[8] := 2;
        draw_save_slot(index, true)
      end;
      index := index + 1
    end;
    u1.slots[u1.picked_slot].words[8] := 3;
    draw_save_slot(u1.picked_slot, true);
    disk_blocks_io(word_address(u1.words[12]), 1, data29.words[31] - 1, false);
    header.word := 2048;
    disk_blocks_io(header.word, 1, 80, true);
    header.bytes^[0] := 255;
    header.bytes^[1] := u1.picked_slot;
    boot_block := header.bytes^[7] - 3;
    moveleft(data29.seed21, header.bytes^[2], 4);
    disk_blocks_io(header.word, 1, 80, false);
    disk_blocks_io(2048, 1, 78, true);
    disk_blocks_io(2048, 1, boot_block, false);
    disk_blocks_io(2048, 1, boot_block, false);
    reboot_with_caption('DUST')
  end
end;
