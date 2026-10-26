{ game_21 procedure30, $133C..$159C, attributes $15AE.
  Check one eight-block group with at most two reads; a persistent checksum
  failure displays the error code then loops forever, as at $1401.
  Shared modes/flags and VAR parameters are reread after calls and stores. }
procedure setup_surface_session;
label 1;
var
  checksum_address: address16;  {slot1}
  reads_left: integer;   {2}
  group_block: integer;      {3}
  system_row: g19addr;     {4}
begin
  select_drawing_buffer(data29.words[16], false);
  assign_bounds(g21.pointer_bounds, data29.words[10] + 4, data29.words[9] - 4,
                        data29.words[8] + 4, data29.words[7] - 4);
  if odd(exit_requested) then data29.nibbles45[1] := data29.nibbles45[2];
  if data29.nibbles45[2] = 3 then
  begin
    if data29.nibbles45[1] = 2 then
    begin
      g21.check_overlay_entry := 6144;
      group_block := data29.bytes[540];
      reads_left := 2;
      store_word(g21.check_overlay_entry + right_shift_word(data29.bytes[540], 2), checksum_address.word);
      disk_blocks_io(g21.check_overlay_entry, 1, data29.words[30] + 9, true);
      repeat
        disk_blocks_io(16384, 8, group_block - 3, true);
        call_disk_checksum(g21.disk_checksum, g21.check_overlay_entry + 64);
        reads_left := reads_left - 1
      until (checksum_address.value^ = g21.disk_checksum) or (reads_left <= 0);
      if checksum_address.value^ <> g21.disk_checksum then
      begin
        apply_bounds(data29.bounds7, 8);
        move_pen(0, 10);
        draw_integer(117 + right_shift_word(group_block, 3), 4, false);
1:      goto 1
      end;
      group_block := group_block + 8;
      if group_block = 48 then group_block := 56;
      data29.bytes[540] := group_block;
      store_word(20480, checksum_address.word);
      fillchar(checksum_address.bytes^, 2048, data29.words[293])
    end;
    if data29.bits73.mid6 = data29.bits37.mid6 then
    begin
      g21.ship_x_cell := data29.pos72.fields.kind2;
      g21.ship_y_cell := data29.pos72.fields.kind3;
      g21.ship_x_offset := data29.words[76] mod 28;
      g21.ship_y_offset := data29.pos72.fields.w5low mod 32
    end
    else
    begin
      g21.ship_x_cell := -1;
      g21.ship_y_cell := -1;
      g21.ship_x_offset := -1;
      g21.ship_y_offset := -1
    end;
    if (data29.pos228.fields.city = data29.bits37.mid6) and
       not data29.flags82[7] and data29.flags45[13] then
    begin
      g21.parked_x_cell := data29.pos228.fields.kind2;
      g21.parked_y_cell := data29.pos228.fields.kind3;
      g21.parked_x_offset := data29.words[232] mod 28;
      g21.parked_y_offset := data29.pos228.fields.w5low mod 32
    end
    else
    begin
      g21.parked_x_cell := -1;
      g21.parked_y_cell := -1;
      g21.parked_x_offset := -1;
      g21.parked_y_offset := -1
    end
  end;
  system_row.word := data29.words[23] + 20 * (data29.loc37.low4 - 1);
  g21.chase_threshold := system_row.rows^[1].nibbles8[3];
  g21.fare_factor := system_row.rows^[1].nibbles8[4];
  g21.fare_discount_factor := system_row.rows^[1].nibbles8[5];
  choose_surface_glyphs;
  g21.planet_view := ord(data29.nibbles45[2] = 4);
  if odd(g21.planet_view) then prepare_planet_view else setup_city_view;
  g21.saved_tick_limit := data29.words[353];
  data29.words[353] := 15;
  g21.saved_time_step := data29.words[351];
  data29.words[351] := 1;
  place_surface_player;
  data29.words[2] := 9;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.flags45[12] := data29.flags45[13];
  initialize_pointer(g21.cursor_x, g21.cursor_y, data29.words[298], g21.pointer_bounds);
  exit_requested := 0;
  tile_or_action := 0;
  g21.was_moving := poll_input(4);
  g21.was_moving := poll_input(0);
  g21.was_moving := 0;
  g21.teleport_ready := 0;
  data29.flags82[28] := false;
  g21.last_x_step := 32767;
  g21.last_y_step := 32767
end;
