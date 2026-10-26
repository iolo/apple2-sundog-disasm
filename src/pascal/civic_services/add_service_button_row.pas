{ game_19 procedure4, $00D2..$0141, attributes $014A.
  Preserve the original divisor and third-button upper endpoint. }
procedure add_service_button_row(button_y, first_action, button_count: integer;
                   caption1, caption2, caption3: text15);
var
  button_width: integer;
begin
  button_width := g19.menu_right div button_count;
  add_menu_button(first_action, caption1, g19.menu_left, g19.menu_left + button_width - 2,
            button_y, button_y + 10);
  if button_count > 1 then
    add_menu_button(first_action + 1, caption2, g19.menu_left + button_width + 2,
              g19.menu_left + button_width + button_width - 2, button_y, button_y + 10);
  if button_count > 2 then
    add_menu_button(first_action + 2, caption3, g19.menu_left + button_width + button_width + 2,
              g19.menu_right, button_y, button_y + 10)
end;
