{ game_13 procedure43, $202A..$2075, attributes $2080; nested in1.
  Value caption is copied on entry. Both library25:8 outputs alias parent
  slot4; preserve that alias and its ordered stores. Read bounds after the call. }
procedure open_space_menu(caption: text15);
begin
  reset_menu;
  add_menu_button(1, caption, 4, 62, 3, 13);
  apply_bounds(data29.bnd335, 8);
  draw_menu(data29.bnd335);
  activate_menu_item(1, space_ui[3], data29.bnd335, space_ui[4], space_ui[4]);
  assign_bounds(data29.bnd335, data29.words[338], data29.words[337],
            data29.words[336] + 15, data29.words[335])
end;
