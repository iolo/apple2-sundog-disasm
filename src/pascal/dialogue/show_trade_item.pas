{ game_16 procedure5, $0118..$0150, attributes $015A.
  Draw the full encoded item caption before masking its code. The16 unused
  local bytes have no nested consumer and are omitted. }
procedure show_trade_item(code, index: integer);
begin
  show_item_description(code);
  code := word_and(code, 31);
  if (index > data31.words[10]) and (code > 5) and (dialog_kind <> 15) then
  begin
    index := 6 * length(g16.price_text);
    move_pen(data31.words[8] - index, data31.words[6]);
    draw_text(g16.price_text)
  end
end;
