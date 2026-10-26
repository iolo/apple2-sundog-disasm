{ game_12 procedure3, $0012..$005D, attributes $0068; nested in1.
  Signed word arithmetic and positive-width guard precede both fills. }
procedure draw_target_hull;
var
  hull_width: integer; {1}
  unused2: integer;
begin
  if odd(g12.target_present) then
  begin
    hull_width := (data29.target_hull + 2) div 3;
    if hull_width > 0 then
    begin
      set_clip_bounds(g12.words[40], g12.words[40] + hull_width,
                  g12.words[38], g12.words[37]);
      if hull_width > 43 then draw_clip_pattern(5) else draw_clip_pattern(6);
      set_clip_bounds(g12.words[40] + hull_width + 1, g12.words[39],
                  g12.words[38], g12.words[37]);
      draw_clip_pattern(4)
    end
  end
end;
