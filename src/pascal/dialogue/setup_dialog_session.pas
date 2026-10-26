{ game_16 procedure37, $13E4..$171C, attributes $172A.
  Keep48 local bytes. The captured system-row pointer uses compiler slot24;
  formerly unused slots hold the address view and loop bound. Trailing equal
  table offsets are scanned without a lower bound, as in the original. }
procedure setup_dialog_session;
var
  system_rows: g16addr;
  unused2: integer;
  unused3: integer;
  unused4: integer;
  unused5: integer;
  record_index: integer;
  last_offset: integer;
  last_index: integer;
  unused9: array[9..23] of integer;
(*$include src/pascal/dialogue/fill_item_availability.pas*)
(*$include src/pascal/dialogue/start_dialog_context.pas*)
begin
  fillchar(g16.alt0_action, 6, chr(0));
  g16.phrase_disk_block := data29.words[26];
  g16.script_disk_base := g16.phrase_disk_block + 2;
  g16.saved_text_bounds := data29.bounds11;
  g16.saved_clock_bounds := data29.bounds327;
  assign_bounds(data29.bounds327, 0, 0, 0, 0);
  g16.saved_tick_limit := data29.words[353];
  data29.words[353] := 150;
  g16.saved_time_step := data29.words[351];
  data29.words[351] := 1;
  make_amount(g16.zero_amount, 0, 0);
  g16.item_price := g16.zero_amount;
  g16.offer_amount := g16.zero_amount;
  g16.buttons_enabled := 0;
  g16.selling_mode := 0;
  g16.price_text := '';
  g16.item_caption := '';
  g16.cached_choice := 0;
  g16.reuse_choice := 0;
  system_rows.word := data29.words[23];
  with system_rows.rows^[data29.loc37.low4] do
  begin
    g16.words[16] := ord(bits5.flag7);
    g16.words[32] := nibbles8[3];
    g16.price_scale := nibbles8[4];
    g16.words[31] := nibbles8[5];
    g16.words[29] := nibbles8[7]
  end;
  if not odd(window_x) then window_x := window_x + word_sign(20 - window_x);
  push_text_window(window_x, window_y);
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  setup_item_panel(1);
  g16.words[34] := data31.words[16];
  assign_bounds(g16.dialog_bounds, data31.words[12] + 39, data31.words[12] + 133,
              data31.words[11] + 2, data31.words[11] + 80);
  apply_bounds(g16.dialog_bounds, 8);
  assign_bounds(g16.trade_bounds, data31.words[12] + 39, data31.words[12] + 133,
              data31.words[11] + 32, data31.words[11] + 80);
  apply_bounds(g16.trade_bounds, 8);
  data29.flags82[117] := false;
  g16.words[20] := ord(data29.bytes[552] <> 0);
  g16.response_level := data29.bytes[549];
  g16.words[87] := 11 + (16 - g16.words[32]) div 6;
  g16.words[88] := 15 + (16 - g16.words[32]) div 2;
  g16.words[89] := 23 + 2 * ((g16.words[31] - 1) div 3);
  fill_item_availability(88, 89, 8, 9);
  if data29.bytes[544] <> data29.pos36.fields.city then
  begin
    data29.flags82[80] := (data29.clock42.hour < 3) or (data29.clock42.hour > 6);
    fill_item_availability(90, 94, 10, g16.words[87]);
    fill_item_availability(95, 102, 15, g16.words[88]);
    fill_item_availability(103, 111, 23, g16.words[89]);
    data29.bytes[544] := data29.pos36.fields.city
  end;
  assign_bounds(g16.dialog_buttons[2], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[68] - 14, g16.words[68] - 2);
  assign_bounds(g16.dialog_buttons[1], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[68] - 30, g16.words[68] - 18);
  assign_bounds(g16.dialog_buttons[0], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[69] + 2, g16.words[68] - 34);
  data29.flags82[117] := false;
  store_word(18432, g16.script_bytes.word);
  store_word(18432 + 512, g16.phrase_bytes.word);
  disk_blocks_io(18432 + 512, 2, g16.phrase_disk_block, true);
  g16.words[47] := 0;
  index_phrase_pages(0, 0, 0);
  record_index := 64;
  last_offset := g16.phrase_bytes.bytes^[record_index];
  while last_offset = g16.phrase_bytes.bytes^[record_index - 1] do record_index := record_index - 1;
  g16.phrase_insert_index := record_index;
  g16.script_bank := -1;
  g16.item12_13_weight := 0;
  g16.item11_weight := 0;
  record_index := 0;
  last_index := 3;
  while record_index <= last_index do
  begin
    if data29.bytes[122 + record_index] = 12 then g16.item12_13_weight := g16.item12_13_weight + 1
    else if word_and(data29.bytes[122 + record_index], 31) = 13 then
      g16.item12_13_weight := g16.item12_13_weight + 2
    else if word_and(data29.bytes[122 + record_index], 31) = 11 then
      g16.item11_weight := g16.item11_weight + 2;
    record_index := record_index + 1
  end;
  draw_panel_items_after(0);
  g16.context_amount := g16.price_scale;
  start_dialog_context;
  set_glyph_mode(1);
  initialize_pointer(g16.cursor_x, g16.cursor_y, 2, data31.bounds2);
  g16.exit_requested := 0
end;
