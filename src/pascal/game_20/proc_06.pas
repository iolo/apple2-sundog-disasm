{ game_20 procedure6, $0204..$025F, attributes $026A; nested in5.
  Copy seven source words first; update only30 entries, preserving padding.
  Parent growth is slot3. }
procedure proc20_6(target: g20levels; var current: g20levels);
var
  cursor, next: integer;
begin
  cursor := 1;
  while cursor <= 30 do
  begin
    if target.values[cursor] <> current.values[cursor] then
    begin
      next := current.values[cursor] + growth;
      if next > target.values[cursor] then next := target.values[cursor];
      current.values[cursor] := next
    end;
    cursor := cursor + 1
  end
end;
