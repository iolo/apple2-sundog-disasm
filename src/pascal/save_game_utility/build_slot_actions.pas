{ utility_disk1:47 $1F44..$1FD7, attributes$1FE2. One local pointer captured
  before display; each status condition rereads through it after menu calls. }
procedure build_slot_actions;
var selected: utilptr;
begin
  selected := @u1.slots[u1.picked_slot];
  draw_save_slot(u1.picked_slot, false);
  u1.menu_left := 4;
  u1.menu_right := data29.words[13] - data29.words[14] - 4;
  u1.menu_bottom := data29.words[11] - data29.words[12] - 3;
  reset_menu;
  u1.button_y := u1.menu_bottom - 10;
  if selected^.words[8] = 0 then add_slot_action('Start new game', 1);
  if (selected^.words[8] > 0) and (selected^.words[8] < 4) then
    add_slot_action('Play game', 2);
  if selected^.words[8] > 0 then add_slot_action('Delete game', 3);
  if selected^.words[8] = 5 then add_slot_action('Certificate', 4)
end;
