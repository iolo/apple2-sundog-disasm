{ game_20 procedure1, $1A12..$1A64, attributes $1A70.
  Load25/28 before setup. The original exit attribute targets the release
  epilogue at $1A53, which requires explicit binding in the game runtime. }
procedure run_cargo_exchange(exchange_kind: integer);
var
(*$include src/pascal/cargo_exchange/locals.pas*)
(*$include src/pascal/cargo_exchange/wait_exchange_buttons.pas*)
(*$include src/pascal/cargo_exchange/market_record_io.pas*)
(*$include src/pascal/cargo_exchange/finish_delivery_phase.pas*)
(*$include src/pascal/cargo_exchange/load_market_state.pas*)
(*$include src/pascal/cargo_exchange/save_market_state.pas*)
(*$include src/pascal/cargo_exchange/poll_exchange_menu.pas*)
(*$include src/pascal/cargo_exchange/add_exchange_buttons.pas*)
(*$include src/pascal/cargo_exchange/flash_exchange_title.pas*)
(*$include src/pascal/cargo_exchange/find_empty_cargo_slot.pas*)
(*$include src/pascal/cargo_exchange/choose_cargo_slot.pas*)
(*$include src/pascal/cargo_exchange/run_warehouse_menu.pas*)
(*$include src/pascal/cargo_exchange/setup_exchange_window.pas*)
(*$include src/pascal/cargo_exchange/cargo_unit_price.pas*)
(*$include src/pascal/cargo_exchange/decrement_market_level.pas*)
(*$include src/pascal/cargo_exchange/refresh_market_offer.pas*)
(*$include src/pascal/cargo_exchange/quote_cargo_transaction.pas*)
(*$include src/pascal/cargo_exchange/select_trade_storage.pas*)
(*$include src/pascal/cargo_exchange/sell_or_deliver_cargo.pas*)
(*$include src/pascal/cargo_exchange/cargo_space_available.pas*)
(*$include src/pascal/cargo_exchange/buy_exchange_lots.pas*)
(*$include src/pascal/cargo_exchange/run_exchange_window.pas*)
begin
  rtldseg(25);
  rtldseg(28);
  setup_exchange_window;
  run_exchange_window(exchange_kind = 4);
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := 6;
    data29.nibbles45[0] := 11
  end;
  data29.words[353] := g20.saved_tick_limit;
  data29.words[351] := g20.saved_time_step;
  if data29.nibbles45[2] <> 13 then pop_text_window;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(28);
  rtrlseg(25)
end;
