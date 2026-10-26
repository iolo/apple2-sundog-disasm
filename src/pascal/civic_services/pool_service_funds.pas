{ game_19 procedure5, $014C..$018C, attributes $0196.
  Capture the system row before comparisons and stores. MOV2 destinations
  precede their sources in the assembly. }
procedure pool_service_funds;
var
  table: g19addr;
begin
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
  begin
    if amount_greater(bank_balance, g19.zero_funds) then
    begin
      g19.working_funds := bank_balance;
      bank_balance := g19.zero_funds
    end
    else g19.working_funds := g19.zero_funds;
    add_amount(data29.money46, g19.working_funds)
  end
end;
