{ game_13 procedure36, $1A4A..$1C31, attributes $1C3C; nested in27.
  Slot2 captures the height predicate so the native mask still runs when
  that predicate is false. The two errors self-EXIT36 before movement writes.
  Retain signed delta wrap at strictly greater128/less than-128. }
procedure start_sublight_trip(var place: g19loc);
var
  at_warp_radius: boolean; {2, originally unused}
  y: integer;       {3}
  x: integer;       {4}
  dest_planet: integer;{5}
  origin_planet: integer; {6}
  distance: integer;{7}
  unused8: integer;
  dest_name: text15; {9..16}
  origin_name: text15;  {17..24}
(*$include src/pascal/spaceflight/name_orbital_location.pas*)
begin
  origin_planet := data29.pos72.fields.planet;
  dest_planet := place.fields.planet;
  name_orbital_location(origin_name, origin_planet, (data29.pos72.fields.w0high = 43) and
                             (data29.pos72.fields.w0low mod 16 = 0));
  name_orbital_location(dest_name, dest_planet, true);
  write_flight_plan('IN-SYSTEM', origin_name, dest_name);
  update_flight_state;
  if data29.fuel_amount = 0 then
  begin
    show_flight_error(0);
    exit(start_sublight_trip)
  end
  else if data29.bytes[178 + 52] = 0 then
  begin
    show_flight_error(5);
    exit(start_sublight_trip)
  end;
  project_polar_point(data29.pos72.fields.w0low, data29.pos72.fields.w0high, x, y);
  apply_bounds(data29.bnd343, 0);
  x := (x - 3) + right_shift_word(data29.words[346] + data29.words[345], 1);
  y := (y + 3) + right_shift_word(data29.words[344] + data29.words[343], 1);
  move_pen(x, y);
  set_glyph_mode(1);
  if origin_planet > 0 then draw_glyph(data29.words[297])
  else
  begin
    at_warp_radius := data29.pos72.fields.w0high = 43;
    if (word_and(data29.pos72.fields.w0low, 15) = 0) and at_warp_radius then
      draw_glyph(43)
  end;
  apply_bounds(data29.bounds11, 0);
  data29.clock80 := data29.clock42;
  data29.pos66 := place;
  data29.flags82[1] := true;
  data29.travel_kind := 2;
  data29.map_object_id := data29.pos66.fields.system;
  data29.flags82[5] := true;
  data29.heading_delta := data29.pos66.fields.w0low - data29.pos72.fields.w0low;
  if data29.heading_delta > 128 then data29.heading_delta := data29.heading_delta - 256
  else if data29.heading_delta < -128 then data29.heading_delta := data29.heading_delta + 256;
  data29.radial_delta := data29.pos66.fields.w0high - data29.pos72.fields.w0high;
  distance := word_abs(data29.radial_delta) div 3 +
              right_shift_word(word_abs(data29.heading_delta) *
                        (data29.pos66.fields.w0high + data29.pos72.fields.w0high), 8);
  data29.travel_span := left_shift_word(distance, 2) + 1;
  data29.start_radius := data29.pos72.fields.w0high;
  data29.start_heading := data29.pos72.fields.w0low;
  data29.travel_progress := 0;
  data29.pos72.fields.planet := 0;
  add_clock_minutes(data29.clock80, 1 + right_shift_word(data29.travel_span, 1));
  write_wrapped_text('ETA:   ');
  draw_clock(data29.clock80);
  text_newline;
  update_flight_state
end;
