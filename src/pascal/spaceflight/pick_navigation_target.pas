{ game_13 procedure49, $2314..$231F, attributes $232A; nested in47.
  Pass parent location9..14 and result6 by reference; modes are1/0. }
procedure pick_navigation_target(view_kind: integer);
begin
  select_map_location(view_kind, nav_destination, target_selected, 1, 0)
end;
