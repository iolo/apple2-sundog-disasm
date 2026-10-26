{ game_13 procedure11, $0622..$069E, attributes $06A8; nested in3.
  Restore rates and bounds before restoring the screen. Recheck bounds after
  that call, restore flag5, clear118/119, then conditionally redraw. }
procedure proc13_11;
begin
  data29.words[353] := g13s.words[4];
  data29.words[351] := g13s.words[1];
  data29.bounds327 := g13s.saved18;
  proc22_52;
  if (data29.words[330] < data29.words[329]) and (data29.words[328] < data29.words[327]) then
  begin
    proc22_19(data29.bounds327, 0);
    proc22_12(data29.words[330] + 3, data29.words[327]);
    proc22_28(data29.clock42)
  end;
  data29.flags82[5] := odd(g13s.words[8]);
  data29.flags82[118] := false;
  data29.flags82[119] := false;
  if (data29.nibbles45[2] = data29.nibbles45[1]) and odd(g13s.words[9]) then proc13_5
end;
