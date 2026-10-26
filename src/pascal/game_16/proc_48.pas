{ game_16 procedure48, $1B90..$1BAC, attributes $1BB6. }
function proc16_48: boolean;
begin
  if odd(g16.words[18]) then proc16_48 := 10 <= g16.words[41]
  else proc16_48 := data29.flags82[80 + g16.words[41]]
end;
