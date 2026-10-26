{ library_27 procedure 9, $0250..$026A, attributes $0274. }
procedure write_item_caption(caption: text15);
begin
  apply_bounds(data31.bounds6, 8);
  move_pen(data31.words[9], data31.words[6]);
  draw_text(caption)
end;
