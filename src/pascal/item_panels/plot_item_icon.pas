{ library_27 procedure 3, $0044..$0081, attributes $008C.
  The native OR forces the low bit of the first coordinate. }
procedure plot_item_icon(firstpos, secondpos: integer);
begin
  firstpos := word_or(firstpos, 1);
  move_pen(firstpos - 7, secondpos);
  draw_glyph(data31.words[76]);
  move_pen(firstpos - 7, secondpos + 8);
  draw_glyph(data31.words[74]);
  move_pen(firstpos, secondpos);
  draw_glyph(data31.words[75]);
  move_pen(firstpos, secondpos + 8);
  draw_glyph(data31.words[73])
end;
