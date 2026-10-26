{ game_18 procedure28, $1720..$17E1, attributes $17F0.
  The computed entry address in original local2 is never dereferenced. }
procedure advance_room_customers;
var
  actor_index: integer;
  random_value: integer;
begin
  if odd(room_controls[142]) then exit(advance_room_customers);
  if (room_layout_state[124] > 1) or (room_layout_state[123] > 1) then begin
    if room_layout_state[124] > 1 then step_room_actor(room_layout_state[124]);
    if room_layout_state[123] > 1 then step_room_actor(room_layout_state[123])
  end else begin
    random_value := random_word;
    if random_value mod room_layout_state[122] = 0 then begin
      actor_index := 2 + room_layout_state[113] div 2;
      random_value := random_word;
      if ((random_value mod actor_count < actor_index) and (actor_count < actor_index)) or
         (actor_count = 1) then begin
        actor_index := actor_count + 1;
        create_room_actor(actor_index, false);
        if actor_index > 0 then begin
          room_layout_state[124] := actor_index;
          actor_count := actor_index
        end
      end else begin
        room_layout_state[124] := random_between(2, actor_count);
        if data29.flags82[65] then redirect_room_actor(room_layout_state[124])
        else begin
          random_value := random_word;
          if odd(random_value) or not odd(room_controls[139]) then send_actor_to_exit(room_layout_state[124])
          else redirect_room_actor(room_layout_state[124])
        end
      end
    end
  end
end;
