{ Library 22:12, $016C..$018A, attributes $0194. Two words, no result. }
procedure move_pen(firstpos, secondpos: integer);
begin
  if data29.line_mode > 0 then          { $016C..$0172 }
    draw_line(data29.pen_x, data29.pen_y,
               firstpos, secondpos);    { $0174..$017E }
  data29.pen_x := firstpos;         { $0180..$0181 }
  data29.pen_y := secondpos         { $0185..$0186 }
end;
