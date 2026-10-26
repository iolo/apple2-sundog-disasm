{ game_16 procedure1, $1BB8..$1C9F, attributes $1CB2.
  Load27/28 before setup; normal return cleans up then releases28/27. The
  original exit attribute targets $1C8F, skipping47 on nonlocal EXIT; binding
  must preserve that release epilogue. Unused slots25/142 hold both initial
  input results so neither call is short-circuited; the278-byte frame remains. }
procedure run_dialogue_session(window_x, window_y, dialog_kind: integer);
var
(*$include src/pascal/dialogue/locals.pas*)
(*$include src/pascal/dialogue/price_trade_item.pas*)
(*$include src/pascal/dialogue/set_trade_price.pas*)
(*$include src/pascal/dialogue/draw_dialog_amount.pas*)
(*$include src/pascal/dialogue/show_trade_item.pas*)
(*$include src/pascal/dialogue/place_trade_icon.pas*)
(*$include src/pascal/dialogue/list_trade_items.pas*)
(*$include src/pascal/dialogue/phrase_offset.pas*)
(*$include src/pascal/dialogue/read_dialog_byte.pas*)
(*$include src/pascal/dialogue/tick_dialog_clock.pas*)
(*$include src/pascal/dialogue/index_phrase_pages.pas*)
(*$include src/pascal/dialogue/merge_dialog_phrases.pas*)
(*$include src/pascal/dialogue/find_dialog_button.pas*)
(*$include src/pascal/dialogue/store_inventory_code.pas*)
(*$include src/pascal/dialogue/wait_dialog_input.pas*)
(*$include src/pascal/dialogue/show_dialog_clock.pas*)
(*$include src/pascal/dialogue/show_cash_on_hand.pas*)
(*$include src/pascal/dialogue/finish_dialog_session.pas*)
(*$include src/pascal/dialogue/item_trade_eligible.pas*)
(*$include src/pascal/dialogue/test_dialog_condition.pas*)
(*$include src/pascal/dialogue/choose_trade_item.pas*)
(*$include src/pascal/dialogue/extract_phrase_variant.pas*)
(*$include src/pascal/dialogue/choose_foreign_place.pas*)
(*$include src/pascal/dialogue/render_dialog_line.pas*)
(*$include src/pascal/dialogue/execute_dialog_record.pas*)
(*$include src/pascal/dialogue/act_dialog_command.pas*)
(*$include src/pascal/dialogue/dispatch_dialog_action.pas*)
(*$include src/pascal/dialogue/setup_dialog_session.pas*)
(*$include src/pascal/dialogue/drag_dialog_item.pas*)
begin
  rtldseg(27);
  rtldseg(28);
  setup_dialog_session;
  repeat
    g16.release0_poll := poll_input(0);
    g16.release1_poll := poll_input(1)
  until not (odd(g16.release0_poll) or odd(g16.release1_poll));
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      tick_dialog_clock;
      g16.dialog_timeout := g16.dialog_timeout - 1;
      if g16.dialog_timeout <= 0 then dispatch_dialog_action(g16.timeout_action, 1)
    end;
    update_pointer(g16.cursor_x, g16.cursor_y);
    if odd(poll_input(0)) then
    begin
      g16.button_hit := 0;
      if odd(g16.buttons_enabled) then
      begin
        find_dialog_button(g16.cursor_x, g16.cursor_y, g16.last_action, g16.button_hit);
        if odd(g16.button_hit) then dispatch_dialog_action(g16.last_action, 1)
      end;
      if not (odd(g16.exit_requested) or odd(g16.button_hit)) then
      begin
        find_panel_item(g16.cursor_x, g16.cursor_y, g16.hit_code, g16.hit_item);
        if g16.hit_code = 4 then show_dialog_clock
        else if g16.hit_code = 5 then show_cash_on_hand
        else if g16.hit_code > 6 then
        begin
          if odd(g16.trade_active) and
             ((g16.hit_item > data31.words[10]) or odd(g16.selling_mode)) then
          begin
            show_item_description(g16.hit_code);
            g16.trade_item_code := g16.hit_code;
            dispatch_dialog_action(g16.words[95 + ord(item_trade_eligible)], 1)
          end
          else
          begin
            show_trade_item(g16.hit_code, g16.hit_item);
            drag_dialog_item(g16.hit_item, 0)
          end
        end
      end
    end
    else if odd(poll_input(1)) then dispatch_dialog_action(g16.secondary_action, 1)
  until odd(g16.exit_requested) or odd(data29.words[347]);
  finish_dialog_session;
  rtrlseg(28);
  rtrlseg(27)
end;
