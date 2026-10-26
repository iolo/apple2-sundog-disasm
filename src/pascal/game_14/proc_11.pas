{ game_14 procedure11, $072C..$0789, attributes $0794.
  Two native masks precede the comparisons. No default layout inference. }
function proc14_11(code, index: integer): boolean;
var
  fits: boolean;
  base: integer;
begin
  if data29.nibbles45[1] = 5 then proc14_11 := false
  else
  begin
    base := g14.words[4] + 20;
    index := proc22_32((index - data31.words[15]) - 1, 3);
    code := proc22_32(code, 31);
    fits := ((code = 23) and (index > 0)) or
            (code = data29.bytes[178 + (base + index)]);
    if not fits then
      fits := (code = data29.bytes[178 + (base + 6)]) and
              (index = data29.bytes[178 + (base + 7)]);
    proc14_11 := fits
  end
end;
