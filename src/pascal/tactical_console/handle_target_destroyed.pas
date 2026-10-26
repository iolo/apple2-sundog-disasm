{ game_12 procedure6, $017C..$0289, attributes $0294; nested in1.
  Bounty adds to only system-row word6, without carry into7. Capture that
  row across printing. Cargo chance runs even without a bounty, and cargo
  field addresses are evaluated before their respective random calls. }
procedure handle_target_destroyed;
var
  bounty_rate: integer;   {1}
  system_rating: integer; {2}
  bounty: integer; {3}
  system_row: g12scratch; {4}
begin
  clear_text_window;
  write_wrapped_text('|TARGET DESTROYED\');
  system_rating := data29.tbl23.rows^[data29.loc73.low4].nibbles8[3];
  if system_rating + data29.target_class > 12 then
  begin
    system_row.word := data29.words[23] + 20 * (data29.loc73.low4 - 1);
    bounty_rate := system_row.row^.nibbles8[4];
    write_wrapped_text('|Bounty:');
    bounty := right_shift_word((data29.target_class + 1) * bounty_rate, 3);
    if bounty = 0 then bounty := 1;
    write_integer(bounty, 3, false);
    write_wrapped_text('000 Cr\');
    system_row.row^.words[6] := system_row.row^.words[6] + bounty
  end;
  if random_between(0, 5) <= data29.target_class then
  begin
    write_wrapped_text('|Cargo detected\|in wreckage');
    g12.wreck_cargo_present := 1;
    data29.flags82[36] := true;
    if data29.flags82[1] then data29.words[207] := 2
    else data29.words[207] := 1;
    g12.cargo34.kind := random_between(1, 30);
    g12.cargo34.category := random_between(4, 7);
    g12.cargo34.origin := 0;
    g12.words[35] := 0
  end
end;
