{ game_20 procedure9, $05BC..$0636, attributes $0640.
  Count1 reduces width by2 before the first button's additional subtraction. }
procedure proc20_9(secondpos, code, count: integer;
                   caption1, caption2, caption3: text15);
var
  width: integer;
begin
  width := g20.words[13] div count;
  if count = 1 then width := width - 2;
  proc25_3(code, caption1, g20.words[14], g20.words[14] + width - 2,
            secondpos, secondpos + 10);
  if count > 1 then
    proc25_3(code + 1, caption2, g20.words[14] + width + 2,
              g20.words[14] + width + width - 2, secondpos, secondpos + 10);
  if count > 2 then
    proc25_3(code + 2, caption3, g20.words[14] + width + width + 2,
              g20.words[13], secondpos, secondpos + 10)
end;
