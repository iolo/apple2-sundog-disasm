{ game_16 procedure4, $00E2..$010C, attributes $0116.
  Copy both value words before changing draw mode. Negative high words take
  the original single-low-word path, without normalization. }
procedure draw_dialog_amount(amount: wordpair);
begin
  set_glyph_mode(3);
  if amount.first > 0 then
  begin
    draw_integer(amount.first, 5, false);
    draw_glyph(44);
    draw_integer(amount.second, 3, true)
  end
  else
  begin
    draw_glyph(32);
    draw_integer(amount.second, 8, false)
  end
end;
