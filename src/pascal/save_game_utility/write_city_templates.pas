{ utility_disk1:14 $03E0..$057F, attributes$0590, nested in9.
  100-byte frame with code rows18..44 and reused slot46. Source templates
  have28-byte stride, output rows32. Copy the second seven words FIRST.
  Flush/clear at16 rows; the final54-byte code copy and two-row advance are
  preserved without invented padding, flushes or initialization of spare bits. }
procedure write_city_templates;
var seed_layout_frame: u14frame;
(*$include src/pascal/save_game_utility/decode_seed_row.pas*)
begin
  store_word(2048, seed_layout_frame.city_output_buffer.word);
  store_word(2048 + 512, seed_layout_frame.template_address.word);
  disk_blocks_io(2048 + 512, 1, data29.words[30], true);
  data29.bytes[544] := 0;
  seed_layout_frame.rotation_index := (seed_layout_frame.template_address.bytes^[504] + 5) mod 18;
  seed_layout_frame.template_address.bytes^[504] := seed_layout_frame.rotation_index;
  data29.bytes[543] := seed_layout_frame.rotation_index;
  fillchar(seed_layout_frame.city_output_buffer.bytes^, 512, 0);
  seed_layout_frame.output_row := 0;
  seed_layout_frame.write_block := 3;
  seed_layout_frame.planet_index := 1;
  seed_layout_frame.words[46] := 18;
  while seed_layout_frame.planet_index <= seed_layout_frame.words[46] do
  begin
    seed_layout_frame.chosen_template := (seed_layout_frame.rotation_index + (seed_layout_frame.planet_index - 1)) mod 18 + 1;
    seed_layout_frame.planet_record.word := data29.words[24] + (seed_layout_frame.planet_index - 1) * 16;
    seed_layout_frame.seed_template.template := @seed_layout_frame.template_address.table^[seed_layout_frame.chosen_template];
    seed_layout_frame.city_index := 1;
    seed_layout_frame.city_count := seed_layout_frame.planet_record.planet^.flags7.count;
    while seed_layout_frame.city_index <= seed_layout_frame.city_count do
    begin
      seed_layout_frame.output_city_record.row := @seed_layout_frame.city_output_buffer.rows^[seed_layout_frame.output_row];
      seed_layout_frame.output_city_record.row^.second := seed_layout_frame.seed_template.template^.second;
      seed_layout_frame.output_city_record.row^.first := seed_layout_frame.seed_template.template^.first;
      seed_layout_frame.output_city_record.row^.flag14 := -16;
      seed_layout_frame.output_city_record.row^.bytes15.high := 0;
      seed_layout_frame.output_city_record.row^.bytes15.low := 0;
      seed_layout_frame.output_row := seed_layout_frame.output_row + 1;
      if seed_layout_frame.output_row = 16 then
      begin
        disk_blocks_io(2048, 1, new_game_frame.save_block + seed_layout_frame.write_block, false);
        seed_layout_frame.output_row := 0;
        fillchar(seed_layout_frame.city_output_buffer.bytes^, 512, 0);
        seed_layout_frame.write_block := seed_layout_frame.write_block + 1
      end;
      seed_layout_frame.city_index := seed_layout_frame.city_index + 1
    end;
    seed_layout_frame.planet_index := seed_layout_frame.planet_index + 1
  end;
  seed_layout_frame.code_row := 0;
  decode_seed_row('@@@@HIKM');
  decode_seed_row('@@JLNU__');
  decode_seed_row('@@TV____');
  decode_seed_row('@HPQRSW_');
  decode_seed_row('@ILXYZ__');
  decode_seed_row('@QRU[___');
  decode_seed_row('CFIOQ^__');
  decode_seed_row('BDENTY__');
  decode_seed_row('BGPXZ\]_');
  moveleft(seed_layout_frame.packed_seed_rows, seed_layout_frame.city_output_buffer.rows^[seed_layout_frame.output_row], 54);
  seed_layout_frame.output_row := seed_layout_frame.output_row + 2;
  seed_layout_frame.work46.row := @seed_layout_frame.city_output_buffer.rows^[seed_layout_frame.output_row];
  seed_layout_frame.work46.row^.flag14 := -16;
  seed_layout_frame.work46.row^.bytes15.high := 1;
  seed_layout_frame.work46.row^.bytes15.low := 1;
  disk_blocks_io(2048, 1, new_game_frame.save_block + seed_layout_frame.write_block, false)
end;
