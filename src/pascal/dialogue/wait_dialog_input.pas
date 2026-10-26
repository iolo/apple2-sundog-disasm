{ game_16 procedure44, $19C8..$19F8, attributes $1A04.
  Each iteration consumes random, optionally ticks, then always polls input4
  before considering global347. One explicit random temporary is added. }
procedure wait_dialog_input;
var
  random_value: integer;
begin
  repeat
    random_value := random_word;
    if random_value mod 8 = 0 then data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then tick_dialog_clock
  until not odd(poll_input(4)) or odd(data29.words[347])
end;
