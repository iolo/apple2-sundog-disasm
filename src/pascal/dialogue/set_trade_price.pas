{ game_16 procedure3, $0080..$00D6, attributes $00E0.
  Direct amount updates100; item mode updates caption124. Both update106 and
  the price text. The implicit concat temporary is34 chars, then SAS31 stores
  back into108. Preserve the formatter's15-char view of that same buffer. }
procedure set_trade_price(value, direct: integer);
var
  price: integer;
begin
  if odd(direct) then
  begin
    price := value;
    make_amount(g16.offer_amount, 0, price)
  end
  else
  begin
    price := price_trade_item(value);
    g16.item_caption := data31.captions.table^[word_and(value, 31)]
  end;
  make_amount(g16.item_price, 0, price);
  integer_to_text(price, g16.price_prefix);
  g16.price_text := concat(g16.price_text, ' Cr')
end;
