{ game_13 procedure39, $1D5C..$1F85, attributes $1F92; nested in27.
  Copy system-row words6/7 as raw signed words before any display calls; these
  overlap the caption view. Do not substitute the trailing words8/9.
  All four error paths self-EXIT39; the enclosing27 still performs its copies.
  Native transition mutates packet byte3; preserve the original VAR call. }
procedure perform_planetary_trip(var place: g19loc);
var
  neither: integer; {2, unused result of original complement}
  landing: boolean; {3}
  lifting: boolean; {4}
  unused5: integer;
  unused6: integer;
  unused7: integer;
  dest_city: integer;{8}
  origin_city: integer; {9}
  unused10: integer;
  dest_name: text15; {11..18}
  origin_name: text15;  {19..26}
  debts: wordpair;  {27..28}
(*$include src/pascal/spaceflight/name_city_or_orbit.pas*)
(*$include src/pascal/spaceflight/pack_view_transition.pas*)
begin
  origin_city := data29.pos72.fields.city;
  dest_city := place.fields.city;
  moveleft(data29.tbl23.rows^[data29.loc37.low4].prefix8[6], debts, 4);
  lifting := (origin_city <> 0) and (dest_city = 0);
  landing := origin_city = 0;
  neither := -1 - ord(lifting or landing);
  name_city_or_orbit(origin_name, origin_city);
  name_city_or_orbit(dest_name, dest_city);
  write_flight_plan('PLANETARY', origin_name, dest_name);
  if data29.fuel_amount = 0 then
  begin
    show_flight_error(0);
    exit(perform_planetary_trip)
  end
  else if data29.bytes[178 + 52] = 0 then
  begin
    show_flight_error(5);
    exit(perform_planetary_trip)
  end
  else if lifting and ((debts.first < 0) or (debts.second < 0)) then
  begin
    show_flight_error(6);
    exit(perform_planetary_trip)
  end
  else if odd(saved_clearance_block) and lifting then
  begin
    show_flight_error(3);
    exit(perform_planetary_trip)
  end;
  update_flight_state;
  load_travel_overlay(119, 2, 7, 0, 1);
  data29.clock80 := data29.clock42;
  data29.pos66 := place;
  data29.flags82[30] := (origin_city = 0) and (dest_city <> 0);
  data29.flags82[38] := true;
  data29.flags82[40] := false;
  apply_bounds(data29.bnd303, 5);
  data29.flags82[25] := false;
  data29.travel_kind := 3;
  data29.map_view_kind := 3;
  data29.flags82[5] := false;
  if (origin_city = 0) or (dest_city = 0) then data29.travel_span := 5
  else data29.travel_span := 20;
  add_clock_minutes(data29.clock80, data29.travel_span);
  write_wrapped_text('ETA:   ');
  draw_clock(data29.clock80);
  text_newline;
  if (data29.shield_setting > 0) or data29.flags82[4] or data29.flags82[12] then
  begin
    write_wrapped_text('Turning off ');
    if data29.flags82[12] then write_wrapped_text('cloaker ');
    if data29.flags82[4] or (data29.shield_setting > 0) then
    begin
      if data29.flags82[12] then write_wrapped_text('and ');
      write_wrapped_text('shields')
    end;
    data29.shield_setting := 0;
    data29.flags82[4] := false;
    data29.flags82[12] := false;
    draw_vertical_gauge(data29.shield_gauge_bounds, data29.shield_charge, 4, 5)
  end;
  write_wrapped_text('\Switching to viewscreen');
  if lifting then pack_view_transition(-1, origin_city, 0)
  else if landing then pack_view_transition(0, dest_city, 0)
  else pack_view_transition(1, origin_city, dest_city);
  call_planet_transition(packet, 6144);
  data29.clock42 := data29.clock80;
  data29.words[354] := data29.words[353] + 1;
  update_flight_state;
  data29.pos72 := data29.pos66;
  data29.words[350] := 0
end;
