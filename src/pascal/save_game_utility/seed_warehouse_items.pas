{ utility_disk1:16 $0592..$0640, attributes$064E, nested in9.
  Nine local words;1/4/5 unused,2 number,3 index,6 buffer,7 source,8 limit,
  9 item pointer. Retry occupied entries without advancing index. Preserve
  random-call order,1024-byte clear,32-byte copy and final two-block write. }
procedure seed_warehouse_items;
var
  unused1: integer;
  city_index: integer;
  seed_index: integer;
  unused4: array[4..5] of integer;
  buffer: u16addr;
  source: address16;
  limit: integer;
  cargo_item: ^stock4;
begin
  data29.flags82[112] := true;
  data29.bytes[541] := 0;
  data29.bytes[542] := 0;
  new_game_frame.inventory_buffer_address := 2048;
  buffer.word := new_game_frame.inventory_buffer_address;
  source.word := 5120;
  fillchar(buffer.bytes^, 1024, 0);
  city_index := random_between(1, 57);
  seed_index := 1;
  limit := 17;
  while seed_index <= limit do
  begin
    repeat
      city_index := (city_index + ((random_word + 0) mod 4 + 1)) mod 57 + 1
    until buffer.rows^[city_index, 1].kind = 0;
    cargo_item := @buffer.rows^[city_index, 1];
    cargo_item^.kind := 31;
    cargo_item^.category := 7;
    cargo_item^.origin := city_index;
    seed_index := seed_index + 1
  end;
  disk_blocks_io(source.word, 1, new_game_frame.save_block + 6, true);
  moveleft(source.bytes^[352], buffer.bytes^[960], 32);
  disk_blocks_io(buffer.word, 2, new_game_frame.save_block + 1, false)
end;
