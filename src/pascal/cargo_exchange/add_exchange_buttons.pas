{ game_20 procedure9, $05BC..$0636, attributes $0640.
  Count1 reduces width by2 before the first button's additional subtraction. }
procedure add_exchange_buttons(button_y, first_action, button_count: integer;
                   caption1, caption2, caption3: text15);
var
  button_width: integer;
begin
  button_width := g20.menu_right div button_count;
  if button_count = 1 then button_width := button_width - 2;
  add_menu_button(first_action, caption1, g20.menu_left, g20.menu_left + button_width - 2,
            button_y, button_y + 10);
  if button_count > 1 then
    add_menu_button(first_action + 1, caption2, g20.menu_left + button_width + 2,
              g20.menu_left + button_width + button_width - 2, button_y, button_y + 10);
  if button_count > 2 then
    add_menu_button(first_action + 2, caption3, g20.menu_left + button_width + button_width + 2,
              g20.menu_right, button_y, button_y + 10)
end;
