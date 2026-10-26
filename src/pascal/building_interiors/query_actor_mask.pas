{ Game 18:3, $0022..$0034, attributes $003E. Frame 5=code, 4=first,
  3=second, 1..2=result reservation. Native 22:9 mode 2 writes 0/1 to word 1. }
function query_actor_mask(code, query_x, query_y: integer): boolean;
begin
  set_glyph_mode(2);                         { $0022..$0023 }
  move_pen(query_x, query_y);        { $0026..$0028 }
  draw_glyph(code);                       { $002B..$002C }
  query_actor_mask := odd(data29.words[1])       { $002F..$0032; known canonical 0/1. }
end;
