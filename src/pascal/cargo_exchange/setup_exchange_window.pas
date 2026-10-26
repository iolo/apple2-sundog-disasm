{ game_20 procedure32, $19B6..$1A07, attributes $1A10. }
procedure setup_exchange_window;
begin
  make_amount(g20.empty_amount, 0, 0);
  push_text_window(data29.words[40] div 7, data29.bytes[80] div 8);
  g20.saved_tick_limit := data29.words[353];
  data29.words[353] := 60;
  g20.saved_time_step := data29.words[351];
  data29.words[351] := 1;
  clear_text_window;
  g20.menu_left := 4;
  g20.menu_right := data29.words[13] - data29.words[14] - 4;
  g20.menu_bottom := data29.words[11] - data29.words[12] - 2
end;
