{ game_20 procedure5, $026C..$0435, attributes $0440.
  Preserve post-random packed reads and the seven-word padding comparisons.
  The phase bonus occurs before the later cash snapshot, as in the listing. }
procedure load_market_state;
var
  template_index: integer;
  index: integer;
  elapsed_weeks: integer; {slot3, first city-1, later elapsed whole weeks}
  random_value: integer;
  systems: g19addr;
(*$include src/pascal/cargo_exchange/grow_market_levels.pas*)
begin
  g20.contract_mode := ord(data29.bits37.mid6 = 60);
  store_word(5120, g20.city_store_rows.word);
  disk_blocks_io(5120, 2, data29.words[30] + 3, true);
  store_word(22528, g20.cargo_names.word);
  if g20.cargo_names.names^[31] <> 'cryogens' then
    disk_blocks_io(22528, 1, data29.words[30] + 2, true);
  g20.phase_table.word := 22528 + 512;
  elapsed_weeks := data29.bits37.mid6 - 1;
  template_index := (data29.loc37.mid5 - 1 + data29.bytes[543]) mod 18;
  g20.warehouse_items := g20.city_store_rows.rows^[elapsed_weeks];
  g20.market_buffer.word := 22528 + 1024;
  market_record_io(data29.words[30] + 5 + elapsed_weeks div 16, 32, elapsed_weeks mod 16, 1);
  market_record_io(data29.words[30], 28, template_index, 4);
  if g20.market_day < 0 then
  begin
    if odd(g20.contract_mode) then
    begin
      g20.supply_levels := g20.supply_target;
      fillchar(g20.demand_levels, 14, 0)
    end
    else
    begin
      index := 1;
      while index <= 30 do
      begin
        random_value := random_word;
        g20.supply_levels.values[index] := random_value mod (g20.supply_levels.values[index] + 1);
        random_value := random_word;
        g20.demand_levels.values[index] := random_value mod (g20.demand_levels.values[index] + 1);
        index := index + 1
      end
    end;
    g20.market_day := data29.clock42.day
  end
  else if not odd(g20.contract_mode) then
  begin
    elapsed_weeks := (data29.clock42.day - g20.market_day) div 7;
    if elapsed_weeks > 0 then
    begin
      if g20.demand_levels <> g20.demand_target then grow_market_levels(g20.demand_target, g20.demand_levels);
      if g20.supply_levels <> g20.supply_target then grow_market_levels(g20.supply_target, g20.supply_levels);
      g20.market_day := data29.clock42.day
    end
  end;
  if odd(g20.contract_mode) then
  begin
    finish_delivery_phase;
    moveleft(data29.bytes[546], g20.bonus_accumulator, 2)
  end;
  g20.trading_cash := data29.money46;
  systems.word := data29.words[23];
  with systems.rows^[data29.loc37.low4] do
  begin
    g20.words[8] := nibbles8[3];
    g20.system_price_scale := nibbles8[4];
    g20.grade_price_scale := nibbles8[5];
    if amount_greater(bank_balance, g20.empty_amount) then
    begin
      add_amount(bank_balance, g20.trading_cash);
      bank_balance := g20.empty_amount
    end
  end
end;
