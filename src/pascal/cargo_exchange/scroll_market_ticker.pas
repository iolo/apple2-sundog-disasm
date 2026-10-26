{ game_20 procedure29, $1672..$16E6, attributes $16F2; nested in28.
  Display22 bytes from the168-byte ring, then advance its head by one.
  The random call after the clock update also occurs in contract mode. }
procedure scroll_market_ticker;
var
  ring_offset, char_index, random_value: integer;
begin
  set_glyph_mode(3);
  move_pen(g20.ticker_x, g20.ticker_y);
  ring_offset := g20.ticker_head;
  for char_index := 1 to 22 do
  begin
    draw_glyph(g20.ticker_bytes[ring_offset]);
    ring_offset := (ring_offset + 1) mod 168
  end;
  g20.ticker_head := (g20.ticker_head + 1) mod 168;
  data29.words[354] := data29.words[354] + 1;
  if data29.words[354] >= 10 then
  begin
    advance_clock_and_conditions;
    random_value := random_word;
    if (random_value mod 8 = 0) and not odd(g20.contract_mode) then
      refresh_market_offer(((g20.ticker_head + 40) mod 168) div 21)
  end
end;
