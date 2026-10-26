{ game_15 procedure1, $0970..$0A29, attributes $0A3A.
  Load8/14/27 before setup. Preserve every input poll and the low-bit NEQ6
  transition test. Normal return writes nibble1 then releases27/14/8;
  the original exit attribute points at $0A13 and skips that nibble write.
  Nonlocal EXIT requires a binding to this release epilogue. }
procedure run_ship_interior;
var
(*$include src/pascal/ship_interior/locals.pas*)
(*$include src/pascal/ship_interior/draw_framed_bounds.pas*)
(*$include src/pascal/ship_interior/write_vertical_label.pas*)
(*$include src/pascal/ship_interior/toggle_ship_marker.pas*)
(*$include src/pascal/ship_interior/enter_ship_landing.pas*)
(*$include src/pascal/ship_interior/launch_ground_transport.pas*)
(*$include src/pascal/ship_interior/query_glyph_collision.pas*)
(*$include src/pascal/ship_interior/walk_ship_interior.pas*)
(*$include src/pascal/ship_interior/ship_action_at.pas*)
(*$include src/pascal/ship_interior/leave_ship_interior.pas*)
(*$include src/pascal/ship_interior/paint_ship_dashboard.pas*)
(*$include src/pascal/ship_interior/load_ship_interior.pas*)
(*$include src/pascal/ship_interior/advance_planet_phases.pas*)
(*$include src/pascal/ship_interior/use_cargo_fuel.pas*)
(*$include src/pascal/ship_interior/setup_ship_interior.pas*)
(*$include src/pascal/ship_interior/handle_ship_action.pas*)
begin
  rtldseg(8);
  rtldseg(14);
  rtldseg(27);
  g15.overlay_flag_index := 30;
  g15.ship_signature := 'SHIP';
  setup_ship_interior;
  while (data29.nibbles45[2] = 2) or (data29.nibbles45[2] = 10) do
  begin
    if odd(poll_input(4)) then walk_ship_interior;
    update_pointer(g15.cursor_x, g15.cursor_y);
    if odd(poll_input(1)) or (data29.nibbles45[2] = 10) then
    begin
      leave_ship_interior;
      run_personal_panel(0, 0);
      if data29.nibbles45[2] < 11 then setup_ship_interior
    end;
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then update_flight_state;
    if odd(poll_input(4)) then walk_ship_interior;
    if odd(poll_input(4)) <> odd(g15.walk_button_state) then
    begin
      g15.walk_button_state := poll_input(4);
      if not odd(g15.walk_button_state) then handle_ship_action
      else g15.previous_action := 0
    end
  end;
  data29.nibbles45[1] := 2;
  rtrlseg(27);
  rtrlseg(14);
  rtrlseg(8)
end;
