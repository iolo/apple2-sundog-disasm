{ game_16 procedure44, $19C8..$19F8, attributes $1A04.
  Each iteration consumes random, optionally ticks, then always polls input4
  before considering global347. One explicit random temporary is added. }
procedure proc16_44;
var
  randomv: integer;
begin
  repeat
    randomv := proc22_3;
    if randomv mod 8 = 0 then data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc16_30
  until not odd(proc22_2(4)) or odd(data29.words[347])
end;
