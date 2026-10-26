{ game_20 procedure23, $0F24..$1244, attributes $1256.
  All outputs except selling are VAR. Buying requires cash strictly greater
  than the offer, not greater-or-equal. Caption padding writes bytes directly. }
procedure quote_cargo_transaction(var slot: integer; var item: stock4; var caption: g20text;
                    var amount: wordpair; selling: boolean; var message: integer);
var
  valid, affordable: boolean;
  tries, negotiable, cursor, value, textlen, choice, found, selected: integer;
  paid: wordpair;
begin
  valid := false;
  tries := 0;
  negotiable := 1;
  repeat
    if selling then
    begin
      cursor := item.kind;
      valid := true
    end
    else
    begin
      if tries > 0 then slot := (slot + 1) mod 8;
      with g20.market_offers[slot] do
      begin
        make_amount(amount, word1 div 10, 100 * (word1 mod 10));
        affordable := amount_greater(g20.trading_cash, amount);
        valid := affordable and (kind > 0)
      end;
      tries := tries + 1
    end
  until valid or (tries = 8);
  if not valid then
  begin
    clear_text_window;
    if odd(message) then write_wrapped_text('No goods available or affordable');
    message := 0;
    amount := g20.empty_amount;
    fillchar(item, 4, 0);
    caption.text := g20.cargo_names.names^[0];
    wait_exchange_buttons;
    exit(quote_cargo_transaction)
  end;
  message := 0;
  if not selling then
    with g20.market_offers[slot] do
    begin
      item.kind := kind;
      item.category := origin;
      item.origin := data29.bits37.mid6;
      item.word1 := word1
    end
  else if not odd(g20.contract_mode) then
    if (item.kind = 1) or (item.kind = 31) then negotiable := 0
    else
    begin
      value := cargo_unit_price(item, true);
      make_amount(amount, value div 10, 100 * (value mod 10))
    end;
  caption.text := g20.cargo_names.names^[item.kind];
  textlen := length(caption.text);
  cursor := textlen + 1;
  while cursor <= 14 do
  begin
    caption.bytes[cursor] := 32;
    cursor := cursor + 1
  end;
  caption.bytes[0] := 14;
  if odd(g20.contract_mode) then
  begin
    write_wrapped_text('|  TO BE DELIVERED\|\|    ');
    write_wrapped_text(caption.text);
    text_newline;
    text_newline;
    write_wrapped_text('Demand:    ');
    negotiable := g20.demand_levels.values[item.kind];
    make_amount(amount, 0, negotiable);
    if negotiable = 0 then write_wrapped_text('none')
    else
    begin
      write_integer(negotiable, 1, false);
      write_wrapped_text(' unit');
      if negotiable <> 1 then write_text_glyph(115)
    end
  end
  else
  begin
    write_wrapped_text('|  PRICE ON GOODS\|    ');
    write_wrapped_text(caption.text);
    text_newline;
    write_wrapped_text('Quality:           ');
    write_text_glyph(72 - item.category);
    text_newline;
    if negotiable = 0 then write_wrapped_text('Item not negotiable ')
    else if selling then
    begin
      make_amount(paid, item.word1 div 10, 100 * (item.word1 mod 10));
      write_captioned_amount('Price paid: ', paid);
      write_captioned_amount('Offered:    ', amount)
    end
    else write_captioned_amount('Asking:     ', amount)
  end;
  if selling then
  begin
    reset_menu;
    if negotiable = 0 then
      add_exchange_buttons(g20.menu_bottom - 10, 2, 1, 'Exit', '', '')
    else if odd(g20.contract_mode) then
      add_exchange_buttons(g20.menu_bottom - 10, 1, 2, 'Deliver', 'Withhold', '')
    else add_exchange_buttons(g20.menu_bottom - 10, 1, 2, 'Accept', 'Withdraw', '');
    poll_exchange_menu(choice, found, data29.words[297], data29.bounds11, selected);
    if choice <> 1 then amount := g20.empty_amount
  end
  else write_captioned_amount('Your limit: ', g20.trading_cash)
end;
