{ utility_disk1:50 $205A..$20B5, attributes$20C0. No parameters/locals.
  Choice4's certificate closes/redraws its own window; other choices including
  unmatched values close and redraw the selected slot here. Restore cursor. }
procedure handle_slot_action;
begin
  toggle_pointer_glyph(u1.cursor_x, u1.cursor_y);
  pick_save_slot(u1.cursor_x, u1.cursor_y, u1.picked_slot);
  push_text_window(u1.cursor_x div 7, u1.cursor_y div 8);
  build_slot_actions;
  select_title_menu(u1.menu_action, 0);
  case u1.menu_action of
    1: start_new_game;
    2: boot_saved_game;
    3: erase_save_slot;
    4: show_slot_certificate(u1.cursor_x div 7, u1.cursor_y div 8)
  end;
  if u1.menu_action <> 4 then
  begin
    pop_text_window;
    draw_save_slot(u1.picked_slot, true)
  end;
  initialize_pointer(u1.cursor_x, u1.cursor_y, 1, data29.bounds7)
end;
