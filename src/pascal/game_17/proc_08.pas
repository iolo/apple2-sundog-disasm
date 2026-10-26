{ game_17 procedure8, $01C6..$0205, attributes $0210.
  Capture the selected entry once, before random calls. VAR matches the
  original address argument even though this routine does not write index. }
procedure proc17_8(var index: integer);
begin
  with g17.items[index] do
    repeat
      first := proc22_40(g17.words[87] + 20, g17.words[86] - 20);
      second := proc22_40(g17.words[85] + 10, g17.words[84] - 10)
    until not proc17_2(code, first, second)
end;
