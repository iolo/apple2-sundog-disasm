{ utility_disk1:22 $1168..$11C6, attributes$11D4. No parameters,70 local
  bytes. Poll0 and poll1 on every inner iteration, even with a saved selection.
  Child29 may set parent34, so test it again before opening confirmation30. }
procedure edit_start_attributes;
var stat_editor: u22frame;
(*$include src/pascal/save_game_utility/draw_attribute_bar.pas*)
(*$include src/pascal/save_game_utility/draw_unspent_points.pas*)
(*$include src/pascal/save_game_utility/setup_attribute_editor.pas*)
(*$include src/pascal/save_game_utility/commit_new_game.pas*)
(*$include src/pascal/save_game_utility/attribute_point_cost.pas*)
(*$include src/pascal/save_game_utility/pick_attribute_row.pas*)
(*$include src/pascal/save_game_utility/adjust_attribute.pas*)
(*$include src/pascal/save_game_utility/confirm_attributes.pas*)
begin
  setup_attribute_editor;
  stat_editor.selected_stat := -1;
  repeat
    initialize_pointer(stat_editor.cursor_x, stat_editor.cursor_y, 2, data29.bounds11);
    repeat
      update_pointer(stat_editor.cursor_x, stat_editor.cursor_y);
      stat_editor.edit_poll := poll_input(0) or ord(stat_editor.selected_stat <> -1);
      stat_editor.done_poll := poll_input(1)
    until odd(stat_editor.done_poll or stat_editor.edit_poll);
    toggle_pointer_glyph(stat_editor.cursor_x, stat_editor.cursor_y);
    if odd(stat_editor.edit_poll) then
    begin
      if stat_editor.selected_stat = -1 then
        pick_attribute_row(stat_editor.cursor_x, stat_editor.cursor_y, stat_editor.selected_stat);
      if stat_editor.selected_stat >= 0 then adjust_attribute(stat_editor.selected_stat)
    end;
    if odd(stat_editor.done_poll) then confirm_attributes
  until odd(stat_editor.confirmed);
  commit_new_game
end;
