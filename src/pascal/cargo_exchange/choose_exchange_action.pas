{ game_20 procedure30, $16F4..$17FD, attributes $1808; nested in28.
  Snapshot selected before the unconditional input1 call. Flash input passes
  the same selected address twice, as at $17D4/$17D6. }
procedure choose_exchange_action(viewmode: integer; var picked: integer);
var
  origin_x, origin_y, pointer_x, pointer_y, found, selected: integer;
  area: bounds4;
  choice_made: boolean;
  cancel_poll: integer;
begin
  assign_bounds(area, data29.words[14], data29.words[13],
              data29.words[12] + 20, data29.words[11] - 20);
  reset_menu;
  if odd(g20.contract_mode) then
    if odd(g20.pods_available) then
      add_exchange_buttons(10, 2, 2, 'Delivery', 'Warehouse', '')
    else add_exchange_buttons(10, 0, 1, 'Exit center', '', '')
  else if viewmode = 0 then
    add_exchange_buttons(10, 4, 2, 'Exchange', 'Warehouse', '')
  else add_exchange_buttons(10, 1, 2, 'Buy', 'Sell', '');
  draw_menu(area);
  initialize_pointer(pointer_x, pointer_y, data29.words[297], area);
  origin_x := area.lower_first;
  origin_y := area.lower_second;
  found := 0;
  selected := 0;
  picked := 0;
  repeat
    scroll_market_ticker;
    update_pointer(pointer_x, pointer_y);
    if odd(poll_input(0)) then
    begin
      find_menu_item(pointer_x - origin_x, pointer_y - origin_y, picked, found);
      if found > 0 then
      begin
        activate_menu_item(found, picked, area, selected, selected);
        play_sound(10, 50, 30, 0, 0, 0, 0);
        selected := 1
      end
    end;
    choice_made := odd(selected);
    cancel_poll := poll_input(1)
  until choice_made or odd(cancel_poll) or odd(data29.words[347]);
  toggle_pointer_glyph(pointer_x, pointer_y)
end;
