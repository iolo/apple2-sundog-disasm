{ game_15 procedure8, $02E8..$0371, attributes $037C.
  Write through the EXISTING pointer26 before replacing it. Caller11 sets
  native entry7=3904, so the conditional raw call uses the reviewed screen
  initializer, with DATASEG29 word58 as its unused VAR argument. }
procedure load_ship_interior;
var
  block: integer;
begin
  g15.overlay_text.text^ := '    ';
  g15.overlay_text.word := 16384;
  disk_blocks_io(g15.words[26], 4, data29.words[32] + 12, true);
  if odd(g15.saved_overlay_flag) then call_screen_initializer(data29.words[58], g15.raw_entry_address);
  if data29.flags82[7] then block := data29.words[32]
  else block := data29.words[32] + 4;
  disk_blocks_io(g15.words[26], 4, block, true);
  g15.overlay_text.word := 6144;
  decode_hires_image;
  g15.overlay_flag_index := 22;
  assign_bounds(data29.bounds327, 0, 0, 0, 0);
  assign_bounds(data29.bnd307, 0, 0, 0, 0);
  assign_bounds(data29.bnd303, 0, 0, 0, 0);
  apply_bounds(data29.bounds7, 0);
  g15.raw_entry_address := 5120
end;
