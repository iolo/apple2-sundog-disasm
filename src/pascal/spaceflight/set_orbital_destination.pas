{ game_13 procedure25, $102E..$10B8, attributes $10C2; nested in18.
  Use the stable VAR address directly and reuse private pointer slot3 for
  table views. Reread the packed planet index after its possibly truncating
  store, and reread the planet table pointer for each coordinate. }
procedure set_orbital_destination(marker_code: integer; var place: g19loc);
var world_row: g13rowptr; {3}
begin
  if (marker_code > 0) and (marker_code <= 3) then
  begin
    world_row.word := data29.words[23] + 20 * (place.fields.system - 1);
    place.fields.planet := world_row.sysrow^.bits5.mid5 + marker_code - 1;
    world_row.word := data29.words[24] + 16 * (place.fields.planet - 1);
    place.fields.w0high := world_row.planetrow^.coords6.high;
    world_row.word := data29.words[24] + 16 * (place.fields.planet - 1);
    place.fields.w0low := world_row.planetrow^.coords6.low
  end
  else
  begin
    place.fields.planet := 0;
    place.fields.w0high := 43;
    place.fields.w0low := marker_code
  end;
  place.fields.city := 0;
  place.fields.xcoord := 0;
  place.fields.ycoord := 0;
  place.fields.kind2 := 0;
  place.fields.kind3 := 0
end;
