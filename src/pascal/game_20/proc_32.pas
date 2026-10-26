{ game_20 procedure32, $19B6..$1A07, attributes $1A10. }
procedure proc20_32;
begin
  proc28_4(g20.zero160, 0, 0);
  proc22_51(data29.words[40] div 7, data29.bytes[80] div 8);
  g20.words[11] := data29.words[353];
  data29.words[353] := 60;
  g20.words[4] := data29.words[351];
  data29.words[351] := 1;
  proc22_44;
  g20.words[14] := 4;
  g20.words[13] := data29.words[13] - data29.words[14] - 4;
  g20.words[12] := data29.words[11] - data29.words[12] - 2
end;
