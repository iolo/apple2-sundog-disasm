{ utility_disk1:31 $1718..$171F, attributes$172A. One VAR Boolean,
  340 local bytes. Always finalize/copy the name, even after cancellation. }
procedure enter_character_name(var name_accepted: boolean);
var name_entry_state: utilname;
(*$include src/pascal/save_game_utility/draw_keyboard_row.pas*)
(*$include src/pascal/save_game_utility/setup_name_keyboard.pas*)
(*$include src/pascal/save_game_utility/backspace_name.pas*)
(*$include src/pascal/save_game_utility/toggle_name_shift.pas*)
(*$include src/pascal/save_game_utility/append_name_character.pas*)
(*$include src/pascal/save_game_utility/confirm_character_name.pas*)
(*$include src/pascal/save_game_utility/poll_name_keyboard.pas*)
(*$include src/pascal/save_game_utility/finish_name_entry.pas*)
begin
  setup_name_keyboard;
  poll_name_keyboard(name_accepted);
  finish_name_entry
end;
