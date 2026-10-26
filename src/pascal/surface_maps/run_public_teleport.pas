{ game_21 procedure38, $1A24..$1B8D, attributes $1B9A.
  Keep22-byte local layout for nested39's bounds and the original deposit
  flag at slot2. That flag is written only when input0 is true; the original
  has no initialization or reset on a false input0. Do not invent one.
  Cancelled destination selection restores both original money words. }
procedure run_public_teleport;
var
  cancel: integer;       {1}
  deposit_selected: integer;      {2: deliberately not initialized, as in the listing}
  destination_selected: integer;     {3}
  cost: integer;         {4}
  active_button: bounds4;       {5..8}
  original_cash: wordpair;        {9..10}
  unused_system_address: integer;      {11: calculated but unused}
(*$include src/pascal/surface_maps/draw_teleport_button.pas*)
begin
  g21.teleport_ready := 0;
  toggle_surface_player;
  toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
  push_text_window(word_or(window_x, 1), window_y);
  unused_system_address := data29.words[23] + 20 * (data29.loc37.low4 - 1);
  cost := 10 + 4 * g21.fare_factor - 2 * g21.fare_discount_factor;
  if cost < 10 then cost := 10;
  original_cash := data29.money46;
  clear_text_window;
  draw_teleport_button('Public TelePort', true);
  text_newline;
  text_newline;
  write_wrapped_text('|||||Cost:  ');
  write_integer(cost, 3, false);
  write_wrapped_text(' Cr\|\');
  write_wrapped_text('|||Deposit money and\||select destination.\|\');
  draw_teleport_button('Deposit money', false);
  destination_selected := 0;
  initialize_pointer(g21.cursor_x, g21.cursor_y, data29.words[297], data29.bounds11);
  repeat
    update_pointer(g21.cursor_x, g21.cursor_y);
    if odd(poll_input(0)) then
      deposit_selected := ord((active_button.lower_first <= g21.cursor_x) and
                     (g21.cursor_x <= active_button.upper_first) and
                     (active_button.lower_second <= g21.cursor_y) and
                     (g21.cursor_y <= active_button.upper_second));
    cancel := poll_input(1)
  until odd(deposit_selected) or odd(cancel);
  toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
  if odd(deposit_selected) then
  begin
    play_sound(30, 50, 10, 0, 0, 0, 0);
    apply_bounds(active_button, 3);
    if charge_teleport_fare(cost) then choose_teleport_destination(destination_selected)
  end;
  pop_text_window;
  if odd(destination_selected) then perform_teleport
  else data29.money46 := original_cash;
  initialize_pointer(g21.cursor_x, g21.cursor_y, data29.words[298], g21.pointer_bounds);
  toggle_surface_player
end;
