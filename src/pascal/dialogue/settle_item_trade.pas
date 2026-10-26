{ game_16 procedure42, $1748..$178B, attributes $1796; nested in41.
  Transfer price before updating elapsed ticks/item count, then dispatch the
  first action with previous item7. Both buffer-selection calls remain. }
procedure settle_item_trade;
begin
  if odd(g16.selling_mode) then add_amount(g16.item_price, g16.cash_amount)
  else subtract_amount(g16.item_price, g16.cash_amount);
  g16.dialog_timeout := g16.dialog_timeout + 2;
  data31.words[16] := data31.words[16] - 1;
  select_drawing_buffer(0, false);
  g16.trade_item_code := exchanged_code;
  dispatch_dialog_action(g16.choice0_action, 0);
  select_drawing_buffer(0, false)
end;
