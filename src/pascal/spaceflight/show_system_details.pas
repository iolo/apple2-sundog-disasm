{ game_13 procedure20, $0C9E..$0D47, attributes $0D52; nested in19.
  Capture the system-row address before printing; location comparison uses
  word37, not word73. Captions retain all original spaces. }
procedure show_system_details(system_index: integer);
var
  distance: integer; {2}
  world_row: g13rowptr;    {3}
begin
  world_row.word := data29.words[23] + 20 * (system_index - 1);
  write_wrapped_text('System:    ');
  write_wrapped_text(world_row.caption^);
  text_newline;
  if system_index = data29.loc37.low4 then write_wrapped_text('(current location)')
  else
  begin
    write_wrapped_text('Distance:  ');
    distance := system_distance(system_index, data29.loc37.low4);
    write_integer(distance, 2, false);
    write_wrapped_text(' j-secs');
    if (system_index = data29.warp_destination_system) and data29.flags82[0] then
      write_wrapped_text('  (current destination)')
  end;
  text_newline
end;
