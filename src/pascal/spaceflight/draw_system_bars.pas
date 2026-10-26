{ game_13 procedure7, $016E..$01F3, attributes $0200; nested in3.
  Seven bars use raw row bytes at word90+28*index+24. Keep both gaps after
  indices2/5, including the independent upper/lower fill operations. }
procedure draw_system_bars;
var
  x: integer;
  bottom: integer;
  edge: integer;
  top: integer;
  system_group: integer;
  last_group: integer;
begin
  bottom := g13s.bars_y;
  top := bottom - 8;
  x := g13s.bars_x;
  system_group := 0;
  last_group := 6;
  while system_group <= last_group do
  begin
    edge := bottom - right_shift_word(data29.bytes[178 + (28 * system_group + 24)], 1);
    if edge > top then
    begin
      set_clip_bounds(x, x + 6, top, edge - 1);
      draw_clip_pattern(8)
    end;
    set_clip_bounds(x, x + 6, edge, bottom);
    if edge = bottom then draw_clip_pattern(8)
    else if edge = top then draw_clip_pattern(5)
    else draw_clip_pattern(9);
    x := x + 7;
    if (system_group = 2) or (system_group = 5) then x := x + 7;
    system_group := system_group + 1
  end;
  apply_bounds(data29.bounds11, 0)
end;
