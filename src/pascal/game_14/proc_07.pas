{ game_14 procedure7, $04E4..$058A, attributes $0596.
  Normalize only bytes greater than144 in the selected20-byte span. }
procedure proc14_7;
var
  index: integer;
  width: integer;
  last: integer;
begin
  if not odd(g14.words[104]) then
  begin
    g14.words[9] := (g14.words[9] + 1) mod 3;
    if action >= 11 then g14.words[9] := g14.words[9] + 3;
    g14.words[4] := 28 * g14.words[9]
  end;
  if g14.words[9] < 6 then
  begin
    data29.bytes[178 + (g14.words[4] + 25)] := 31;
    index := g14.words[4];
    last := g14.words[4] + 19;
    while index <= last do
    begin
      if data29.bytes[178 + index] > 144 then data29.bytes[178 + index] := 7;
      index := index + 1
    end
  end;
  if odd(g14.words[103]) then proc14_6
  else
  begin
    proc22_19(g14.title82, 8);
    width := 6 * length(g14.captions[g14.words[9]]);
    proc22_12((g14.words[84] + g14.words[85] - width) div 2, g14.words[82]);
    proc22_10(g14.captions[g14.words[9]])
  end;
  proc14_4;
  if not odd(g14.words[104]) then proc14_5
end;
