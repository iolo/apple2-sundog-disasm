{ game_20 procedure10, $0642..$066A, attributes $0674.
  Both flash input outputs intentionally use the same local address. }
procedure flash_exchange_title(caption: text15; left_x, right_x, button_y: integer);
var
  selected, code: integer;
begin
  reset_menu;
  add_menu_button(1, caption, left_x, right_x, button_y, button_y + 10);
  draw_menu(data29.bounds11);
  activate_menu_item(1, code, data29.bounds11, selected, selected)
end;
