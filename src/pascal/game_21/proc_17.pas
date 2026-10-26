{ game_21 procedure17, $07E4..$0842, attributes $084C.
  Output writes are ordered; parent56 is reread after each possible alias. }
procedure proc21_17(var xlow, xhigh, ylow, yhigh: integer);
begin
  if data29.bits37.mid6 = 60 then
  begin
    data29.flags82[113] := true;
    g21.words[35] := 1;
    g21.words[56] := data29.bytes[541];
    proc22_37(0, g21.words[56], 9)
  end
  else g21.words[56] := 9;
  data29.bytes[545] := g21.words[56];
  xlow := 18 - g21.words[56];
  xhigh := 21 + g21.words[56];
  g21.words[56] := (g21.words[56] + 1) div 2;
  ylow := 10 - g21.words[56];
  yhigh := 13 + g21.words[56]
end;
