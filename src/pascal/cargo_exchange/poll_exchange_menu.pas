{ game_20 procedure8, $0514..$05AE, attributes $05BA.
  Increment the shared timer before cursor/input polling. Preserve ordered
  output stores, aliased VAR outputs, and conditional input1 polling. }
procedure poll_exchange_menu(var code, found: integer; mode: integer; area: bounds4;
                   var selected: integer);
var
  origin_x, origin_y, pointer_x, pointer_y, picked_code, input1: integer;
  poll_done: boolean;
begin
  origin_x := area.lower_first;
  origin_y := area.lower_second;
  draw_menu(area);
  initialize_pointer(pointer_x, pointer_y, mode, area);
  poll_done := false;
  selected := 0;
  input1 := 0;
  found := 0;
  code := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= 10 then advance_clock_and_conditions;
    update_pointer(pointer_x, pointer_y);
    if odd(poll_input(0)) then
    begin
      picked_code := code;
      find_menu_item(pointer_x - origin_x, pointer_y - origin_y, picked_code, found);
      if found > 0 then
      begin
        play_sound(30, 50, 10, 0, 0, 0, 0);
        activate_menu_item(found, picked_code, area, selected, input1);
        code := picked_code;
        poll_done := true
      end
    end
    else if odd(poll_input(1)) then poll_done := true
  until poll_done or odd(data29.words[347]);
  toggle_pointer_glyph(pointer_x, pointer_y)
end;
