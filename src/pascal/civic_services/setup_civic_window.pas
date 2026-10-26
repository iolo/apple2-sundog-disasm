{ game_19 procedure26, $131C..$13A0, attributes $13AA. }
procedure setup_civic_window;
var
  table: g19addr;
begin
  push_text_window(data29.words[40] div 7, data29.bytes[80] div 8);
  g19.saved_tick_limit := data29.words[353];
  data29.words[353] := 60;
  g19.saved_time_step := data29.words[351];
  data29.words[351] := 1;
  g19.trip_completed := 0;
  clear_text_window;
  g19.menu_left := 4;
  g19.menu_right := data29.words[13] - data29.words[14] - 4;
  g19.menu_bottom := data29.words[11] - data29.words[12] - 2;
  make_amount(g19.zero_funds, 0, 0);
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
  begin
    g19.depot_rating := nibbles8[3];
    g19.transport_rate := nibbles8[4];
    g19.repair_discount := nibbles8[5]
  end
end;
