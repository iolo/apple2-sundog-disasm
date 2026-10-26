{ game_13 procedure19, $0E82..$0FEC, attributes $0FFE; nested in18.
  Parameters7..1: VAR pickcode/hit, glyph, value bounds, VAR selected/chosen, viewtype.
  Bounds copy8..11 precedes cursor setup. Keep the discarded input1 poll,
  cursor toggles around periodic updates, input0 store visible to proc24_9,
  timeout path, and post-hit selection test even when hit<=0. }
procedure poll_map_marker(var picked_code, hit_index: integer; glyph: integer; area: bounds4;
                    var confirmed: integer; var chosen_place: g19loc; detail_kind: integer);
var
  confirm_ticks: integer; {12}
  unused13: integer;
  ybase: integer;     {14}
  xbase: integer;     {15}
  ycursor: integer;   {16}
  xcursor: integer;   {17}
  hover_code: integer;   {18}
  cancel_input: integer;    {19}
  poll_done: integer;      {20}
(*$include src/pascal/spaceflight/show_system_details.pas*)
(*$include src/pascal/spaceflight/show_orbital_details.pas*)
(*$include src/pascal/spaceflight/show_city_details.pas*)
begin
  initialize_pointer(xcursor, ycursor, glyph, area);
  xbase := area.lower_first;
  ybase := area.lower_second;
  poll_done := poll_input(1);
  poll_done := 0;
  confirmed := 0;
  hit_index := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      toggle_pointer_glyph(xcursor, ycursor);
      update_flight_state;
      toggle_pointer_glyph(xcursor, ycursor)
    end;
    update_pointer(xcursor, ycursor);
    if odd(poll_input(0)) then
    begin
      hover_code := picked_code;
      find_menu_item(xcursor - xbase, ycursor - ybase, hover_code, hit_index);
      if hit_index > 0 then
      begin
        play_sound(30, 50, 10, 0, 0, 0, 0);
        toggle_pointer_glyph(xcursor, ycursor);
        apply_bounds(data29.bnd339, 8);
        set_text_window(data29.words[342], data29.words[341],
                    data29.words[340], data29.words[339]);
        case detail_kind of
          1: show_system_details(hover_code);
          2: show_orbital_details(hover_code);
          3: show_city_details(hover_code, confirmed)
        end;
        confirmed := poll_input(0);
        update_flight_state;
        confirmed := 1;
        if not odd(can_confirm) then confirmed := 0;
        confirm_ticks := 5;
        cancel_input := 0;
        if odd(confirmed) then
          repeat
            data29.words[354] := data29.words[354] + 1;
            if data29.words[354] >= data29.words[353] then
            begin
              confirm_ticks := confirm_ticks - 1;
              update_flight_state
            end;
            activate_menu_item(hit_index, hover_code, area, confirmed, cancel_input)
          until odd(confirmed) or odd(cancel_input) or (confirm_ticks = 0);
        if (not odd(cancel_input)) and (confirm_ticks = 0) then
        begin
          confirmed := 1;
          if not data29.flags82[31] then play_sound(30, 50, 10, 0, 0, 0, 0)
        end;
        initialize_pointer(xcursor, ycursor, glyph, area)
      end;
      if odd(confirmed) then
      begin
        picked_code := hover_code;
        poll_done := 1
      end
      else hit_index := 0
    end
    else if odd(poll_input(1)) then poll_done := 1
  until odd(poll_done) or odd(data29.words[347]);
  toggle_pointer_glyph(xcursor, ycursor)
end;
