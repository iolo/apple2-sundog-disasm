{ game_17 procedure6, $00DC..$0125, attributes $0130.
  DATASEG29 word62 byte0 is absolute byte122. The scan still reads byte126
  when index reaches4: do not move the index guard ahead of the native call. }
procedure proc17_6;
begin
  g17.words[77] := 0;
  while (proc22_32(data29.bytes[122 + g17.words[77]], 31) <> 11)
        and (g17.words[77] < 4) do
    g17.words[77] := g17.words[77] + 1;
  g17.words[41] := ord(g17.words[77] < 4);
  if odd(g17.words[41]) then
    g17.words[76] := proc22_31(data29.bytes[122 + g17.words[77]], 5)
  else g17.words[76] := 0
end;
