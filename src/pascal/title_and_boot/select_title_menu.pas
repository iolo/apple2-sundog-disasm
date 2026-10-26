{ Both library26 variants: procedure5, $0210..$02BA, attributes $02C6.
  Initial lasty is unspecified. Timeout resets only on cursor movement.
  Keep random and input1 calls unconditional; unused slot12 saves input1
  to prevent Pascal short-circuit evaluation from omitting the poll. }
procedure select_title_menu(var choice: integer; timeout_step: integer);
var
  last_y: integer; {3}
  last_x: integer; {4}
  selected_item: integer; {5}
  random_scratch: integer; {6}
  origin_y: integer; {7}
  origin_x: integer; {8}
  y: integer; {9}
  x: integer; {10}
  idle_countdown: integer; {11}
  cancel_poll: integer; {12}
  input1: integer; {13}
  input0: integer; {14}
begin
  origin_x := data29.words[14];
  origin_y := data29.words[12];
  draw_menu(data29.bounds11);
  initialize_pointer(x, y, 1, data29.bounds11);
  input0 := 0;
  input1 := 0;
  selected_item := 0;
  choice := 0;
  last_x := -1;
  repeat
    update_pointer(x, y);
    if (x <> last_x) or (y <> last_y) then
    begin
      last_x := x;
      last_y := y;
      idle_countdown := 2150
    end;
    random_scratch := random_word;
    if odd(poll_input(0)) then
    begin
      find_menu_item(x - origin_x, y - origin_y, choice, selected_item);
      if selected_item > 0 then
      begin
        play_sound(30, 50, 10, 0, 0, 0, 0);
        activate_menu_item(selected_item, choice, data29.bounds11, input0, input1)
      end
    end
    else idle_countdown := idle_countdown - timeout_step;
    cancel_poll := poll_input(1)
  until odd(input0) or odd(cancel_poll) or (idle_countdown <= 0);
  if idle_countdown <= 0 then
  begin
    activate_menu_item(3, choice, data29.bounds11, input0, input1);
    choice := 3
  end;
  toggle_pointer_glyph(x, y)
end;
