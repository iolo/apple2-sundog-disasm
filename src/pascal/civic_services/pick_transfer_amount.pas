{ game_19 procedure7, $01F8..$036E, attributes $037A.
  Both amounts are VAR. The initial available copy occurs after menu setup;
  the accumulated amount is committed even when the menu is cancelled. }
procedure pick_transfer_amount(var available, destination: wordpair);
var
  amount_action, menu_hit, choice_confirmed: integer;
  increment_amount, remaining_funds, transfer_total: wordpair;
begin
  reset_menu;
  add_service_button_row(g19.menu_bottom - 25, 1, 3, 'ALL', '100', '1000');
  add_service_button_row(g19.menu_bottom - 10, 4, 3, '10000', '50000', 'CLEAR');
  make_amount(transfer_total, 0, 0);
  remaining_funds := available;
  set_clip_bounds(data29.words[14], data29.words[13],
            data29.words[12] + g19.menu_bottom - 50, data29.words[11]);
  draw_clip_pattern(8);
  apply_bounds(data29.bounds11, 0);
  repeat
    data29.text_x := data29.words[14] + g19.menu_left;
    data29.text_y := data29.words[12] + g19.menu_bottom - 48;
    text_newline;
    write_captioned_amount('AMOUNT:    ', transfer_total);
    write_captioned_amount('AVAILABLE: ', remaining_funds);
    poll_service_menu(amount_action, menu_hit, data29.words[297], data29.bounds11, choice_confirmed);
    make_amount(increment_amount, 0, 0);
    if odd(choice_confirmed) and (0 < amount_action) and (amount_action < 7) then
    begin
      case amount_action of
        1: increment_amount := remaining_funds;
        2: increment_amount.second := 100;
        3: increment_amount.first := 1;
        4: increment_amount.first := 10;
        5: increment_amount.first := 50;
        6:
          begin
            make_amount(transfer_total, 0, 0);
            remaining_funds := available;
            make_amount(increment_amount, 0, 0)
          end
      end;
      if not amount_greater(increment_amount, remaining_funds) then
      begin
        subtract_amount(increment_amount, remaining_funds);
        add_amount(increment_amount, transfer_total)
      end
      else play_sound(10, 40, 50, 0, 0, 0, 0)
    end
  until not odd(choice_confirmed) or (amount_action = 7) or odd(data29.words[347]);
  add_amount(transfer_total, destination);
  available := remaining_funds;
  set_clip_bounds(data29.words[14], data29.words[13],
            data29.words[12] + g19.menu_bottom - 50, data29.words[11]);
  draw_clip_pattern(8);
  apply_bounds(data29.bounds11, 0);
  choice_confirmed := 1
end;
