{ game_13 procedure24, $1000..$1022, attributes $102C; nested in18.
  Clear all12 location bytes before setting system, height and random heading.
  The compiler uses the stable VAR address directly; retain the original
  private pointer slot3 as unused storage. }
procedure set_system_destination(marker_code: integer; var place: g19loc);
var unused3: integer;
begin
  fillchar(place, 12, 0);
  place.fields.system := marker_code;
  place.fields.w0high := 43;
  place.fields.w0low := random_between(0, 255)
end;
