{ library_25 procedure8, $02BC..$038D, attributes $039C.
  itemcode's address is passed but unused. Outputs may alias: store input0,
  then input1, and reread both. Flash cleanup uses the low bit of the count. }
procedure activate_menu_item(index: integer; var itemcode: integer; area: bounds4;
                   var input0, input1: integer);
var
  firstbase, secondbase, flashes, counter, work: integer;
begin
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  with data30.items[index] do
    if tag.button then
    begin
      input0 := 1;
      input1 := 0;
      set_clip_bounds(firstbase + bounds.lower_first,
                firstbase + bounds.upper_first,
                secondbase + bounds.lower_second,
                secondbase + bounds.upper_second);
      draw_clip_pattern(3)
    end
    else
    begin
      apply_bounds(area, 0);
      set_glyph_mode(1);
      flashes := 0;
      repeat
        data29.words[354] := data29.words[354] + 1;
        move_pen(firstbase + words[3], secondbase + words[2]);
        draw_glyph(words[1]);
        flashes := flashes + 1;
        counter := 0;
        while counter <= 70 do
        begin
          work := counter + counter - counter;
          counter := counter + 1
        end;
        input0 := poll_input(0);
        input1 := poll_input(1)
      until odd(input0) or odd(input1)
            or (data29.words[354] >= data29.words[353])
            or odd(data29.words[347]);
      if odd(input0) then play_sound(30, 50, 10, 0, 0, 0, 0);
      if odd(flashes) then
      begin
        move_pen(firstbase + words[3], secondbase + words[2]);
        draw_glyph(words[1])
      end
    end
end;
