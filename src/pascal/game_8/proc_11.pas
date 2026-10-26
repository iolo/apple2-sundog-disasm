{ game_8 procedure11, $04D0..$0502, attributes $050E.
  Poll selector4 on every iteration, including when word347's low bit is set. }
procedure proc8_11;
var
  randomv: integer;
  inputv: integer;
begin
  repeat
    randomv := proc22_3;
    if randomv mod 8 = 0 then
      data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc8_3(false, false);
    inputv := proc22_2(4)
  until not odd(inputv) or odd(data29.words[347])
end;
