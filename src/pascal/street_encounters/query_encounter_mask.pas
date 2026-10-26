{ game_17 procedure2, $0000..$0013, attributes $001C.
  Same native mode2 query as game18:3; result word1 is canonical0/1. }
function query_encounter_mask(code, x, y: integer): boolean;
begin
  set_glyph_mode(2);
  move_pen(x, y);
  draw_glyph(code);
  query_encounter_mask := odd(data29.words[1])
end;
