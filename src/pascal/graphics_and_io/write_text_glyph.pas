{ library_22 procedure 47, $08AA..$08D7, attributes $08E2.
  Position/bounds loads after drawing are deliberately not cached. }
procedure write_text_glyph(code: integer);
begin
  if data29.text_x > data29.text_right - 5 then text_newline;
  move_pen(data29.text_x, data29.text_y);
  draw_glyph(code);
  data29.text_x := data29.text_x + 6;
  if data29.text_x > data29.text_right - 5 then text_newline
end;
