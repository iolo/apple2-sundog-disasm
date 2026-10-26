{ game_15 procedure13, $070C..$07BE, attributes $07CA.
  Six locals retain slots1..6. Try doubled signed steps, clipped to distance;
  retry with unit steps only when BOTH coordinates remain unchanged.
  Cursor calls bracket both attempts; arithmetic remains signed16-bit. }
procedure walk_ship_interior;
var
  dy: integer;
  dx: integer;
  oldy: integer;
  oldx: integer;
  stepy: integer;
  stepx: integer;
begin
  dx := (g15.cursor_x - 3) - g15.marker_x;
  dy := (g15.cursor_y + 3) - g15.marker_y;
  if (dx <> 0) or (dy <> 0) then
  begin
    stepx := word_sign(dx);
    stepx := stepx + stepx;
    if word_abs(stepx) > word_abs(dx) then stepx := dx;
    stepy := word_sign(dy);
    stepy := stepy + stepy;
    if word_abs(stepy) > word_abs(dy) then stepy := dy;
    toggle_pointer_glyph(g15.cursor_x, g15.cursor_y);
    oldx := g15.marker_x;
    oldy := g15.marker_y;
    step_glyph_pair(g15.marker_glyph, g15.background_glyph, stepx, stepy, g15.marker_x, g15.marker_y);
    if (oldx = g15.marker_x) and (oldy = g15.marker_y) then
      step_glyph_pair(g15.marker_glyph, g15.background_glyph, word_sign(stepx), word_sign(stepy),
                g15.marker_x, g15.marker_y);
    toggle_pointer_glyph(g15.cursor_x, g15.cursor_y)
  end
end;
