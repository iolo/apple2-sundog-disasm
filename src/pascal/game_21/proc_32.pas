{ game_21 procedure32, $1684..$173F, attributes $1752.
  Draw the 20 by12 map interior, retaining row-major call order and the
  seven-pixel row advance. Case7 distinguishes the selected map cell. }
procedure proc21_32(xbase, ybase, pickx, picky: integer);
var
  column: integer;
  row: integer;
begin
  proc22_19(data29.bounds11, 8);
  proc22_11(3);
  row := 6;
  while row <= 17 do
  begin
    proc22_12(xbase, ybase);
    column := 10;
    while column <= 29 do
    begin
      case proc22_32(g21.map55.rows^[row][column], 15) of
        0: proc22_9(127);
        1: proc22_9(32);
        2, 3, 4, 5, 6: proc22_9(3);
        7: if (row = picky) and (column = pickx) then
             proc22_9(95)
           else proc22_9(29);
        8, 9, 10: proc22_9(4);
        11: proc22_9(94);
        12: proc22_9(5);
        13: proc22_9(23);
        14: proc22_9(6);
        15: proc22_9(7)
      end;
      column := column + 1
    end;
    ybase := ybase + 7;
    row := row + 1
  end
end;
