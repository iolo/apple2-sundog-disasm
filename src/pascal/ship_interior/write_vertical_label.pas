{ game_15 procedure3, $002A..$0074, attributes $007E.
  Original: copy bounds first (slots44..47), then caption with SAS80
  (slots3..43). The reference compiler relocates these private copies to
  slots3..6 and7..47, retaining copy order and90 local bytes. No raw slot
  observer or nested child depends on those private offsets.
  Exactly four bytes are drawn, without a caption-length test. }
procedure write_vertical_label(bounds: bounds4; caption: text80);
begin
  move_pen(bounds.lower_first, bounds.upper_second + 9);
  draw_glyph(ord(caption[1]));
  move_pen(bounds.lower_first, bounds.upper_second + 17);
  draw_glyph(ord(caption[2]));
  move_pen(bounds.lower_first, bounds.upper_second + 25);
  draw_glyph(ord(caption[3]));
  move_pen(bounds.lower_first, bounds.upper_second + 33);
  draw_glyph(ord(caption[4]))
end;
