{ game_20 procedure27, $1584..$1660, attributes $1670.
  Poll input1 even after failed capacity check; random offer refresh also runs
  its random call in contract mode. Buying charges before storage selection. }
(*$warning goto false*)
procedure buy_exchange_lots(slot: integer);
label 1, 2;
var
  free_index, choice, column, row, message, selected: integer;
  amount: wordpair;
  item: stock4;
  caption: g20text;
  room: boolean;
  cancel_poll: integer;
  random_value: integer;
begin
1:
    room := cargo_space_available(free_index);
    cancel_poll := poll_input(1);
    if not (room and not (odd(cancel_poll) or odd(data29.words[347]))) then goto 2;
    reset_menu;
    add_exchange_buttons(g20.menu_bottom - 10, 1, 2, 'Buy', 'Pass', '');
    clear_text_window;
    column := data29.text_x;
    row := data29.text_y;
    choice := 0;
    message := 1;
    repeat
      data29.text_x := column;
      data29.text_y := row;
      random_value := random_word;
      if (random_value mod 8 = 0) and not odd(g20.contract_mode) then refresh_market_offer(-1);
      quote_cargo_transaction(slot, item, caption, amount, false, message);
      if amount <> g20.empty_amount then
        poll_exchange_menu(choice, free_index, data29.words[297], data29.bounds11, selected)
      else choice := 0;
      if choice = 2 then slot := (slot + 1) mod 8
    until (choice <> 2) or odd(data29.words[347]);
    if choice = 0 then exit(buy_exchange_lots);
    refresh_market_offer(slot);
    if amount <> g20.empty_amount then
    begin
      if not odd(g20.contract_mode) then subtract_amount(amount, g20.trading_cash);
      select_trade_storage(item, slot, amount, false);
      decrement_market_level(item.kind, false)
    end;
  goto 1;
2:
end;
(*$warning goto true*)
