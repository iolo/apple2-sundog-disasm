{ game_19 procedure3, $0040..$00C5, attributes $00D0.
  Output stores and rereads are ordered to preserve aliasing. Input1 is polled
  only when input0 was false, as in the original branch structure. }
procedure poll_service_menu(var code, found: integer; mode: integer; area: bounds4;
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
