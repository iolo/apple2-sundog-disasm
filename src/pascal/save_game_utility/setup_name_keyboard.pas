{ utility_disk1:33 $1258..$1345, attributes$1350, nested in31.
  Locals1 unused,2 x,3 y. Preserve full bounds save and setup order. }
procedure setup_name_keyboard;
var
  unused: integer;
  x: integer;
  y: integer;
begin
  name_entry_state.previous_text_bounds := data29.bounds11;
  clear_text_window;
  write_wrapped_text('Spell character name\|using cursor\Button 1 deletes\');
  write_wrapped_text('Press + when done');
  y := data29.words[11];
  x := data29.words[14] + 2;
  draw_keyboard_row(0, x, y - 24, 'abcdefghij');
  draw_keyboard_row(1, x, y - 12, 'klmnopqrst');
  draw_keyboard_row(2, x, y - 0, 'uvwxyz ` +');
  name_entry_state.entered_name := '';
  name_entry_state.typed_length := 0;
  name_entry_state.uppercase_next := 0;
  assign_bounds(name_entry_state.name_pointer_bounds, data29.words[14] + 4, data29.words[14] + 133,
              data29.words[11] - 36, data29.words[11] - 4);
  set_text_window(data29.words[14], data29.words[13],
              data29.words[11] - 52, data29.words[11] - 40);
  name_entry_state.unused160 := 1
end;
