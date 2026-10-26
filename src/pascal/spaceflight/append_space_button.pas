{ game_13 procedure42, $1FFC..$201D, attributes $2028; nested in1.
  raw13 denotes the entry's eight local words. Copy the value caption before
  reading the parent's bounds, then advance parent slot6 after the menu call. }
procedure append_space_button(code: integer; caption: text15);
begin
  add_menu_button(code, caption, space_ui[8], space_ui[7], space_ui[6], space_ui[6] + 10);
  space_ui[6] := space_ui[6] + 15
end;
