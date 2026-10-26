{ game_19 procedure2, $0000..$0035, attributes $003E.
  The same parent29 address is deliberately passed for both input outputs. }
procedure open_service_title(caption: text15);
begin
  reset_menu;
  add_menu_button(1, caption, g19.menu_left, g19.menu_right,
            g19.menu_bottom - 87, g19.menu_bottom - 78);
  draw_menu(data29.bounds11);
  activate_menu_item(1, g19.title_code, data29.bounds11, g19.menu_confirmed, g19.menu_confirmed)
end;
