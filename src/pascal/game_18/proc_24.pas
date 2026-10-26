{ game_18 procedure 24, $1372..$142C, attributes $1436. }
procedure proc18_24;
var
  neighbor, column, row: integer;
begin
  with g18items[1] do
  begin
    row := ((words[5] + 3 - g18w131) * 3) div (g18a112[130] - g18w131);
    if proc22_35(words[5] - (g18w131 +
        (row * (g18a112[130] - g18w131)) div 3)) < 10 then column := 0
    else column := 1;
    g18refs[row][column] := 1;
    flags.high_byte := (4 + 2 * row) + column;
    neighbor := g18refs[row][(column + 1) mod 2]
  end;
  with g18items[neighbor] do
      if (neighbor > 0) and flags.bit2 then
        if not flags.bit5 then
        begin
          if flags.bit0 and flags.bit1 and data29.flags82[65] then
            g18a112[116] := 17
          else g18a112[116] := 21;
          data29.bytes[550] := neighbor;
          g18a133[141] := 1
        end
end;
