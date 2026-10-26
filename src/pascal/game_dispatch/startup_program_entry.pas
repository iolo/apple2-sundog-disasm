{ startup_disk1 procedure1 (identical startup_disk2), entry$01E8,
  body$01EA..$01FF, load$0212..$0221, release$0201..$020E, RBP$0223,
  attributes$0230. This is a program-block include after the program header,
  shared declarations and recovered dependencies, not an ordinary procedure.
  Original four parameter bytes belong to the program ABI; zero local bytes.
  Preserve repeated loads/releases. Nonlocal EXIT must enter$0201. }
(*$include src/pascal/game_dispatch/halt_on_io_error.pas*)
(*$include src/pascal/game_dispatch/run_ship_mode_loop.pas*)
(*$include src/pascal/game_dispatch/run_ground_mode_loop.pas*)
(*$include src/pascal/game_dispatch/run_game_modes.pas*)
begin
  rtldseg(30);
  rtldseg(31);
  rtldseg(29);
  rtldseg(30);
  rtldseg(31);
  graphics_library_entry;
  tile_library_entry;
  effects_library_entry;
  menu_library_entry;
  title_library_entry;
  item_panel_library_entry;
  amount_library_entry;
  run_game_modes;
  rtrlseg(31);
  rtrlseg(30);
  rtrlseg(29);
  rtrlseg(31);
  rtrlseg(30)
end.
