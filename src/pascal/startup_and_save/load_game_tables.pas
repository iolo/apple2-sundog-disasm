{ startup_7 procedure6, $02C0..$0395, attributes $03A2; nested in1.
  The one-word parent pointer copy,6140-byte fill, and raw negative addresses
  are deliberate. The six-block operation at$0302 is a WRITE (flag0).
  Preserve eight120-byte copies with128-byte spacing and parent loop slot14. }
procedure load_game_tables;
var
  dest_address: integer; {1}
  source_address: integer; {2}
  table_address: integer; {3}
  unused: integer; {4}
  last_row: integer; {5}
begin
  data29.words[15] := 2048;
  data29.words[33] := 16384;
  release(data29.addr33.bytes);
  table_address := -5887;
  store_word(table_address, data29.words[23]);
  table_address := table_address + 240;
  store_word(table_address, data29.words[24]);
  table_address := table_address + 288;
  store_word(table_address, data29.words[25]);
  s7.memory := data29.addr33;
  disk_blocks_io(16384 + 512, 6, data29.words[30] + 3, false);
  copy_raw_bytes(16384 + 3584, -5887, 1440);
  fillchar(s7.memory.bytes^, 6140, 0);
  disk_blocks_io(5632, 1, data29.words[30] + 1, true);
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  load_buffer_pair(1, 1, data29.words[15]);
  load_buffer_pair(2, 0, data29.words[16]);
  source_address := data29.words[16];
  dest_address := 1024;
  s7.words[14] := 0;
  last_row := 7;
  while s7.words[14] <= last_row do
  begin
    copy_raw_bytes(source_address + s7.words[14] * 128, dest_address + s7.words[14] * 128, 120);
    s7.words[14] := s7.words[14] + 1
  end
end;
