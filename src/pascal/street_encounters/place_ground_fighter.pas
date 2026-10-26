{ game_17 procedure8, $01C6..$0205, attributes $0210.
  Capture the selected entry once, before random calls. VAR matches the
  original address argument even though this routine does not write index. }
procedure place_ground_fighter(var index: integer);
begin
  with g17.items[index] do
    repeat
      first := random_between(g17.arena_left + 20, g17.arena_right - 20);
      second := random_between(g17.arena_top + 10, g17.arena_bottom - 10)
    until not query_encounter_mask(code, first, second)
end;
