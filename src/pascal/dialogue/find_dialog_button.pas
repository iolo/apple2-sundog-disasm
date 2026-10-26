{ game_16 procedure35, $11B4..$1213, attributes $1220.
  Probe each of the first three rectangles before the signed enable check.
  The VAR flag is stored before sound/drawing and reread on the loop backedge;
  parent35 and the VAR selection are updated after those calls. }
procedure find_dialog_button(pointer_x, pointer_y: integer; var selected_action, button_found: integer);
var
  button_index: integer;
(*$include src/pascal/dialogue/inside_dialog_button.pas*)
begin
  button_index := 0;
  button_found := 0;
  while (button_index < 3) and not odd(button_found) do
  begin
    if inside_dialog_button(pointer_x, pointer_y, button_index) and (g16.words[90 + button_index] >= 0) then
    begin
      button_found := 1;
      play_sound(30, 50, 10, 0, 0, 0, 0);
      if not (odd(g16.amount_controls) and (button_index < 2)) then
        apply_bounds(g16.dialog_buttons[button_index], 3);
      g16.selected_caption := g16.words[90 + button_index];
      selected_action := g16.words[95 + button_index]
    end
    else button_index := button_index + 1
  end
end;
