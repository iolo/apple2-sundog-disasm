{ Game 18:8, $01AE..$0316, attributes $0328. Frame arguments 4=index,
  3=firstpos address, 2=secondpos address, 1=found address. }
procedure proc18_8(index: integer; var firstpos, secondpos, found: integer);
var
  attempts: integer;
  upper: integer;
  lower: integer;
  available: integer;
  column: integer;
  row: integer;
begin
  found := 0;                                      { $01AE..$01B0 }
  if odd(g18a133[139]) then                        { $01B1..$01B5 }
  begin
    available := 6;                               { $01B7..$01B8 }
    { $01BA..$01BB stores unused local constant 2; no observable effect. }
    if data29.flags82[65] and g18items[1].flags.bit2 then
    begin                                         { $01BD..$01E7 }
      row := (g18items[1].flags.high_byte - 4) div 2;
      column := 0
    end
    else
    begin                                         { $01E9..$01F9 }
      row := proc22_3;
      row := row mod 3;
      column := proc22_3;
      column := column mod 2
    end;
    while (g18refs[row][column] <> 0) and (available >= 0) do
    begin                                         { $01FB..$0227 }
      available := available - 1;
      column := column + 1;
      if column > 1 then
      begin
        row := (row + 1) mod 3;
        column := 0
      end
    end;
    if available >= 0 then                        { $0229..$022C }
    begin
      found := 0;                                 { $022E..$0230 }
      lower := g18w131 + ((row * (g18a112[130] - g18w131)) div 3);
      upper := g18w131 + (((row + 1) * (g18a112[130] - g18w131)) div 3);
      attempts := 0;                              { $0231..$025C }
      repeat                                      { $025E..$029A }
        if column = 0 then firstpos := lower + 3
        else firstpos := upper - 7;
        secondpos := g18a112[128];
        if not proc18_3(24, firstpos, secondpos) then
          found := 1
        else
          column := (column + 1) mod 2;
        attempts := attempts + 1
      until (found > 0) or (attempts = 2);
      if found > 0 then                           { $029C..$02A0 }
      begin
        g18items[index].flags.high_byte := (4 + (2 * row)) + column;
        g18refs[row][column] := index;              { $02A2..$02BF }
        if g18refs[row][(column + 1) mod 2] = 1 then
          with g18items[index] do                 { $02C0..$02D9 }
          begin
            flags.bit0 := true;                   { $02DB..$02E1 }
            if data29.flags82[65] then
              split8.high := data29.bytes[548]    { word271 base + 8 bytes. }
            else
              split8.high := 0;                   { $02E2..$0300 }
            flags.bit1 := data29.flags82[65];      { $0301..$030E: reread. }
            split8.low := 4                       { $030F..$0315 }
          end
      end
    end
  end
end;
