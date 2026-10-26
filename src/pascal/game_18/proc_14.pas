{ game_18 procedure 14, $0908..$0AB3, attributes $0AC0.
  CSP 10 at $0910 fills all 180 bytes of the nine-entry storage view. }
procedure proc18_14;
var
  candidate, cursor: integer;
begin
  fillchar(g18items, 180, 0);
  with g18items[1] do
  begin
    if odd(g18a133[142]) then
    begin
      split6.high := 12;
      split6.low := 13;
      data29.flags45[12] := data29.flags45[13];
      data29.flags45[13] := false;
      if data29.flags45[12] then
      begin
        words[5] := g18w131 + 28;
        words[4] := g18a112[129] + 44
      end
      else
      begin
        words[5] := g18w131 + 28;
        words[4] := g18a112[129] + 67
      end
    end
    else
    begin
      split6.high := 22;
      split6.low := 24;
      words[5] := g18a112[121];
      words[4] := g18a112[120]
    end;
    { $0991..$09CE: explicit stores are retained even after the fill. }
    words[3] := words[5];
    words[2] := words[4];
    flags.bit3 := false;
    flags.bit4 := false;
    flags.bit5 := false;
    flags.bit1 := false;
    bytes9[0] := 0;
    split8.high := 0;
    split8.low := 4;
    proc18_4(1)
  end;
  if odd(g18a133[142]) then
  begin
    g18w132 := 1;
    g18a112[124] := 0;
    exit(proc18_14)
  end;
  { $09E4..$0A11: the limit is reread; a failure shrinks it without advancing. }
  g18a112[125] := 0;
  cursor := 2;
  while cursor <= g18w132 do
  begin
    candidate := cursor;
    proc18_13(candidate, true);
    if candidate < 0 then g18w132 := g18w132 - 1
    else cursor := cursor + 1
  end;
  with g18items[0] do
  begin
    { $0A13..$0A68: retain the actual bound order used by the original calls. }
    if g18w132 > 1 then
    begin
      words[5] := g18items[2].words[5] + g18a112[115];
      words[4] := g18items[2].words[4] + g18a112[114]
    end
    else
    begin
      words[5] := proc22_40(g18b107.upper_first, g18b107.lower_first) +
                  g18a112[115];
      words[4] := proc22_40(g18b107.lower_second, g18b107.upper_second) +
                  g18a112[114]
    end;
    words[3] := words[5];
    words[2] := words[4];
    words[1] := words[3];
    words[0] := words[2];
    flags.bit5 := false;
    flags.bit1 := false;
    bytes9[0] := 0;
    split8.high := 0;
    split8.low := 3;
    split6.high := 23;
    split6.low := 3;
    proc18_4(0)
  end
end;
