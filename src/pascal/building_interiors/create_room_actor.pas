{ game_18 procedure 13, $077A..$08FA, attributes $0906.
  Frame slot 1 is initially_placed; slot 2 is the address of index.
  An unsuccessful placement sets index to -1 and exits this procedure. }
procedure create_room_actor(var index: integer; initially_placed: boolean);
var
  remaining, secondpos, firstpos: integer;
  random_value: integer;
  placement_failed, entry_blocked: boolean;
begin
  if index > room_layout_state[113] then
  begin
    index := -1;
    exit(create_room_actor)
  end;
  { $078A: capture the entry address before any calls or changes to index. }
  with room_actors[index] do
  begin
    random_value := random_word;
    flags.bit0 := (random_value mod 8) = 0;
    split8.high := 0;
    random_value := random_word;
    split8.low := random_value mod 5;
    flags.bit1 := false;
    if initially_placed then
    begin
      { $07BF..$0820. }
      find_open_room_position(index, firstpos, secondpos, remaining);
      if remaining = 0 then
      begin
        index := -1;
        room_layout_state[124] := 0;
        exit(create_room_actor)
      end;
      words[5] := firstpos;
      words[4] := secondpos;
      words[3] := words[5];
      words[2] := words[4];
      words[1] := words[3];
      words[0] := words[2];
      flags.bit5 := false;
      flags.bit3 := true;
      flags.bit4 := true;
      random_value := random_word;
      bytes9[0] := 2 + (random_value mod 250)
    end
    else
    begin
      { $0823..$0859: try the packed grid, random placement, then grid again. }
      random_value := random_word;
      if (random_value mod 3) = 0 then
        find_counter_position(index, firstpos, secondpos, remaining)
      else remaining := 0;
      if remaining = 0 then
        find_open_room_position(index, firstpos, secondpos, remaining);
      if remaining = 0 then
        find_counter_position(index, firstpos, secondpos, remaining);
      { $085B..$0877: the collision call occurs even when remaining is zero. }
      placement_failed := remaining = 0;
      entry_blocked := query_actor_mask(24, room_layout_state[127], room_layout_state[126] + 5);
      if placement_failed or entry_blocked then
      begin
        room_layout_state[124] := 0;
        index := -1;
        exit(create_room_actor)
      end;
      words[5] := room_layout_state[127];
      words[4] := room_layout_state[126] + 5;
      if odd(room_controls[140]) then
      begin
        words[1] := firstpos;
        words[0] := secondpos + 10 * word_sign(words[4] - secondpos)
      end
      else
      begin
        words[1] := firstpos + word_sign(words[5] - firstpos) *
                    word_abs(secondpos - words[4]);
        words[0] := secondpos
      end;
      words[3] := firstpos;
      words[2] := secondpos;
      flags.bit5 := true;
      flags.bit3 := false;
      flags.bit4 := false;
      bytes9[0] := 0
    end;
    { $08E8..$08F8: common tail, reached only after successful placement. }
    split6.high := 23;
    split6.low := 24;
    toggle_room_actor(index)
  end
end;
