{ game_16 procedure48, $1B90..$1BAC, attributes $1BB6. }
function item_trade_eligible: boolean;
begin
  if odd(g16.selling_mode) then item_trade_eligible := 10 <= g16.trade_item_code
  else item_trade_eligible := data29.flags82[80 + g16.trade_item_code]
end;
