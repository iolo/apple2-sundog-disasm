{ game_13 procedure13, $0C2A..$0C92, attributes $0C9C; nested in12.
  Parameters: viewkind2, VAR chosenloc1. Preserve44 local bytes, including
  redraw23 and selector24. Children15/16 also use procedure12's mapstate,
  an array[6..11] of integer occupying its six local words.
  LNOT complements the entire word: redraw23 is -1 or -2, not1 or0. }
procedure render_map_view(render_kind: integer; var chosen_place: g19loc);
var
  unused: array[3..22] of integer;
  redraw_flag: integer;   {23}
  object_id: integer; {24}
(*$include src/pascal/spaceflight/paint_galaxy_map.pas*)
(*$include src/pascal/spaceflight/draw_orbital_map.pas*)
(*$include src/pascal/spaceflight/draw_planet_map.pas*)
begin
  update_flight_state;
  if render_kind = 3 then object_id := chosen_place.fields.planet
  else object_id := chosen_place.fields.system;
  redraw_flag := -2 + ord((not data29.flags82[5]) or
                    (data29.map_view_kind <> render_kind) or
                    (data29.map_object_id <> object_id));
  data29.flags82[5] := true;
  data29.map_view_kind := render_kind;
  data29.map_object_id := object_id;
  case render_kind of
    1: paint_galaxy_map(chosen_place);
    2: draw_orbital_map(chosen_place);
    3: draw_planet_map(chosen_place)
  end
end;
