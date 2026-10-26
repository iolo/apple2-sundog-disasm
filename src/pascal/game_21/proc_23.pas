{ game_21 procedure23, $0C1E..$0C95, attributes $0C9E. }
procedure proc21_23;
(*$include src/pascal/game_21/proc_24.pas*)
begin
  g21.words[37] := 0;
  if data29.nibbles45[2] = 3 then
  begin
    if data29.flags45[13] then proc21_24(10, 10, 11)
    else
    begin
      g21.words[37] := 1;
      g21.words[30] := data29.bytes[507];
      g21.words[31] := data29.bytes[507];
      g21.words[29] := 17;
      proc21_22(g21.glyph39, 14);
      proc21_22(g21.glyph47, 15);
      if data29.nibbles45[1] = 4 then
      begin
        g21.words[30] := g21.glyph39[data29.words[292]];
        g21.words[31] := g21.words[30]
      end
    end
  end
  else if data29.flags45[13] then proc21_24(10, 10, 15)
  else proc21_24(26, 29, 15)
end;
