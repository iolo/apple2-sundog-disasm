{ game_16 procedure2, $0000..$0073, attributes $007E.
  Clamp shared numerator/denominator before scaling; read the caption row's
  byte15 as a weight regardless of its text length. Added raw-address local
  has no nested consumers. }
function price_trade_item(code: integer): integer;
var
  ceiling: integer;
  weight: integer;
  scale: integer;
  entry: address16;
begin
  code := word_and(code, 31);
  if g16.price_numerator < 0 then g16.price_numerator := 0;
  if g16.price_denominator <= 0 then g16.price_denominator := 1;
  scale := g16.price_numerator * g16.price_scale div g16.price_denominator;
  entry.word := data31.words[1] + 16 * code;
  weight := entry.bytes^[15];
  if (15 <= code) and (code <= 22) then
  begin
    ceiling := 42;
    weight := weight + weight + weight
  end
  else if not data29.flags82[80 + code] then
  begin
    ceiling := 64;
    weight := weight + weight
  end
  else ceiling := 128;
  clamp_word(1, scale, ceiling);
  price_trade_item := scale * weight
end;
