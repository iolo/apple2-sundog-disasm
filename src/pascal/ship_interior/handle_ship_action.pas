{ game_15 procedure16, $08E6..$0963, attributes $096E.
  Self EXIT occurs before state writes when the action is unchanged.
  Four unused local bytes are omitted. Game14 receives a VAR action. }
procedure handle_ship_action;
begin
  g15.selected_action := ship_action_at(g15.marker_x, g15.marker_y);
  if g15.selected_action = g15.previous_action then exit(handle_ship_action);
  g15.previous_action := g15.selected_action;
  data29.nibbles45[1] := 2;
  data29.nibbles45[0] := 11;
  if g15.selected_action > 0 then
  begin
    leave_ship_interior;
    if g15.selected_action = 1 then
    begin
      data29.nibbles45[2] := 0;
      paint_ship_dashboard
    end
    else if g15.selected_action = 3 then launch_ground_transport
    else if g15.selected_action = 4 then enter_ship_landing
    else if not odd(data29.words[347]) and (g15.selected_action > 0) then
    begin
      run_component_panel(g15.selected_action, 0, 0);
      if not odd(data29.words[347]) then setup_ship_interior
    end
  end
end;
