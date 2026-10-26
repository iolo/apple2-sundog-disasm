{ game_16 procedure11, $04AA..$0575, attributes $0582.
  Item rejection repeats with fixed limits. Capture the item predicate before
  the unconditional8(30),8(166) calls; reread item41 after both calls.
  Reuse previously unused locals for temporaries, keeping the24-byte frame. }
procedure proc16_11;
var
  upper: integer;       {1}
  lower: integer;
  factor: integer;
  allowed: boolean;     {4}
  randomv: integer;
  before4: integer;
  eligible: boolean;
  firstres: boolean;
  secondres: boolean;
  unused10: integer;
  unused11: integer;
  unused12: integer;
begin
  if g16.words[41] = 0 then
  begin
    lower := 12;
    if arg1 = 17 then upper := 22
    else if arg1 = 15 then upper := 18
    else upper := 31;
    repeat
      g16.words[41] := proc22_40(lower, upper);
      allowed := data29.flags82[80 + g16.words[41]];
      if (g16.words[41] < 14) or (g16.words[41] > 22) then allowed := not allowed
    until allowed
  end;
  if arg1 >= 17 then
  begin
    g16.words[4] := 20;
    if g16.words[41] > 22 then factor := 2 else factor := 12;
    before4 := g16.words[4] + 4;
    randomv := proc22_3;
    g16.words[5] := before4 + randomv mod factor;
    eligible := g16.words[41] > 14;
    firstres := odd(proc16_8(30));
    secondres := odd(proc16_8(166));
    if eligible and not (firstres or secondres) then
      g16.words[41] := g16.words[41] + 128;
    if odd(g16.words[18]) then
    begin
      g16.words[36] := -1;
      factor := g16.words[5];
      g16.words[5] := g16.words[4];
      g16.words[4] := factor
    end
    else g16.words[36] := 1
  end;
  proc16_3(g16.words[41], 0);
  if arg1 = 15 then proc16_3(0, 1)
end;
