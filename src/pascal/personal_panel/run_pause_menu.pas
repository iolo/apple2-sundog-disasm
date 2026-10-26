{ game_8 procedure16, $07C4..$0934, attributes $0942.
  save is a one-word VAR flag, represented as integer to alias parent slot19.
  Its writes are 0/1; tests retain the interpreter's low-bit convention. }
procedure run_pause_menu(var save_requested: integer);
var
  saved_bounds: bounds4;
  pointer_y: integer;
  pointer_x: integer;
  save_enabled: boolean;
  sound_toggled: boolean;
  cancel_poll: integer;
  save_hit: boolean;
begin
  saved_bounds := data29.bounds11;
  set_text_window(stats_bounds.lower_first, stats_bounds.upper_first,
            stats_bounds.lower_second, stats_bounds.upper_second);
  clear_text_window;
  write_wrapped_text('The game is frozen.');
  save_enabled := not data29.flags45[13] or (data29.nibbles45[1] <> 5);
  if save_enabled then draw_personal_button(save_button_bounds, 'Save game');
  initialize_pointer(pointer_x, pointer_y, data29.words[297], data29.bounds11);
  save_requested := 0;
  cancel_poll := 0;
  repeat
    toggle_pointer_glyph(pointer_x, pointer_y);
    if data29.flags82[122] then draw_personal_button(sleep_button_bounds, 'Sound is off')
    else draw_personal_button(sleep_button_bounds, 'Sound is on');
    toggle_pointer_glyph(pointer_x, pointer_y);
    sound_toggled := false;
    repeat
      update_pointer(pointer_x, pointer_y);
      if odd(poll_input(0)) then begin
        save_hit := point_in_item_area(pointer_x, pointer_y, save_button_bounds);
        save_requested := ord(save_hit and save_enabled);
        sound_toggled := point_in_item_area(pointer_x, pointer_y, sleep_button_bounds)
      end else cancel_poll := poll_input(1)
    until odd(save_requested) or odd(cancel_poll) or sound_toggled;
    if odd(save_requested) then apply_bounds(save_button_bounds, 3)
    else if sound_toggled then begin
      apply_bounds(sleep_button_bounds, 3);
      data29.flags82[122] := not data29.flags82[122]
    end
  until odd(save_requested) or odd(cancel_poll);
  toggle_pointer_glyph(pointer_x, pointer_y);
  if odd(save_requested) then begin
    data29.nibbles45[2] := 11;
    if data29.nibbles45[1] = 5 then begin
      if data29.nibbles45[0] = 11 then begin
        if data29.bits37.mid6 = 0 then data29.nibbles45[0] := 4
        else data29.nibbles45[0] := 3
      end;
      data29.nibbles45[1] := data29.nibbles45[0]
    end;
    pop_text_window;
    exit(run_personal_panel)
  end;
  clear_text_window;
  paint_condition_panel;
  set_text_window(saved_bounds.lower_first, saved_bounds.upper_first,
            saved_bounds.lower_second, saved_bounds.upper_second)
end;
