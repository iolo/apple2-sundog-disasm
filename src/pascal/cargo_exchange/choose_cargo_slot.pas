{ game_20 procedure12, $06DE..$0811, attributes $0820.
  Build labels once, then repeat selection for empty entries. The empty flag
  is only assigned for positive choices; zero exits without needing its value. }
procedure choose_cargo_slot(var chosen: integer; pods: boolean; column, row: integer);
var
  index, found, selected: integer;
  empty: boolean;
begin
  set_clip_bounds(data29.words[14], data29.words[13], row - 8, data29.words[11]);
  draw_clip_pattern(8);
  apply_bounds(data29.bounds11, 0);
  data29.text_x := column;
  data29.text_y := row;
  if pods then
  begin
    write_wrapped_text('Pod contents:\');
    g20.button_y := g20.menu_bottom - 39
  end
  else g20.button_y := g20.menu_bottom - 51;
  reset_menu;
  index := 1;
  if pods then
    while index <= 2 do
    begin
      with data29.stock234[index] do
        add_menu_button(index, g20.cargo_names.names^[kind], g20.menu_left + 4,
                  g20.menu_right - 4, g20.button_y, g20.button_y + 9);
      g20.button_y := g20.button_y + 14;
      index := index + 1
    end
  else
    while index <= 4 do
    begin
      with g20.warehouse_items[index] do
        add_menu_button(index, g20.cargo_names.names^[kind], g20.menu_left + 4,
                  g20.menu_right - 4, g20.button_y, g20.button_y + 9);
      g20.button_y := g20.button_y + 14;
      index := index + 1
    end;
  repeat
    chosen := 0;
    poll_exchange_menu(chosen, found, data29.words[297], data29.bounds11, selected);
    if chosen > 0 then
    begin
      if pods then empty := data29.stock234[chosen].kind = 0
      else empty := g20.warehouse_items[chosen].kind = 0;
      if empty then play_sound(10, 40, 50, 0, 0, 0, 0)
    end
  until (chosen = 0) or not empty or odd(data29.words[347])
end;
