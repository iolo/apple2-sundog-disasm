{ game_13 procedure23, $0E04..$0E75, attributes $0E80; nested in19.
  The second parameter is an unused VAR address. Preserve the first-city
  reread through the captured planet pointer after displaying the city. }
procedure show_city_details(marker_code: integer; var unused: integer);
var world_row: g13rowptr; {3}
begin
  world_row.word := data29.words[24] + 16 * (chosen_place.fields.planet - 1);
  if marker_code = 0 then
  begin
    write_wrapped_text('Orbit around ');
    write_wrapped_text(world_row.caption^)
  end
  else
  begin
    marker_code := marker_code - 1 + world_row.planetrow^.place7.mid6;
    write_wrapped_text('City:  ');
    write_wrapped_text(data29.names25.cities^[marker_code]);
    if marker_code = world_row.planetrow^.place7.mid6 then write_wrapped_text(' (starport)')
  end;
  text_newline
end;
