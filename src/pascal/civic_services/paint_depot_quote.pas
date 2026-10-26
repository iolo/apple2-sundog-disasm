{ game_19 procedure19, $0DD0..$0E39, attributes $0E42; nested in18.
  The price comparison always executes, even with no remaining units. }
procedure paint_depot_quote;
var
  no_units_needed, insufficient_cash: boolean;
begin
  data29.text_x := quote_x;
  data29.text_y := quote_y;
  write_integer(units_needed, 3, false);
  write_text_glyph(32);
  write_wrapped_text(unitname);
  if units_needed = 1 then write_wrapped_text(' \') else write_wrapped_text('s\');
  write_captioned_amount('Cash on hand ', g19.working_funds);
  no_units_needed := units_needed = 0;
  insufficient_cash := amount_greater(unit_cost, g19.working_funds);
  purchase_blocked := no_units_needed or insufficient_cash or (quantity = 16)
end;
