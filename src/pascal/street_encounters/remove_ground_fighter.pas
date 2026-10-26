{ game_17 procedure4, $0046..$008B, attributes $0096.
  The unused entry-address calculation at $0046..$004C has no memory read.
  MOV5 copies all ten bytes, including packed flags and spare bits. }
procedure remove_ground_fighter(index: integer);
var
  source_index, last_fighter: integer;
begin
  toggle_fighter_glyph(index);
  source_index := index + 1;
  last_fighter := g17.fighter_count;
  while source_index <= last_fighter do
  begin
    g17.items[source_index - 1] := g17.items[source_index];
    source_index := source_index + 1
  end;
  g17.fighter_count := g17.fighter_count - 1;
  if g17.fighter_count = 1 then g17.exit_requested := 1
end;
