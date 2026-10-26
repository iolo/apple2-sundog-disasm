{ utility_disk1:48 $1FE4..$2022, attributes$202C. Four local bytes:
  unused word1, keepgoing2. Both confirmation and name-entry acceptance must
  succeed before initialization9 and attribute editing22. }
procedure start_new_game;
var
  unused: integer;
  name_accepted: boolean;
begin
  if confirm_slot_delete then
  begin
    clear_text_window;
    enter_character_name(name_accepted);
    if name_accepted then
    begin
      write_wrapped_text('Initializing new game -- please wait');
      create_game_state;
      edit_start_attributes
    end
  end
end;
