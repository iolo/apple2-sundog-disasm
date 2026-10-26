{ utility_disk1:30 $101E..$115B, attributes$1166. Five local words:
  1 choice,2 bottom,3 row,4 right,5 left. Confirmation is choice=1 only;
  retain the points warning at >=8 and always close the window afterward. }
procedure confirm_attributes;
var
  choice: integer;
  bottom: integer;
  row: integer;
  right: integer;
  left: integer;
begin
  push_text_window(20, 12);
  write_wrapped_text('Strength:    ');
  write_integer(data29.bytes[94], 3, false);
  text_newline;
  write_wrapped_text('Intelligence:');
  write_integer(data29.bytes[95], 3, false);
  text_newline;
  write_wrapped_text('Dexterity:   ');
  write_integer(data29.bytes[96], 3, false);
  text_newline;
  write_wrapped_text('Charisma:    ');
  write_integer(data29.bytes[97], 3, false);
  text_newline;
  write_wrapped_text('Luck:        ');
  write_integer(data29.bytes[98], 3, false);
  text_newline;
  write_wrapped_text('Points left: ');
  write_integer(stat_editor.unspent_points, 3, false);
  text_newline;
  if stat_editor.unspent_points >= 8 then write_wrapped_text('||Don''t waste! `');
  left := 4;
  right := data29.words[13] - data29.words[14] - 4;
  bottom := data29.words[11] - data29.words[12] - 3;
  row := bottom - 25;
  reset_menu;
  add_menu_button(1, 'All done', left, right, row, row + 10);
  row := row + 15;
  add_menu_button(2, 'Adjust', left, right, row, row + 10);
  select_title_menu(choice, 0);
  stat_editor.confirmed := ord(choice = 1);
  pop_text_window
end;
