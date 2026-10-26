{ game_8 procedure13, $0552..$05BF, attributes $05CA.
  Original eight local words are unread. Keep the two-word currency format,
  including its ordered nonpositive test and exact display strings. }
procedure paint_cash_caption;
begin
  write_item_caption('');
  move_pen(data31.words[9], data31.words[6]);
  if (data29.words[47] <= 0) and (data29.words[46] <= 0) then
    draw_text(' no money')
  else begin
    if data29.words[46] = 0 then draw_integer(data29.words[47], 8, false)
    else begin
      draw_integer(data29.words[46], 5, false);
      draw_integer(data29.words[47], 3, true)
    end;
    draw_text(' Cr')
  end;
  draw_text(' on hand');
  wait_personal_input;
  write_item_caption('')
end;
