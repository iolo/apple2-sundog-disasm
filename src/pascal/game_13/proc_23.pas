{ game_13 procedure23, $0E04..$0E75, attributes $0E80; nested in19.
  The second parameter is an unused VAR address. Preserve the first-city
  reread through the captured planet pointer after displaying the city. }
procedure proc13_23(codevalue: integer; var unused: integer);
var row: g13rowptr; {3}
begin
  row.word := data29.words[24] + 16 * (chosen.fields.planet - 1);
  if codevalue = 0 then
  begin
    proc22_48('Orbit around ');
    proc22_48(row.caption^)
  end
  else
  begin
    codevalue := codevalue - 1 + row.planetrow^.place7.mid6;
    proc22_48('City:  ');
    proc22_48(data29.names25.cities^[codevalue]);
    if codevalue = row.planetrow^.place7.mid6 then proc22_48(' (starport)')
  end;
  proc22_45
end;
