{ game_21 procedure39, $198C..$1A17, attributes $1A22; nested in38.
  Value string is copied before effects. The shared button bounds occupy
  parent slots5..8; the second call replaces the first button's rectangle. }
procedure draw_teleport_button(caption: text80; heading: boolean);
var
  caption_x: integer;
begin
  if heading then
    assign_bounds(active_button, data29.words[14] + 4, data29.words[13] - 4,
                data29.words[12] + 2, data29.words[12] + 12)
  else
    assign_bounds(active_button, data29.words[14] + 4, data29.words[13] - 4,
                data29.words[11] - 12, data29.words[11] - 2);
  set_clip_bounds(active_button.lower_first - 2, active_button.upper_first + 2,
              active_button.lower_second - 2, active_button.upper_second + 2);
  draw_clip_pattern(10);
  apply_bounds(active_button, 8);
  caption_x := (active_button.lower_first + active_button.upper_first) div 2 - 3 * length(caption);
  move_pen(caption_x, active_button.upper_second - 1);
  draw_text(caption);
  if heading then apply_bounds(active_button, 3)
end;
