{ game_13 procedure51, $246A..$2505, attributes $2510; nested in1.
  Missing entries still consume15 units of vertical space. Original unused
  local1 holds the city predicate so call50 always runs after that read. }
procedure build_space_menu;
var
  outside_city: boolean;
begin
  space_ui[8] := 4;
  space_ui[7] := 62;
  space_ui[6] := 4;
  reset_menu;
  if not group_below_limit(5, 3) then append_space_button(1, 'STATUS')
  else space_ui[6] := space_ui[6] + 15;
  if not group_below_limit(5, 1) then append_space_button(2, 'NAVIGATE')
  else space_ui[6] := space_ui[6] + 15;
  outside_city := data29.pos72.fields.city = 0;
  if not group_below_limit(3, 0) and outside_city then append_space_button(3, 'TACTICAL')
  else space_ui[6] := space_ui[6] + 15;
  if not data29.flags82[25] and (data29.pos72.fields.city = 0) then
    append_space_button(4, 'DISTRESS')
end;
