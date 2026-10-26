{ utility_disk1:23 $0AA2..$0AE9, attributes$0AF4. Parameters2 index,1 mode;
  locals3 value,4 bar pointer. Bounds are addressed again for the initial clear. }
procedure draw_attribute_bar(stat_index, bar_pattern: integer);
var
  stat_value: integer;
  bar: ^bounds4;
begin
  bar := @stat_editor.bars[stat_index];
  stat_value := data29.bytes[94 + stat_index];
  apply_bounds(stat_editor.bars[stat_index], 8);
  if stat_value > 0 then
  begin
    set_clip_bounds(bar^.lower_first, bar^.lower_first + stat_value,
              bar^.lower_second, bar^.upper_second);
    draw_clip_pattern(bar_pattern)
  end;
  apply_bounds(data29.bounds11, 0);
  move_pen(bar^.upper_first + 8, bar^.lower_second - 2);
  draw_integer(stat_value, 3, false)
end;
