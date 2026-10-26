{ game_21 procedure26, $0EAE..$105D, attributes $106E.
  Generate the city interior in column-major order, saving/restoring both
  random-state words. Random is called for every cell, including clipped ones.
  flag28 expects a tile12: if none exists, the original uses uninitialized
  found coordinates; no default or repair is introduced here. }
procedure proc21_26;
var
  find12: boolean;
  xlow, xhigh, ylow, yhigh: integer;
  tile, column, row, foundx, foundy: integer;
  block, part, cached, randomv: integer;
  saved: wordpair;
  seed: wordpair;
  scratch: address16;
  source: g21cptr;
begin
  find12 := data29.flags82[28];
  block := (data29.bits37.mid6 - 1) div 4 + data29.words[28];
  part := (data29.bits37.mid6 - 1) mod 4;
  scratch.word := 21504;
  cached := scratch.bytes^[1000];
  scratch.word := 6144;
  if (cached <> data29.bits37.mid6) or data29.flags82[114] then
  begin
    proc22_53(scratch.word, 1, block, true);
    proc21_17(xlow, xhigh, ylow, yhigh);
    moveleft(data29.words[21], saved, 4);
    seed.first := 3 * data29.bits37.mid6 + 39;
    seed.second := 11 * data29.bits37.mid6 + 51;
    moveleft(seed, data29.words[21], 4);
    source.word := scratch.word + 128 * part;
    fillchar(g21.map55.rows^, 960, 0);
    column := 10;
    while column <= 29 do
    begin
      row := 6;
      while row <= 17 do
      begin
        tile := source.city^.tiles[column - 10][row - 6];
        if find12 and (tile = 12) then
        begin
          foundx := column;
          foundy := row
        end;
        randomv := proc22_3;
        tile := tile + 16 * (randomv mod 2);
        if not odd(g21.words[35]) then
          g21.map55.rows^[row][column] := tile
        else if (xlow < column) and (column < xhigh) and
                (ylow < row) and (row < yhigh) then
          g21.map55.rows^[row][column] := tile;
        row := row + 1
      end;
      column := column + 1
    end;
    moveleft(saved, data29.words[21], 4)
  end;
  arg8 := (data29.loc37.low4 - 1) mod 4;
  arg7 := (data29.loc37.mid5 - 1) mod 4;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  scratch.word := 21504;
  scratch.bytes^[1000] := data29.bits37.mid6;
  if find12 then
  begin
    data29.bits38.low6 := foundx;
    data29.bits39.low5 := foundy
  end;
  if not data29.flags82[114] then
  begin
    arg6 := (data29.bits38.low6 - 5 + 40) mod 40;
    arg5 := (data29.bits39.low5 - g21.words[23] + 24) mod 24
  end
  else data29.flags82[114] := false;
  proc21_9;
  proc21_8
end;
