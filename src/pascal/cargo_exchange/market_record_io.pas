{ game_20 procedure3, $002C..$0095, attributes $009E.
  Read the block before multiplying count/index. All copies use forward CSP2.
  Operation2 still reads the block; only operation3 writes it back. }
procedure market_record_io(block, record_bytes, record_index, operation: integer);
var
  byte_offset: integer;
begin
  disk_blocks_io(g20.market_buffer.word, 1, block, true);
  byte_offset := record_bytes * record_index;
  case operation of
    1:
      begin
        if odd(g20.contract_mode) then
          moveleft(g20.market_buffer.bytes^[288], g20.phase_table.bytes^, 54);
        moveleft(g20.market_buffer.bytes^[byte_offset], g20.demand_levels, record_bytes)
      end;
    3: moveleft(g20.demand_levels, g20.market_buffer.bytes^[byte_offset], record_bytes);
    4: moveleft(g20.market_buffer.bytes^[byte_offset], g20.demand_target, record_bytes)
  end;
  if operation = 3 then disk_blocks_io(g20.market_buffer.word, 1, block, false)
end;
