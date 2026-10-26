{ game_21 procedure6, $00B0..$01A5, attributes $01AE.
  Save packed location first, then copy all six words to the parked location
  when flag13 is clear. Later stores must reread aliased VAR arguments. }
procedure proc21_6;
begin
  proc22_41(g21.words[19], g21.words[18]);
  if (data29.nibbles45[2] <> 11) and (data29.nibbles45[2] <> 2) then
    if data29.flags45[13] or not odd(arg1) then proc21_5;
  data29.bits38.low6 := (arg6 + g21.words[26] div 28) mod 40;
  data29.bits39.low5 := (arg5 + g21.words[25] div g21.words[21]) mod 24;
  if (data29.nibbles45[2] >= 11) or (data29.nibbles45[2] <= 4) then
  begin
    data29.words[40] := 140 + g21.words[26] mod 28;
    data29.bytes[80] := 96 + g21.words[25] mod g21.words[21]
  end
  else
  begin
    data29.words[40] := g21.words[26];
    data29.bytes[80] := g21.words[25]
  end;
  if not data29.flags45[13] then
  begin
    data29.rec228 := data29.rec36;
    if odd(g21.words[26]) then data29.bytes[507] := g21.words[31]
    else data29.bytes[507] := g21.words[30];
    data29.bytes[506] := g21.words[29]
  end;
  if odd(arg1) then
  begin
    data29.nibbles45[1] := data29.nibbles45[2];
    data29.nibbles45[2] := 5;
    arg2 := 16
  end;
  proc22_21(data29.words[16], false);
  proc22_21(2048, true)
end;
