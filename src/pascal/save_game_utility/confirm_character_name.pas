{ utility_disk1:37 $142E..$160C, attributes$161E, nested in31.
  Locals1..4 saved cursor,5..8 saved display,9 index,10 width,11 height,
  12 choice,13 y,14 duplicate,15 limit. Trim length byte without updating
  parent length171, as in the original. Compare all four names regardless
  of slot state. Restore both bounds before cursor calls on global5/4. }
procedure confirm_character_name;
var
  savedcur: bounds4;
  savedscr: bounds4;
  index: integer;
  width: integer;
  height: integer;
  choice: integer;
  y: integer;
  duplicate: boolean;
  limit: integer;
begin
  savedscr := data29.bounds11;
  savedcur := name_entry_state.name_pointer_bounds;
  push_text_window(20, 12);
  while (name_entry_state.namebytes[1] = 32) and (name_entry_state.namebytes[0] > 0) do
    delete(name_entry_state.entered_name, 1, 1);
  index := name_entry_state.namebytes[0];
  while (index > 0) and (name_entry_state.namebytes[index] = 32) do index := index - 1;
  name_entry_state.namebytes[0] := index;
  text_newline;
  write_wrapped_text('Your character name is:  ');
  write_wrapped_text(name_entry_state.entered_name);
  text_newline;
  text_newline;
  duplicate := false;
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    if (name_entry_state.entered_name = u1.slots[index].caption) and (index <> u1.picked_slot) then
      duplicate := true;
    index := index + 1
  end;
  if name_entry_state.namebytes[0] = 0 then
  begin
    write_wrapped_text('You must choose a name.  Please do so.');
    name_entry_state.name_confirmed := false;
    wait_utility_input(3000)
  end
  else if duplicate then
  begin
    write_wrapped_text('This name is already in use.  Please choose another.');
    name_entry_state.name_confirmed := false;
    wait_utility_input(3000)
  end
  else
  begin
    write_wrapped_text('Is this correct?');
    reset_menu;
    height := data29.words[11] - data29.words[12] - 3;
    width := data29.words[13] - data29.words[14] - 4;
    y := height - 25;
    add_menu_button(1, 'Yes', 4, width, y, y + 10);
    y := y + 15;
    add_menu_button(2, 'No', 4, width, y, y + 10);
    select_title_menu(choice, 0);
    name_entry_state.name_confirmed := choice = 1
  end;
  pop_text_window;
  data29.bounds11 := savedscr;
  name_entry_state.name_pointer_bounds := savedcur;
  initialize_pointer(u1.cursor_x, u1.cursor_y, 1, name_entry_state.name_pointer_bounds);
  toggle_pointer_glyph(u1.cursor_x, u1.cursor_y);
  if not name_entry_state.name_confirmed then
  begin
    clear_text_window;
    write_wrapped_text('Name: ');
    write_wrapped_text(name_entry_state.entered_name)
  end
end;
