{ game_21 procedure22, $0BC6..$0BFB, attributes $0C04.
  Write length9 and nine glyph bytes in the original order; bytes10..15 stay. }
procedure build_heading_glyphs(var pattern: g21glyphs; base: integer);
begin
  pattern[0] := 9;
  pattern[1] := base + 6;
  pattern[4] := base;
  pattern[7] := base + 4;
  pattern[2] := base + 2;
  pattern[5] := base;
  pattern[8] := base + 2;
  pattern[3] := base + 4;
  pattern[6] := base;
  pattern[9] := base + 6
end;
