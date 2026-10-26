{ library_22 procedure 41, $06FA..$070E, attributes $0718.
  The position call can change external storage: load word 374 afterwards. }
procedure toggle_pointer_glyph(firstpos, secondpos: integer);
begin
  set_glyph_mode(1);
  move_pen(firstpos - 3, secondpos + 3);
  draw_glyph(data29.words[374]);
  set_glyph_mode(0)
end;
