{ game_18 procedure 14, $0908..$0AB3, attributes $0AC0.
  CSP 10 at $0910 fills all 180 bytes of the nine-entry storage view. }
procedure seed_room_actors;
var
  new_actor, actor_index: integer;
begin
  fillchar(room_actors, 180, 0);
  with room_actors[1] do
  begin
    if odd(room_controls[142]) then
    begin
      split6.high := 12;
      split6.low := 13;
      data29.flags45[12] := data29.flags45[13];
      data29.flags45[13] := false;
      if data29.flags45[12] then
      begin
        words[5] := room_left + 28;
        words[4] := room_layout_state[129] + 44
      end
      else
      begin
        words[5] := room_left + 28;
        words[4] := room_layout_state[129] + 67
      end
    end
    else
    begin
      split6.high := 22;
      split6.low := 24;
      words[5] := room_layout_state[121];
      words[4] := room_layout_state[120]
    end;
    { $0991..$09CE: explicit stores are retained even after the fill. }
    words[3] := words[5];
    words[2] := words[4];
    flags.bit3 := false;
    flags.bit4 := false;
    flags.bit5 := false;
    flags.bit1 := false;
    bytes9[0] := 0;
    split8.high := 0;
    split8.low := 4;
    toggle_room_actor(1)
  end;
  if odd(room_controls[142]) then
  begin
    actor_count := 1;
    room_layout_state[124] := 0;
    exit(seed_room_actors)
  end;
  { $09E4..$0A11: the limit is reread; a failure shrinks it without advancing. }
  room_layout_state[125] := 0;
  actor_index := 2;
  while actor_index <= actor_count do
  begin
    new_actor := actor_index;
    create_room_actor(new_actor, true);
    if new_actor < 0 then actor_count := actor_count - 1
    else actor_index := actor_index + 1
  end;
  with room_actors[0] do
  begin
    { $0A13..$0A68: retain the actual bound order used by the original calls. }
    if actor_count > 1 then
    begin
      words[5] := room_actors[2].words[5] + room_layout_state[115];
      words[4] := room_actors[2].words[4] + room_layout_state[114]
    end
    else
    begin
      words[5] := random_between(room_walk_bounds.upper_first, room_walk_bounds.lower_first) +
                  room_layout_state[115];
      words[4] := random_between(room_walk_bounds.lower_second, room_walk_bounds.upper_second) +
                  room_layout_state[114]
    end;
    words[3] := words[5];
    words[2] := words[4];
    words[1] := words[3];
    words[0] := words[2];
    flags.bit5 := false;
    flags.bit1 := false;
    bytes9[0] := 0;
    split8.high := 0;
    split8.low := 3;
    split6.high := 23;
    split6.low := 3;
    toggle_room_actor(0)
  end
end;
