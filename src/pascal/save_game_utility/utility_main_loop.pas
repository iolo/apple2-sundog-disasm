{ utility_disk1:1 entry$20C2, body$20C4..$2124, release$2126..$2138,
  load$213A..$214C, RBP$214E, attributes$215C. Program-block include after
  declarations/dependencies, ending in end. Declare u1:utilframe as the first
  program variable: original slots3..524 are1044 local bytes after four ABI
  parameter bytes. DATA29/30/31 are external segments, not additional locals.
  Preserve duplicate segment30 loads/releases. Nonlocal EXIT must enter$2126;
  runtime error dispatch must bind utility procedure2 to util1_2. The external
  rtldseg/rtrlseg declarations alone do not provide these runtime bindings. }
(*$include src/pascal/save_game_utility/utility_error_prompt.pas*)
(*$include src/pascal/save_game_utility/utility_disk_matches.pas*)
(*$include src/pascal/save_game_utility/require_utility_side.pas*)
(*$include src/pascal/save_game_utility/confirm_slot_delete.pas*)
(*$include src/pascal/save_game_utility/wait_utility_input.pas*)
(*$include src/pascal/save_game_utility/save_catalog_and_reboot.pas*)
(*$include src/pascal/save_game_utility/erase_save_slot.pas*)
(*$include src/pascal/save_game_utility/write_save_status.pas*)
(*$include src/pascal/save_game_utility/add_slot_action.pas*)
(*$include src/pascal/save_game_utility/pick_save_slot.pas*)
(*$include src/pascal/save_game_utility/draw_save_slot.pas*)
(*$include src/pascal/save_game_utility/paint_utility_catalog.pas*)
(*$include src/pascal/save_game_utility/load_save_catalog.pas*)
(*$include src/pascal/save_game_utility/boot_saved_game.pas*)
(*$include src/pascal/save_game_utility/build_slot_actions.pas*)
(*$include src/pascal/save_game_utility/show_slot_certificate.pas*)
(*$include src/pascal/save_game_utility/enter_character_name.pas*)
(*$include src/pascal/save_game_utility/create_game_state.pas*)
(*$include src/pascal/save_game_utility/edit_start_attributes.pas*)
(*$include src/pascal/save_game_utility/start_new_game.pas*)
(*$include src/pascal/save_game_utility/handle_slot_action.pas*)
begin
  rtldseg(30);
  rtldseg(29);
  rtldseg(22);
  rtldseg(30);
  rtldseg(25);
  rtldseg(26);
  graphics_library_entry;
  menu_library_entry;
  title_library_entry;
  mark(data29.text35.text);
  mark(data29.addr34.bytes);
  data29.words[33] := 16384;
  release(data29.addr33.bytes);
  disk_blocks_io(16384, 1, 80, true);
  setup_graphics(data29.addr33.bytes^[6] - 3);
  load_save_catalog;
  initialize_pointer(u1.cursor_x, u1.cursor_y, 1, data29.bounds7);
  repeat
    update_pointer(u1.cursor_x, u1.cursor_y);
    if odd(poll_input(0)) then handle_slot_action
  until odd(poll_input(1) or u1.exit_word);
  toggle_pointer_glyph(u1.cursor_x, u1.cursor_y);
  save_catalog_and_reboot;
  rtrlseg(26);
  rtrlseg(25);
  rtrlseg(30);
  rtrlseg(22);
  rtrlseg(29);
  rtrlseg(30)
end.
