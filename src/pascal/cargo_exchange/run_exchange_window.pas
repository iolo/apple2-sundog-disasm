{ game_20 procedure28, $18FE..$19A7, attributes $19B4.
  The early EXIT after setup bypasses procedure7. Nested31 writes suffix. }
procedure run_exchange_window(haspods: boolean);
var
  mode: integer;       {2}
  choice: integer;     {3}
  suffix: text15;      {4..11}
(*$include src/pascal/cargo_exchange/scroll_market_ticker.pas*)
(*$include src/pascal/cargo_exchange/choose_exchange_action.pas*)
(*$include src/pascal/cargo_exchange/paint_exchange_heading.pas*)
begin
  g20.pods_available := ord(haspods);
  load_market_state;
  if data29.nibbles45[2] = 13 then exit(run_exchange_window);
  g20.ticker_x := data29.words[14];
  g20.ticker_y := data29.words[11];
  if odd(g20.pods_available) then mode := 0 else mode := 1;
  paint_exchange_heading;
  for choice := 0 to 7 do refresh_market_offer(choice);
  choice := 0;
  g20.ticker_head := 0;
  repeat
    if ((choice > 0) and (choice < 4)) or (choice = 5) then paint_exchange_heading;
    choose_exchange_action(mode, choice);
    case choice of
      0: if odd(g20.pods_available) and (mode = 1) then
         begin
           choice := 6;
           mode := 0
         end;
      1: buy_exchange_lots(g20.ticker_head div 21);
      2: sell_or_deliver_cargo;
      3, 5: run_warehouse_menu;
      4: mode := 1
    end
  until (choice = 0) or odd(data29.words[347]);
  save_market_state
end;
