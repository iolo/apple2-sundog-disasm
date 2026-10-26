{ game_21 procedure4, $0020..$0040, attributes $004A; nested in3.
  Set the cache bit only after the original unit-read call returns. }
procedure cache_tile_bank(cache_flag, load_address, bank_index: integer);
begin
  if not data29.flags82[cache_flag] then
  begin
    disk_blocks_io(load_address, 4, 6 + 4 * bank_index, true);
    data29.flags82[cache_flag] := true
  end
end;
