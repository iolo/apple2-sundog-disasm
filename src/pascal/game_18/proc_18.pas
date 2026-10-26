{ game_18 procedure 18, $0CD0..$0D50, attributes $0D5C. }
procedure proc18_18;
var
  rightedge, leftedge, column: integer;
begin
  fillchar(g18refs, 6, data29.words[293]);
  column := 0;
  while column <= 2 do
  begin
    leftedge := g18w131 + (column * (g18a112[130] - g18w131)) div 3;
    rightedge := g18w131 + ((column + 1) * (g18a112[130] - g18w131)) div 3;
    proc22_14(leftedge + 10, rightedge - 10,
              g18a112[128] - 6, g18a112[128]);
    proc22_7(9);
    if column < 2 then
    begin
      { $0D2B..$0D32: FJP examines bit zero of the edge coordinate. }
      if odd(rightedge) then rightedge := rightedge + 1;
      proc22_14(rightedge - 1, rightedge,
                g18a112[128] - 9, g18a112[128]);
      proc22_7(10)
    end;
    column := column + 1
  end
end;
