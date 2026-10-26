{ game_14 procedure11, $072C..$0789, attributes $0794.
  Two native masks precede the comparisons. No default layout inference. }
function item_fits_component(code, index: integer): boolean;
var
  fits: boolean;
  base: integer;
begin
  if data29.nibbles45[1] = 5 then item_fits_component := false
  else
  begin
    base := g14.group_byte_base + 20;
    index := word_and((index - data31.words[15]) - 1, 3);
    code := word_and(code, 31);
    fits := ((code = 23) and (index > 0)) or
            (code = data29.bytes[178 + (base + index)]);
    if not fits then
      fits := (code = data29.bytes[178 + (base + 6)]) and
              (index = data29.bytes[178 + (base + 7)]);
    item_fits_component := fits
  end
end;
