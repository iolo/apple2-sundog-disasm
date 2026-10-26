{ game_19 procedure17, $0C10..$0DC2, attributes $0DCE.
  Hold the entry system-row address through every menu call and final store.
  SYSTEM_CORE23 ($05F2) refuses an over-capacity append: a name longer than9
  yields just ' Bank', rather than its first9 characters plus that suffix. }
procedure run_uniteller;
var
  systems: g19addr;
  heading: string[14];
begin
  systems.word := data29.words[23];
  with systems.rows^[data29.loc37.low4] do
  begin
    g19.working_funds := bank_balance;
    heading := '';
    if length(caption) <= 9 then heading := caption;
    heading := concat(heading, ' Bank');
    open_service_title(heading);
    set_text_grid_position(0, 4);
    write_wrapped_text('|     UNITELLER');
    text_newline;
    repeat
      apply_bounds(data29.bounds11, 0);
      set_text_grid_position(0, 6);
      write_captioned_amount('On hand:   ', data29.money46);
      set_text_grid_position(0, 8);
      if amount_greater(g19.zero_funds, g19.working_funds) then
        write_captioned_amount('Deficit:   ', g19.working_funds)
      else write_captioned_amount('In bank:   ', g19.working_funds);
      set_clip_bounds(data29.words[14], data29.words[13],
                data29.words[12] + 40, data29.words[11]);
      draw_clip_pattern(8);
      reset_menu;
      g19.button_y := g19.menu_bottom - 10;
      if amount_greater(data29.money46, g19.zero_funds) then
      begin
        add_menu_button(1, 'DEPOSIT CASH', g19.menu_left, g19.menu_right,
                  g19.button_y, g19.button_y + 10);
        g19.button_y := g19.button_y - 15
      end;
      if amount_greater(g19.working_funds, g19.zero_funds) then
      begin
        add_menu_button(2, 'WITHDRAW CASH', g19.menu_left, g19.menu_right,
                  g19.button_y, g19.button_y + 10);
        g19.button_y := g19.button_y - 15;
        add_menu_button(3, 'TRANSFER', g19.menu_left, g19.menu_right,
                  g19.button_y, g19.button_y + 10)
      end;
      g19.menu_action := 0;
      g19.menu_confirmed := 0;
      poll_service_menu(g19.menu_action, g19.menu_hit, data29.words[297],
                data29.bounds11, g19.menu_confirmed);
      case g19.menu_action of
        1: pick_transfer_amount(data29.money46, g19.working_funds);
        2: pick_transfer_amount(g19.working_funds, data29.money46);
        3: send_bank_transfer(g19.working_funds)
      end
    until not odd(g19.menu_confirmed) or odd(data29.words[347]);
    bank_balance := g19.working_funds
  end
end;
