{ utility_disk1:8 $0000..$0198, attributes$01A8. Locals1 unused,2 address/
  index,3 header pointer,4 limit,5 selected slot. Preserve checksum timing,
  the copy order and header invalidation. Buffer269 is512 bytes through524;
  word504+byte2 equals root byte1004. Parent word278 holds state nibbles. }
procedure load_save_catalog;
var
  unused: integer;
  index: integer;
  header: address16;
  limit: integer;
  selected: utilptr;
begin
  data29.flags82[122] := false;
  assign_bounds(data29.bounds7, 0, 279, 0, 191);
  assign_bounds(data29.bounds3, 0, 139, 0, 95);
  use_linear_row_tables(true);
  apply_bounds(data29.bounds3, 8);
  use_linear_row_tables(false);
  data29.words[1] := 0;
  set_line_mode(0);
  move_pen(0, 0);
  set_glyph_mode(0);
  set_window_image_origin(0, 0);
  data29.words[16] := 2048;
  load_buffer_pair(0, 0, data29.words[16]);
  run_title_menu(false);
  data29.words[16] := 4096;
  load_buffer_pair(0, 0, data29.words[16]);
  data29.words[30] := 19;
  data29.words[31] := 24;
  u1.exit_word := 0;
  index := -5887;
  store_word(index, data29.words[23]);
  index := index + 240;
  store_word(index, data29.words[24]);
  index := index + 288;
  store_word(index, data29.words[25]);
  require_utility_side(true);
  disk_blocks_io(16384, 3, data29.words[30] + 1, true);
  copy_raw_bytes(16384, -5887, 1440);
  header.word := 2048;
  disk_blocks_io(word_address(u1.words[12]), 1, data29.words[31] - 1, true);
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    selected := @u1.slots[index];
    if (selected^.words[8] > 0) and (selected^.words[8] <= 6) then
    begin
      disk_blocks_io(16384, 10, data29.words[31] + 10 * index, true);
      copy_raw_bytes(16384, word_address(u1.words[269]), 512);
      selected^.words[9] := u1.bytes[1004];
      selected^.saved_location := u1.place269;
      selected^.saved_clock := u1.stamp275;
      if selected^.words[15] <> even_odd_checksum(16384, 10) then
      begin
        selected^.words[8] := 6;
        if index = header.bytes^[1] then
        begin
          header.bytes^[1] := 255;
          disk_blocks_io(2048, 1, 80, false)
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
  paint_utility_catalog
end;
