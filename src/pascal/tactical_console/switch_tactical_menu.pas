{ game_12 procedure20, $10F6..$1107, attributes $1112; nested in1.
  Value caption copy occupies slots3..10 before any calls. }
procedure switch_tactical_menu(mode: integer; caption: text15);
begin
  swap_tactical_buffers;
  g12.menu_mode := mode;
  open_tactical_menu(caption);
  swap_tactical_buffers
end;
