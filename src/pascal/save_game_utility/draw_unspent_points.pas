{ utility_disk1:24 $0AF6..$0B3E, attributes$0B48. One local word.
  Display the points bar at rounded-up one-eighth scale. }
procedure draw_unspent_points;
var width: integer;
begin
  apply_bounds(stat_editor.points, 8);
  if stat_editor.unspent_points > 0 then
  begin
    width := (stat_editor.unspent_points + 7) div 8;
    set_clip_bounds(stat_editor.words[32], stat_editor.words[32] + width,
              stat_editor.words[30], stat_editor.words[29]);
    draw_clip_pattern(10)
  end;
  apply_bounds(data29.bounds11, 0);
  move_pen(stat_editor.words[31] + 9, stat_editor.words[29] + 3);
  draw_integer(stat_editor.unspent_points, 3, false)
end;
