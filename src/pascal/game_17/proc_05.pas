{ game_17 procedure5, $0098..$00D0, attributes $00DA. }
procedure proc17_5;
begin
  with g17.items[1] do
  begin
    if data29.flags82[48] then delay := 2 else delay := 10;
    g17.words[78] := 1;
    if life = 0 then data29.nibbles45[1] := 12
  end
end;
