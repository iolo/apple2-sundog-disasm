{ game_20 procedure17, $0A96..$0ABE, attributes $0AC8; nested in16. }
procedure adjust_market_price(var value: integer; left, right: integer);
var
  factor: integer;
(*$include src/pascal/cargo_exchange/scaled_market_product.pas*)
begin
  factor := 8 + word_abs(left - right);
  if left >= right then value := scaled_market_product(factor, value, 8)
  else value := scaled_market_product(8, value, factor)
end;
