{ utility_disk1:38 $1620..$16E3, attributes$16F4, nested in31.
  VAR active slot1; locals2 column,3 row,4 y,5 x,6 unused,7 key pointer.
  Wait for input1 release initially; input1 deletion has priority over input0.
  Wait for input0 release after a key action before undoing its highlight. }
procedure poll_name_keyboard(var entry_active: boolean);
var
  column: integer;
  row: integer;
  y: integer;
  x: integer;
  unused: integer;
  key: utilkptr;
begin
  entry_active := true;
  clear_text_window;
  write_wrapped_text('Name: ');
  initialize_pointer(x, y, 1, name_entry_state.name_pointer_bounds);
  name_entry_state.name_confirmed := false;
  toggle_name_shift;
  repeat until not odd(poll_input(1));
  repeat
    update_pointer(x, y);
    if odd(poll_input(1)) then backspace_name(entry_active)
    else if odd(poll_input(0)) then
    begin
      toggle_pointer_glyph(x, y);
      column := (x - name_entry_state.words[155]) div 13;
      row := (y - name_entry_state.words[153]) div 12;
      play_sound(5, 50, 10, 0, 0, 0, 0);
      key := @name_entry_state.keys[row, column];
      apply_bounds(key^.bounds, 3);
      if key^.code.low = 96 then toggle_name_shift
      else if key^.code.low = 43 then confirm_character_name
      else append_name_character(key^.code.low);
      repeat until not odd(poll_input(0));
      apply_bounds(key^.bounds, 3);
      toggle_pointer_glyph(x, y)
    end
  until name_entry_state.name_confirmed or (not entry_active);
  toggle_pointer_glyph(x, y)
end;
