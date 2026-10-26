{ game_16 procedure11, $04AA..$0575, attributes $0582.
  Item rejection repeats with fixed limits. Capture the item predicate before
  the unconditional8(30),8(166) calls; reread item41 after both calls.
  Reuse previously unused locals for temporaries, keeping the24-byte frame. }
procedure choose_trade_item;
var
  last_item_code: integer;       {1}
  first_item_code: integer;
  random_modulus: integer;
  item_allowed: boolean;     {4}
  random_value: integer;
  saved_denominator: integer;
  check_encoding: boolean;
  first_test: boolean;
  second_test: boolean;
  unused10: integer;
  unused11: integer;
  unused12: integer;
begin
  if g16.trade_item_code = 0 then
  begin
    first_item_code := 12;
    if dialog_kind = 17 then last_item_code := 22
    else if dialog_kind = 15 then last_item_code := 18
    else last_item_code := 31;
    repeat
      g16.trade_item_code := random_between(first_item_code, last_item_code);
      item_allowed := data29.flags82[80 + g16.trade_item_code];
      if (g16.trade_item_code < 14) or (g16.trade_item_code > 22) then item_allowed := not item_allowed
    until item_allowed
  end;
  if dialog_kind >= 17 then
  begin
    g16.price_denominator := 20;
    if g16.trade_item_code > 22 then random_modulus := 2 else random_modulus := 12;
    saved_denominator := g16.price_denominator + 4;
    random_value := random_word;
    g16.price_numerator := saved_denominator + random_value mod random_modulus;
    check_encoding := g16.trade_item_code > 14;
    first_test := odd(test_dialog_condition(30));
    second_test := odd(test_dialog_condition(166));
    if check_encoding and not (first_test or second_test) then
      g16.trade_item_code := g16.trade_item_code + 128;
    if odd(g16.selling_mode) then
    begin
      g16.price_direction := -1;
      random_modulus := g16.price_numerator;
      g16.price_numerator := g16.price_denominator;
      g16.price_denominator := random_modulus
    end
    else g16.price_direction := 1
  end;
  set_trade_price(g16.trade_item_code, 0);
  if dialog_kind = 15 then set_trade_price(0, 1)
end;
