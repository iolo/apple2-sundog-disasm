{ game_8 procedure1, $0B54..$0C05, attributes $0C12.
  Complete enclosing scope and entry body. Child3/16 may EXIT this procedure,
  intentionally bypassing the normal final call to18. Arguments occupy2/1. }
procedure run_personal_panel(window_x, window_y: integer);
var
(*$include src/pascal/personal_panel/locals.pas*)
(*$include src/pascal/personal_panel/draw_condition_bar.pas*)
(*$include src/pascal/personal_panel/point_in_item_area.pas*)
(*$include src/pascal/personal_panel/draw_personal_button.pas*)
(*$include src/pascal/personal_panel/paint_condition_panel.pas*)
(*$include src/pascal/personal_panel/setup_personal_panel.pas*)
(*$include src/pascal/personal_panel/lift_inventory_item.pas*)
(*$include src/pascal/personal_panel/close_personal_panel.pas*)
(*$include src/pascal/personal_panel/tick_personal_panel.pas*)
(*$include src/pascal/personal_panel/drag_inventory_item.pas*)
(*$include src/pascal/personal_panel/wait_personal_input.pas*)
(*$include src/pascal/personal_panel/paint_clock_caption.pas*)
(*$include src/pascal/personal_panel/paint_cash_caption.pas*)
(*$include src/pascal/personal_panel/show_player_attributes.pas*)
(*$include src/pascal/personal_panel/paint_location_page.pas*)
(*$include src/pascal/personal_panel/run_pause_menu.pas*)
(*$include src/pascal/personal_panel/sleep_and_risk_theft.pas*)
begin
  setup_personal_panel;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then tick_personal_panel(false, true);
    update_pointer(personal_state[13], personal_state[12]);
    if odd(poll_input(0)) then begin
      toggle_pointer_glyph(personal_state[13], personal_state[12]);
      find_panel_item(personal_state[13], personal_state[12], personal_state[11], personal_state[10]);
      if personal_state[10] = data31.words[13] then show_player_attributes
      else if personal_state[11] = 1 then run_pause_menu(personal_state[19])
      else if personal_state[11] = 4 then paint_clock_caption
      else if personal_state[11] = 5 then paint_cash_caption
      else if personal_state[11] = 6 then paint_location_page
      else if personal_state[11] > 6 then begin
        show_item_description(personal_state[11]);
        drag_inventory_item(personal_state[10])
      end else if point_in_item_area(personal_state[13], personal_state[12], sleep_button_bounds) then sleep_and_risk_theft;
      initialize_pointer(personal_state[13], personal_state[12], 2, data31.bounds2)
    end;
    if data29.nibbles45[2] = 10 then begin
      toggle_pointer_glyph(personal_state[13], personal_state[12]);
      sleep_and_risk_theft;
      toggle_pointer_glyph(personal_state[13], personal_state[12])
    end
  until odd(poll_input(1)) or odd(personal_state[19]);
  close_personal_panel
end;
