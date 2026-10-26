{ game_21 procedure32, $1684..$173F, attributes $1752.
  Draw the 20 by12 map interior, retaining row-major call order and the
  seven-pixel row advance. Case7 distinguishes the selected map cell. }
procedure paint_city_overview(xbase, ybase, pickx, picky: integer);
var
  column: integer;
  row: integer;
begin
  apply_bounds(data29.bounds11, 8);
  set_glyph_mode(3);
  row := 6;
  while row <= 17 do
  begin
    move_pen(xbase, ybase);
    column := 10;
    while column <= 29 do
    begin
      case word_and(g21.map_buffer.rows^[row][column], 15) of
        0: draw_glyph(127);
        1: draw_glyph(32);
        2, 3, 4, 5, 6: draw_glyph(3);
        7: if (row = picky) and (column = pickx) then
             draw_glyph(95)
           else draw_glyph(29);
        8, 9, 10: draw_glyph(4);
        11: draw_glyph(94);
        12: draw_glyph(5);
        13: draw_glyph(23);
        14: draw_glyph(6);
        15: draw_glyph(7)
      end;
      column := column + 1
    end;
    ybase := ybase + 7;
    row := row + 1
  end
end;
