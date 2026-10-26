{ utility_disk1:4 $1E3E..$1EE3, attributes$1EF0. Result slots1/2,
  locals3 tone,4 middle,5 selected pointer. No prompt for an empty slot.
  Preserve the second state read after menu calls and both mode3 inversions. }
function confirm_slot_delete: boolean;
var
  tone: integer;
  menu_midpoint: integer;
  save_record: utilptr;
begin
  confirm_slot_delete := true;
  save_record := @u1.slots[u1.picked_slot];
  if save_record^.words[8] > 0 then
  begin
    set_clip_bounds(data29.words[14], data29.words[13],
              data29.words[11] - 30, data29.words[11]);
    draw_clip_pattern(8);
    apply_bounds(data29.bounds11, 0);
    set_text_grid_position(7, 16);
    write_wrapped_text('Delete?');
    menu_midpoint := (u1.menu_left + u1.menu_right) div 2;
    reset_menu;
    add_menu_button(1, 'Yes', u1.menu_left, menu_midpoint - 2,
              u1.menu_bottom - 10, u1.menu_bottom);
    add_menu_button(2, 'No', menu_midpoint + 2, u1.menu_right,
              u1.menu_bottom - 10, u1.menu_bottom);
    if save_record^.words[8] = 3 then
    begin
      apply_bounds(data29.bounds11, 3);
      tone := 14
    end
    else tone := 7;
    play_sound(10, 100, 40, 252, 1, tone, 0);
    if tone = 14 then apply_bounds(data29.bounds11, 3);
    select_title_menu(u1.menu_action, 0);
    confirm_slot_delete := u1.menu_action = 1
  end
end;
