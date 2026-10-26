{ game_15 procedure12, $06EE..$0700, attributes $070A.
  Return the whole word1 after the mode2 native draw/query, without coercing
  it to Boolean. Arguments occupy slots5=code,4=x,3=y. }
function query_glyph_collision(code, x, y: integer): integer;
begin
  set_glyph_mode(2);
  move_pen(x, y);
  draw_glyph(code);
  query_glyph_collision := data29.words[1]
end;
