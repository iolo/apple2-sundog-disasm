{ game_17 procedure4, $0046..$008B, attributes $0096.
  The unused entry-address calculation at $0046..$004C has no memory read.
  MOV5 copies all ten bytes, including packed flags and spare bits. }
procedure proc17_4(index: integer);
var
  nextitem, lastitem: integer;
begin
  proc17_3(index);
  nextitem := index + 1;
  lastitem := g17.words[94];
  while nextitem <= lastitem do
  begin
    g17.items[nextitem - 1] := g17.items[nextitem];
    nextitem := nextitem + 1
  end;
  g17.words[94] := g17.words[94] - 1;
  if g17.words[94] = 1 then g17.words[42] := 1
end;
