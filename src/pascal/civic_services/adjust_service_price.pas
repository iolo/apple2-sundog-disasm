{ game_19 procedure22, $10AE..$10D6, attributes $10E0; nested in21. }
procedure adjust_service_price(var value: integer; left, right: integer);
var
  factor: integer;
(*$include src/pascal/civic_services/scaled_service_product.pas*)
begin
  factor := 8 + word_abs(left - right);
  if left >= right then value := scaled_service_product(factor, value, 8)
  else value := scaled_service_product(8, value, factor)
end;
