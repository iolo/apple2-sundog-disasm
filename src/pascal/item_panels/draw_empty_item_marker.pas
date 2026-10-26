{ library_27 procedure12, $03E8..$041C, attributes $0426. }
procedure draw_empty_item_marker(index: integer);
begin
  if (data31.words[14] < index) and (index <= data31.words[15]) then
    with data31.items[index] do
    begin
      set_glyph_mode(1);
      move_pen(data31.words[12] + firstoff,
                 (data31.words[11] + secondoff) + 6);
      draw_glyph(43)
    end
end;
