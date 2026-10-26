{ game_20 procedure7, $0442..$0508, attributes $0512.
  Preserve disk operation order and the final bank pointer re-evaluation. }
procedure save_market_state;
var
  city: integer;
  systems: g19addr;
begin
  if odd(g20.contract_mode) then moveleft(g20.bonus_accumulator, data29.bytes[546], 2);
  city := data29.bits37.mid6 - 1;
  g20.city_store_rows.rows^[city] := g20.warehouse_items;
  disk_blocks_io(5120, 2, data29.words[30] + 3, false);
  disk_blocks_io(5120 + 512, 1, data29.words[30] + 1, true);
  g20.market_buffer.word := 22528 + 1024;
  market_record_io(data29.words[30] + 5 + city div 16, 32, city mod 16, 3);
  systems.word := data29.words[23];
  if amount_greater(g20.empty_amount, systems.rows^[data29.loc37.low4].bank_balance) then
    data29.money46 := g20.trading_cash
  else
  begin
    if amount_greater(g20.trading_cash, data29.money46) then
      subtract_amount(data29.money46, g20.trading_cash)
    else
    begin
      data29.money46 := g20.trading_cash;
      g20.trading_cash := g20.empty_amount
    end;
    systems.word := data29.words[23];
    systems.rows^[data29.loc37.low4].bank_balance := g20.trading_cash
  end
end;
