{ game_21 procedure10, $02EC..$02FF, attributes $0308.
  Return DATASEG29 word1 only after the drawing calls. }
function proc21_10(glyph, xpos, ypos: integer): integer;
begin
  proc22_11(2);
  proc22_12(xpos, ypos);
  proc22_9(glyph);
  proc21_10 := data29.words[1]
end;
