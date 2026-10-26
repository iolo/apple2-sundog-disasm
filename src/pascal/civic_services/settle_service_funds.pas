{ game_19 procedure6, $0198..$01ED, attributes $01F6.
  Original EQU12,2 compares four bytes. The two signed-word equalities here
  are equivalent bitwise equality tests without intervening side effects. }
procedure settle_service_funds;
var
  table: g19addr;
begin
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
    if (bank_balance.first = g19.zero_funds.first) and
       (bank_balance.second = g19.zero_funds.second) then
    begin
      if amount_greater(g19.working_funds, data29.money46) then
        subtract_amount(data29.money46, g19.working_funds)
      else
      begin
        data29.money46 := g19.working_funds;
        g19.working_funds := g19.zero_funds
      end;
      bank_balance := g19.working_funds
    end
    else data29.money46 := g19.working_funds
end;
