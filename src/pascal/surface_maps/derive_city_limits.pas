{ game_21 procedure17, $07E4..$0842, attributes $084C.
  Output writes are ordered; parent56 is reread after each possible alias. }
procedure derive_city_limits(var left_limit, right_limit, top_limit, bottom_limit: integer);
begin
  if data29.bits37.mid6 = 60 then
  begin
    data29.flags82[113] := true;
    g21.contract_city := 1;
    g21.words[56] := data29.bytes[541];
    clamp_word(0, g21.words[56], 9)
  end
  else g21.words[56] := 9;
  data29.bytes[545] := g21.words[56];
  left_limit := 18 - g21.words[56];
  right_limit := 21 + g21.words[56];
  g21.words[56] := (g21.words[56] + 1) div 2;
  top_limit := 10 - g21.words[56];
  bottom_limit := 13 + g21.words[56]
end;
