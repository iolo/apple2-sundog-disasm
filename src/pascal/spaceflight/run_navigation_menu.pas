{ game_13 procedure47, $232C..$2442, attributes $244E; nested in1.
  Retain all28 local bytes. Child48 uses otherwise unused slots2..4 for a
  mandatory table read. Input7 controls repetition independently of result6.
  The action9 redraw can clear result6 via procedure12's early return; preserve
  that effect before deciding whether to call travel27. }
procedure run_navigation_menu;
var
  unused_zero: integer; {1}
  city_access: boolean; {2}
  planet_row: g13rowptr; {3}
  city_count: integer; {4}
  menu_hit: integer;  {5}
  target_selected: integer;   {6}
  menu_input: integer; {7}
  nav_action: integer;  {8}
  nav_destination: g19loc;   {9..14}
(*$include src/pascal/spaceflight/build_navigation_menu.pas*)
(*$include src/pascal/spaceflight/pick_navigation_target.pas*)
begin
  unused_zero := 0;
  open_space_menu('NAVIGATE');
  if data29.flags82[1] then
  begin
    nav_destination := data29.pos66;
    select_map_location(2, nav_destination, target_selected, 1, 1)
  end;
  data29.words[349] := 1;
  repeat
    build_navigation_menu;
    nav_action := 0;
    apply_bounds(data29.bnd335, 8);
    poll_space_menu(nav_action, menu_hit, data29.words[297], data29.bnd335, menu_input);
    if odd(data29.words[347]) then nav_action := 0;
    target_selected := menu_input;
    nav_destination := data29.pos36;
    case nav_action of
      1: browse_world_maps;
      2, 3, 4:
        begin
          data29.flags82[32] := nav_action = 2;
          data29.flags82[39] := (nav_action = 2) or
                               ((nav_action = 4) and (not data29.flags82[21]));
          pick_navigation_target(3);
          nav_action := 4
        end;
      6: pick_navigation_target(2);
      8: pick_navigation_target(1);
      9: if data29.map_view_kind = 1 then
         begin
           data29.flags82[0] := false;
           select_map_location(1, nav_destination, target_selected, 1, 1)
         end
    end;
    if nav_action < 4 then target_selected := 0;
    if odd(target_selected) and (not odd(data29.words[347])) and (nav_action <> 255) then
      execute_flight_plan(nav_action, nav_destination)
  until (not odd(menu_input)) or odd(data29.words[347]);
  if not data29.flags82[5] then
    select_map_location(data29.map_view_kind, data29.pos72, menu_input, 1, 1);
  close_space_menu;
  data29.words[349] := 0
end;
