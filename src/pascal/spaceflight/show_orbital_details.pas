{ game_13 procedure21, $0D88..$0DF7, attributes $0E02; nested in19.
  Code0 and codes>3 are warp points; negative values retain the planet path.
  Row pointer3 is reused for the planet and retained across display calls. }
procedure show_orbital_details(marker_code: integer);
var
  planet: integer; {2}
  world_row: g13rowptr;  {3}
(*$include src/pascal/spaceflight/write_mark_location.pas*)
begin
  if (marker_code = 0) or (marker_code > 3) then
  begin
    write_wrapped_text('Warp point\');
    write_mark_location(marker_code, 100)
  end
  else
  begin
    world_row.word := data29.words[23] + 20 * (chosen_place.fields.system - 1);
    planet := world_row.sysrow^.bits5.mid5 + marker_code - 1;
    world_row.word := data29.words[24] + 16 * (planet - 1);
    write_wrapped_text('Planet:  ');
    write_wrapped_text(world_row.caption^);
    text_newline;
    write_mark_location(world_row.planetrow^.coords6.low, 2 * world_row.planetrow^.coords6.high + 14)
  end
end;
