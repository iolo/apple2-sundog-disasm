{ game_19 procedure4, $00D2..$0141, attributes $014A.
  Preserve the original divisor and third-button upper endpoint. }
procedure proc19_4(secondpos, code, count: integer;
                   caption1, caption2, caption3: text15);
var
  width: integer;
begin
  width := g19.words[22] div count;
  proc25_3(code, caption1, g19.words[23], g19.words[23] + width - 2,
            secondpos, secondpos + 10);
  if count > 1 then
    proc25_3(code + 1, caption2, g19.words[23] + width + 2,
              g19.words[23] + width + width - 2, secondpos, secondpos + 10);
  if count > 2 then
    proc25_3(code + 2, caption3, g19.words[23] + width + width + 2,
              g19.words[22], secondpos, secondpos + 10)
end;
