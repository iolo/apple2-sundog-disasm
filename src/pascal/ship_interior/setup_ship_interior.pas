{ game_15 procedure11, $04FE..$06DD, attributes $06EC.
  The two early paths skip loading and table updates and join at $066E.
  Do not initialize action1 or flag10 on those paths: the listing does not.
  Original local3 is unused; only row1 and column2 are retained. }
procedure setup_ship_interior;
var
  row: integer;
  column: integer;
begin
  g15.saved_overlay_flag := ord(data29.flags82[g15.overlay_flag_index]);
  if (data29.nibbles45[1] = 8) and (8 <= g15.selected_action) and (g15.selected_action <= 13)
  then
  begin
    g15.marker_x := 7 * 16 - 3;
    if g15.selected_action <= 10 then g15.marker_y := 8 * 7 + 7
    else g15.marker_y := 8 * 17 + 7;
    data29.words[40] := g15.marker_x;
    data29.bytes[80] := g15.marker_y;
    g15.previous_action := g15.selected_action
  end
  else if (data29.nibbles45[1] = 8) or (data29.nibbles45[1] = 7) then
  begin
    g15.marker_x := data29.words[40];
    g15.marker_y := data29.bytes[80];
    g15.previous_action := g15.selected_action
  end
  else
  begin
    g15.overlay_text.word := 6144;
    g15.overlay_text.text^ := g15.ship_signature;
    g15.raw_entry_address := 3904;
    load_ship_interior;
    g15.signature_changed := ord(g15.overlay_text.text^ <> g15.ship_signature);
    disk_blocks_io(g15.raw_entry_address, 1, data29.words[30] + 2, true);
    advance_planet_phases;
    column := 6 + 3;
    row := 12;
    g15.previous_action := 0;
    case data29.nibbles45[1] of
      0: begin
        column := 6;
        row := 12;
        g15.previous_action := 1
      end;
      3,4: if not data29.flags45[13] then
           begin
             column := 14;
             row := 14;
             g15.previous_action := 3;
             use_cargo_fuel;
             data29.pos228 := data29.pos72
           end
           else
           begin
             g15.marker_x := 7 * 8 - 2;
             g15.marker_y := 8 * 14 + 6;
             column := 0;
             row := 0;
             g15.previous_action := 4
           end;
      11: begin
        g15.marker_x := data29.words[40];
        g15.marker_y := data29.bytes[80];
        g15.previous_action := 0;
        column := 0;
        row := 0
      end
    end;
    if column + row > 0 then
    begin
      g15.marker_x := column * 7;
      g15.marker_y := row * 8 + 7
    end;
    data29.words[40] := g15.marker_x;
    data29.bytes[80] := g15.marker_y
  end;
  { $066E: common tail, including both early paths. }
  if odd(data29.words[347]) then
  begin
    if data29.bytes[118] = 0 then data29.nibbles45[2] := 12
    else data29.nibbles45[2] := 10
  end;
  data29.words[351] := 1;
  data29.words[353] := 15;
  data29.flags45[13] := true;
  g15.marker_glyph := 12;
  g15.background_glyph := 13;
  apply_bounds(data29.bounds7, 0);
  toggle_ship_marker;
  data29.words[2] := 8;
  g15.walk_button_state := 0;
  assign_bounds(g15.walk_bounds, data29.words[10], data29.words[9] - 7,
            data29.words[8], data29.words[7] - 8);
  initialize_pointer(g15.cursor_x, g15.cursor_y, data29.words[298], g15.walk_bounds)
end;
