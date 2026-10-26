{ game_13 procedure18, $124E..$12DA, attributes $12E4; nested in12.
  Parameters4..1: mapkind, VAR targetloc/found, allow (low-bit flag).
  The original condition reads the current planet's city count even when
  mapkind<>3 or saved flag21 is clear. Use local5 for that mandatory read
  before the Boolean test, then as the hit output supplied to19. }
procedure pick_map_destination(pick_kind: integer; var target_place: g19loc;
                    var selected: integer; can_confirm: integer);
var
  probe: g13rowptr; {5}
  code: integer;   {6}
(*$include src/pascal/spaceflight/poll_map_marker.pas*)
(*$include src/pascal/spaceflight/set_system_destination.pas*)
(*$include src/pascal/spaceflight/set_orbital_destination.pas*)
(*$include src/pascal/spaceflight/set_city_destination.pas*)
begin
  update_flight_state;
  code := 0;
  if data29.flags82[32] then
  begin
    selected := 1;
    target_place := data29.pos72;
    data29.flags82[32] := false
  end
  else
  begin
    probe.word := data29.words[24] + 16 * (data29.loc73.mid5 - 1);
    probe.word := probe.planetrow^.place7.low9 mod 8;
    if (pick_kind = 3) and ((not odd(mapstate[11])) or (probe.word = 1)) and
       odd(set_destination) then
    begin
      selected := 1;
      target_place := data29.pos72;
      code := 1
    end
    else poll_map_marker(code, probe.word, data29.words[298], data29.bnd343,
                    selected, target_place, pick_kind)
  end;
  if odd(selected) then
    case pick_kind of
      1: set_system_destination(code, target_place);
      2: set_orbital_destination(code, target_place);
      3: set_city_destination(code, target_place)
    end
end;
