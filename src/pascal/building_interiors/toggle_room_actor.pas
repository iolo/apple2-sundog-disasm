{ Game 18:4, $0040..$005C, attributes $0066. One index argument. }
procedure toggle_room_actor(index: integer);
begin
  with room_actors[index] do               { $0040..$0046: capture address. }
  begin
    set_glyph_mode(1);                       { $0048..$0049 }
    move_pen(words[5], words[4]);       { $004C..$0050 }
    draw_glyph(split6.high)               { $0053..$0059: word 6 bits 8..15. }
  end
end;
