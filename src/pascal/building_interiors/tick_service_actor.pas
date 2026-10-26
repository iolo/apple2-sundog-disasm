{ game_18 procedure27, $1616..$1711, attributes $171E. }
procedure tick_service_actor;
var
  actor_index: integer;
  random_value: integer;
  service_waiting: boolean;
begin
  if odd(room_controls[142]) then exit(tick_service_actor);
  with room_actors[0] do begin
    if flags.bit5 then begin
      step_room_actor(0);
      if not flags.bit5 then begin
        if (bytes9[0] = 1) and room_actors[1].flags.bit3 then switch_room_context(true)
        else begin
          room_actors[bytes9[0]].flags.bit4 := true;
          { Capture this destination before random, as $1668..$1677 do. }
          with room_actors[bytes9[0]].pair9 do begin
            random_value := random_word;
            low := 64 + random_value mod 192
          end;
          room_layout_state[125] := room_layout_state[125] - 1
        end;
        bytes9[0] := 0
      end
    end else begin
      service_waiting := room_layout_state[125] > 0;
      random_value := random_word;
      if service_waiting and (random_value mod 8 = 0) then begin
        actor_index := 1;
        while actor_index <= actor_count do begin
          if room_actors[actor_index].flags.bit3 and not room_actors[actor_index].flags.bit4 then begin
            flags.bit5 := true;
            bytes9[0] := actor_index;
            words[1] := room_actors[actor_index].words[5] + room_layout_state[115];
            words[0] := room_actors[actor_index].words[4] + room_layout_state[114];
            words[3] := words[1];
            words[2] := words[0];
            actor_index := actor_count + 1
          end else actor_index := actor_index + 1
        end
      end
    end
  end
end;
