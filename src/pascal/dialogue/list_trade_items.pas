{ game_16 procedure7, $01C2..$0208, attributes $0214.
  Zero stop means14. A nonpositive starting code does not increment, even
  though the item index advances. Keep both zero/false buffer-selection calls. }
procedure list_trade_items(first, last, draw: integer);
var
  index: integer;
  code: integer;
  limit: integer;
begin
  select_drawing_buffer(0, false);
  g16.first_icon_code := first;
  code := first;
  if last = 0 then last := 14;
  data31.words[16] := data31.words[10] + (last - first) + 1;
  index := first;
  limit := last;
  while index <= limit do
  begin
    place_trade_icon(code, index, draw);
    if code > 0 then code := code + 1;
    index := index + 1
  end;
  select_drawing_buffer(0, false)
end;
