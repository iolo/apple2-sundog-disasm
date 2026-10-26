{ game_21 procedure28, $10F2..$12C2, attributes $12D6.
  Cache miss decodes the planet map, then randomizes tile13 in column-major
  order under temporary random state. City markers are written on cache hits
  too. Special city60 placement retries without an invented attempt limit. }
procedure proc21_28;
var
  planetno, cached, part, column, row, firstcity, lastcity, index: integer;
  randomv: integer;
  target: address16;
  saved: wordpair;
  seed: wordpair;
  scratch: address16;
  planet: g19paddr;
  cityrow: g19caddr;
begin
  planetno := data29.loc37.mid5 - 1;
  scratch.word := 20480;
  cached := scratch.bytes^[1000];
  if cached <> planetno + 1 then
  begin
    scratch.word := 6144;
    proc22_53(scratch.word, 1, data29.words[29] + planetno div 2, true);
    part := planetno mod 2;
    proc23_2(scratch.word + 256 * part + 16, g21.map55.word);
    moveleft(data29.words[21], saved, 4);
    seed.first := 3 * data29.loc37.mid5 + 39;
    seed.second := 11 * data29.loc37.mid5 + 51;
    moveleft(seed, data29.words[21], 4);
    column := 0;
    while column <= 39 do
    begin
      row := 0;
      while row <= 23 do
      begin
        if g21.map55.rows^[row][column] = 13 then
        begin
          { Capture the destination before the random call, as in $118A. }
          target.word := g21.map55.word + 40 * row + column;
          randomv := proc22_3;
          target.bytes^[0] := 14 + randomv mod 7
        end;
        row := row + 1
      end;
      column := column + 1
    end;
    moveleft(saved, data29.words[21], 4)
  end;
  planet.word := data29.words[24] + 16 * (data29.loc37.mid5 - 1);
  firstcity := planet.rows^[1].place7.mid6;
  lastcity := planet.rows^[1].place7.low9 mod 8 + firstcity - 1;
  index := firstcity;
  while index <= lastcity do
  begin
    cityrow.word := data29.words[25] + 12 * (index - 1);
    g21.map55.rows^[cityrow.rows^[1].coords5.mid5]
                   [cityrow.rows^[1].coords5.low6] := 13;
    index := index + 1
  end;
  if data29.loc37.mid5 = 1 then
  begin
    cityrow.word := data29.words[25] + 12 * (60 - 1);
    if data29.flags82[112] then
    begin
      data29.flags82[112] := false;
      repeat
        randomv := proc22_3;
        index := randomv mod 960;
        cityrow.rows^[1].coords5.low6 := index mod 40;
        cityrow.rows^[1].coords5.mid5 := index div 40
      until g21.map55.rows^[cityrow.rows^[1].coords5.mid5]
                           [cityrow.rows^[1].coords5.low6] >= 14
    end;
    g21.map55.rows^[cityrow.rows^[1].coords5.mid5]
                   [cityrow.rows^[1].coords5.low6] := 13
  end;
  scratch.word := 20480;
  scratch.bytes^[1000] := data29.loc37.mid5;
  arg8 := 4;
  arg7 := 4;
  data29.flags82[116] := false;
  arg6 := (data29.bits38.low6 - 5 + 40) mod 40;
  arg5 := (data29.bits39.low5 - g21.words[23] + 24) mod 24;
  if arg5 > 20 then arg5 := 0;
  proc21_9
end;
