{ game_13 procedure26, $10C4..$123B, attributes $124C; nested in18.
  Reuse private pointer slot4 for table views; the VAR location address is
  stable. Parent result writes and packed stores stay ordered. Failed access
  still leaves the earlier city/coordinate/default writes in place.
  Grandparent mapstate11 is the saved flag21, not its current global value. }
procedure proc13_26(codevalue: integer; var place: g19loc);
var
  gate: integer;  {3; also holds the random case selector}
  row: g13rowptr; {4}
begin
  if codevalue = 0 then
  begin
    place.fields.city := 0;
    place.fields.xcoord := 0;
    place.fields.ycoord := 0;
    place.fields.kind2 := 0;
    place.fields.kind3 := 0;
    found := 1
  end
  else
  begin
    row.word := data29.words[24] + 16 * (place.fields.planet - 1);
    place.fields.city := row.planetrow^.place7.mid6 + codevalue - 1;
    row.word := data29.words[25] + 12 * (place.fields.city - 1);
    place.fields.xcoord := row.cityrow^.coords5.low6;
    row.word := data29.words[25] + 12 * (place.fields.city - 1);
    place.fields.ycoord := row.cityrow^.coords5.mid5;
    place.fields.word4 := 140 + 10;
    place.fields.w5low := 96 + 19;
    row.word := data29.words[24] + 16 * (place.fields.planet - 1);
    if row.planetrow^.place7.mid6 = place.fields.city then
    begin
      found := 1;
      row.word := data29.words[24] + 16 * (place.fields.planet - 1);
      gate := row.bytes^[10];
      place.fields.kind2 := 10 + gate mod 20;
      place.fields.kind3 := 6 + gate div 20
    end
    else if odd(mapstate[11]) then
    begin
      found := 1;
      if place.fields.city = 60 then
      begin
        place.fields.kind2 := 19;
        place.fields.kind3 := 12
      end
      else
      begin
        gate := proc22_3;
        case gate mod 4 of
          0: begin
               place.fields.kind2 := proc22_40(10, 30);
               place.fields.kind3 := 5
             end;
          1: begin
               place.fields.kind2 := 31;
               place.fields.kind3 := proc22_40(6, 17)
             end;
          2: begin
               place.fields.kind2 := proc22_40(10, 30);
               place.fields.kind3 := 18
             end;
          3: begin
               place.fields.kind2 := 9;
               place.fields.kind3 := proc22_40(6, 17)
             end
        end
      end
    end
    else found := 0
  end
end;
