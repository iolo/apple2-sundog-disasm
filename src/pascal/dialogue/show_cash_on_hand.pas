{ game_16 procedure46, $1A50..$1AB9, attributes $1AC4.
  Preserve the exact captions and high/low formatting choices. The original
  unused16 local bytes are omitted; no nested procedure consumes them. }
procedure show_cash_on_hand;
begin
  apply_bounds(data31.bounds6, 8);
  move_pen(data31.words[9], data31.words[6]);
  if (g16.words[105] = 0) and (g16.words[104] = 0) then draw_text(' no money')
  else
  begin
    if g16.words[104] = 0 then draw_integer(g16.words[105], 8, false)
    else
    begin
      draw_integer(g16.words[104], 5, false);
      draw_integer(g16.words[105], 3, true)
    end;
    draw_text(' Cr on hand')
  end;
  wait_dialog_input;
  apply_bounds(data31.bounds6, 8)
end;
