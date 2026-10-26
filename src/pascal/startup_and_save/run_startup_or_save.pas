{ startup_7 procedure1, entry$0706, body$0708..$071A, load$0724..$072A,
  release epilogue$071C..$0720, return$072C, attributes$0738.
  One Boolean parameter and36 local bytes. Nonlocal EXIT must use the original
  release epilogue; runtime EXTERNAL declarations alone do not implement it. }
procedure run_startup_or_save(initialize: boolean);
var s7: s7frame;
(*$include src/pascal/startup_and_save/check_disk_side.pas*)
(*$include src/pascal/startup_and_save/request_disk_side.pas*)
(*$include src/pascal/startup_and_save/reset_game_runtime.pas*)
(*$include src/pascal/startup_and_save/setup_play_graphics.pas*)
(*$include src/pascal/startup_and_save/load_game_tables.pas*)
(*$include src/pascal/startup_and_save/restore_play_state.pas*)
(*$include src/pascal/startup_and_save/save_or_restart_game.pas*)
begin
  rtldseg(25);
  rtldseg(26);
  release(data29.addr33.bytes);
  if initialize then
  begin
    reset_game_runtime;
    setup_play_graphics;
    load_game_tables;
    restore_play_state
  end
  else save_or_restart_game;
  rtrlseg(26);
  rtrlseg(25)
end;
