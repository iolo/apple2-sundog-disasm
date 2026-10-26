{ game_20 procedure25, $147A..$1514, attributes $1520.
  Retain the bonus accumulator snapshot before price/shift calls. The initial
  unused paid value and message word are not given invented initial values. }
procedure sell_or_deliver_cargo;
var
  slot, cursor, message: integer;
  amount: wordpair;
  item: stock4;
  caption: g20text;
  previous_bonus: integer;
  earned_bonus: integer;
begin
  select_trade_storage(item, slot, amount, true);
  if slot = 0 then exit(sell_or_deliver_cargo);
  clear_text_window;
  quote_cargo_transaction(slot, item, caption, amount, true, message);
  if amount <> g20.empty_amount then
  begin
    decrement_market_level(item.kind, true);
    if odd(g20.contract_mode) then
    begin
      previous_bonus := g20.bonus_accumulator;
      earned_bonus := cargo_unit_price(item, true);
      g20.bonus_accumulator := previous_bonus + right_shift_word(earned_bonus, 2);
      finish_delivery_phase;
      cursor := 0;
      while cursor <= 7 do
      begin
        refresh_market_offer(cursor);
        cursor := cursor + 1
      end
    end
    else add_amount(amount, g20.trading_cash);
    fillchar(item, 4, 0);
    if slot > 4 then data29.stock234[slot - 4] := item
    else g20.warehouse_items[slot] := item
  end
end;
