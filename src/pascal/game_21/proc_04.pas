{ game_21 procedure4, $0020..$0040, attributes $004A; nested in3.
  Set the cache bit only after the original unit-read call returns. }
procedure proc21_4(flag, buffer, index: integer);
begin
  if not data29.flags82[flag] then
  begin
    proc22_53(buffer, 4, 6 + 4 * index, true);
    data29.flags82[flag] := true
  end
end;
