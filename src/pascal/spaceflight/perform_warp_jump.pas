{ game_13 procedure35, $1760..$19F5, attributes $1A04; nested in27.
  Original locals1/5/6/7 are unused;1 supplies dynamic byte index4 and5 holds
  the random result. Keep the18-byte frame and parent27's six-byte frame.
  packet[spill] intentionally writes one byte past the parent's declared
  locals. Range checks must remain disabled; runtime binding must preserve
  the original caller/frame context. Do not silently allocate a larger packet.
  LNOT is a word complement: byte0 must be255/254, not canonical Boolean1/0. }
procedure perform_warp_jump;
var
  spill: integer;    {1}
  arrival_radius: integer;   {2}
  arrival_heading: integer;  {3}
  success_chance: integer;   {4}
  random_value: integer;  {5}
  unused6: integer;
  unused7: integer;
  heading_spread: integer;   {8}
  warp_success: boolean;   {9}
begin
  load_travel_overlay(118, 3, 4, 1, 0);
  clear_text_window;
  write_wrapped_text('Engaging warp engines');
  set_window_image_origin(data29.words[344], data29.words[346] div 7);
  if data29.pos72.fields.planet > 0 then success_chance := 0
  else success_chance := left_shift_word(data29.pos72.fields.w0high + 7, 1);
  random_value := random_word;
  warp_success := success_chance > random_value mod 100;
  packet[0] := 255 - ord(data29.flags82[122]);
  packet[1] := 20 + right_shift_word(data29.warp_setting, 1);
  packet[2] := 17 * data29.loc73.low4;
  packet[3] := 13 * data29.warp_destination_system;
  if warp_success then
  begin
    arrival_radius := data29.pos72.fields.w0high;
    if arrival_radius < 43 then
    begin
      arrival_heading := 32 + right_shift_word(data29.pos72.fields.w0low + 8, 4);
      heading_spread := right_shift_word(43 - arrival_radius, 2) + 1;
      arrival_heading := left_shift_word(word_and(random_between(arrival_heading - heading_spread,
                                             arrival_heading + heading_spread), 15), 4)
    end
    else arrival_heading := left_shift_word(right_shift_word(data29.pos72.fields.w0low + 8, 4), 4);
    spill := 4;
    packet[spill] := 0;
    fillchar(data29.pos72, 12, data29.words[293]);
    data29.pos72.fields.system := data29.warp_destination_system;
    data29.pos72.fields.w0low := arrival_heading;
    data29.pos72.fields.w0high := 43;
    write_wrapped_text('\Switching to viewscreen\');
    apply_bounds(data29.bnd343, 8);
    call_warp_animation(packet, 6144);
    data29.words[354] := data29.words[353] + 1;
    data29.flags82[1] := false;
    data29.flags82[40] := false;
    data29.flags82[25] := false;
    data29.flags82[47] := false;
    update_flight_state;
    apply_bounds(data29.bnd303, 5);
    clear_text_window;
    write_wrapped_text('Warp successfully completed\');
    seed_system_stars
  end
  else
  begin
    heading_spread := 3 * (20 + data29.pos72.fields.w0high);
    spill := 4;
    packet[spill] := 1;
    write_wrapped_text('\Switching to viewscreen\');
    apply_bounds(data29.bnd343, 8);
    call_warp_animation(packet, 6144);
    heading_spread := 63;
    play_sound(heading_spread, 255 - 3 * heading_spread, 1 + heading_spread, 3, 255, 0, 0);
    set_text_window(data29.words[342], data29.words[341],
              data29.words[340], data29.words[339]);
    clear_text_window;
    write_wrapped_text('Instability due to gravity field')
  end;
  data29.flags82[5] := false;
  data29.map_view_kind := 2;
  data29.warp_destination_system := 0;
  data29.warp_charge := 0;
  data29.warp_setting := 0;
  apply_bounds(data29.bnd307, 8);
  move_pen(data29.words[310] + 2, data29.words[307]);
  draw_integer(14 + 2 * data29.pos72.fields.w0high, 3, true);
  apply_bounds(data29.warp_gauge_bounds, 8);
  data29.flags82[0] := false
end;
