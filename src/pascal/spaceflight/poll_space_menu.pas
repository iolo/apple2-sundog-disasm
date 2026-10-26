{ game_13 procedure45, $20B0..$216B, attributes $2178; nested in1.
  Parameters: VAR code5, VAR found4, glyph3, value bounds pointer2, VAR input0 at1.
  Bounds copy6..9 precedes calls. Locals10..16 retain the original roles.
  Keep the discarded initial input1 poll and the later conditional poll.
  All stop flags use bit0; a full-word nonzero test would change behavior. }
procedure poll_space_menu(var code, found: integer; glyph: integer;
                    area: bounds4; var input0: integer);
var
  origin_y: integer; {10}
  origin_x: integer;  {11}
  pointer_y: integer;  {12}
  pointer_x: integer;   {13}
  picked_code: integer;   {14}
  input1: integer;     {15}
  poll_done: integer;       {16}
begin
  origin_x := area.lower_first;
  origin_y := area.lower_second;
  draw_menu(area);
  initialize_pointer(pointer_x, pointer_y, glyph, area);
  poll_done := poll_input(1);
  poll_done := 0;
  input0 := 0;
  input1 := 0;
  found := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then update_flight_state;
    update_pointer(pointer_x, pointer_y);
    if odd(poll_input(0)) then
    begin
      picked_code := code;
      find_menu_item(pointer_x - origin_x, pointer_y - origin_y, picked_code, found);
      if found > 0 then
      begin
        play_sound(30, 50, 10, 0, 0, 0, 0);
        activate_menu_item(found, picked_code, area, input0, input1);
        code := picked_code;
        poll_done := 1
      end
      else found := 0
    end
    else if odd(data29.words[350]) then
    begin
      data29.words[350] := 0;
      code := 255;
      input0 := 1;
      poll_done := 1
    end
    else poll_done := poll_input(1)
  until odd(poll_done) or odd(data29.words[347]);
  toggle_pointer_glyph(pointer_x, pointer_y)
end;
