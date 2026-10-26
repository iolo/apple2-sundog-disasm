{ game_20 procedure6, $0204..$025F, attributes $026A; nested in5.
  Copy seven source words first; update only30 entries, preserving padding.
  Parent growth is slot3. }
procedure grow_market_levels(target: g20levels; var current: g20levels);
var
  item_index, new_level: integer;
begin
  item_index := 1;
  while item_index <= 30 do
  begin
    if target.values[item_index] <> current.values[item_index] then
    begin
      new_level := current.values[item_index] + elapsed_weeks;
      if new_level > target.values[item_index] then new_level := target.values[item_index];
      current.values[item_index] := new_level
    end;
    item_index := item_index + 1
  end
end;
