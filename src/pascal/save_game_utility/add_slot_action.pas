{ utility_disk1:45 $1E1C..$1E32, attributes$1E3C. Slot1 number,2 caption
  address,3..10 local value-copy caption. Word8 reread after menu call. }
procedure add_slot_action(caption: text15; action_code: integer);
begin
  add_menu_button(action_code, caption, u1.menu_left, u1.menu_right,
            u1.button_y, u1.button_y + 10);
  u1.button_y := u1.button_y - 15
end;
