{ game_20 procedure29, $1672..$16E6, attributes $16F2; nested in28.
  Display22 bytes from the168-byte ring, then advance its head by one.
  The random call after the clock update also occurs in contract mode. }
procedure proc20_29;
var
  offset, index, randomv: integer;
begin
  proc22_11(3);
  proc22_12(g20.words[6], g20.words[5]);
  offset := g20.words[7];
  for index := 1 to 22 do
  begin
    proc22_9(g20.capt60[offset]);
    offset := (offset + 1) mod 168
  end;
  g20.words[7] := (g20.words[7] + 1) mod 168;
  data29.words[354] := data29.words[354] + 1;
  if data29.words[354] >= 10 then
  begin
    proc22_29;
    randomv := proc22_3;
    if (randomv mod 8 = 0) and not odd(g20.words[16]) then
      proc20_21(((g20.words[7] + 40) mod 168) div 21)
  end
end;
