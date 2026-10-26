{ game_8 procedure 2, $0000..$006D, attributes $0078. }
procedure draw_condition_bar(bar_index: integer);
var
  bar_edge, bar_pattern: integer;
begin
  with condition_bars[bar_index] do
  begin
    bar_edge := data29.bytes[118 + bar_index];
    if bar_edge < 64 then bar_pattern := 6
    else if bar_edge < 128 then bar_pattern := 9
    else if bar_edge < 192 then bar_pattern := 5
    else bar_pattern := 10;
    bar_edge := lower_first + (bar_edge + 7) div 8;
    set_clip_bounds(lower_first, bar_edge, lower_second, upper_second);
    draw_clip_pattern(bar_pattern);
    if bar_edge < upper_first then
    begin
      set_clip_bounds(bar_edge + 1, upper_first, lower_second, upper_second);
      if bar_pattern < 9 then draw_clip_pattern(4)
      else draw_clip_pattern(8)
    end
  end
end;
