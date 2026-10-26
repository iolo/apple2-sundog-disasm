{ game_18 procedure26, $149A..$1605, attributes $1614.
  Native selector4 produces canonical0/1 here; other raw flag tests use bit0. }
procedure tick_room_player;
var
  movement_input: integer;
begin
  with room_actors[1] do begin
    update_pointer(room_controls[134], room_controls[133]);
    if odd(room_controls[141]) then switch_room_context(true);
    movement_input := poll_input(4);
    if odd(room_controls[138]) <> odd(movement_input) then begin
      room_controls[138] := movement_input;
      if odd(room_controls[138]) then begin
        if odd(room_controls[136]) then flags.bit4 := active_station > 0
        else flags.bit4 := false;
        if room_actors[0].bytes9[0] = 1 then room_actors[0].flags.bit5 := false;
        reindex_room_references(1, true)
      end else begin
        if odd(room_controls[142]) then begin
          if (words[5] >= room_left + 45) and (words[4] > 65) then
            switch_room_context(true)
          else if (words[5] < room_left + 28) and
                  (words[4] < room_layout_state[129] + 46) then begin
            data29.flags45[13] := true;
            room_controls[143] := 1
          end else if (words[5] < room_left + 35) and
                      (words[4] > room_layout_state[129] + 62) then begin
            data29.flags45[13] := false;
            room_controls[143] := 1
          end
        end else begin
          flags.bit3 := inside_actor_area(words[5], words[4], room_walk_bounds);
          flags.bit2 := (words[4] >= room_layout_state[128] - 2) and odd(room_controls[139]);
          if flags.bit2 then probe_counter_neighbor
          else if odd(room_controls[136]) and (active_station > 0) then refresh_service_area
        end;
        if flags.bit3 and not flags.bit4 then begin
          room_layout_state[125] := room_layout_state[125] + 1;
          bytes9[0] := 0
        end
      end
    end;
    if odd(poll_input(4)) then begin
      words[1] := room_controls[134] - 3;
      words[0] := room_controls[133] + 3;
      step_room_actor(1);
      room_controls[143] := ord(odd(room_controls[143]) or
                          (words[5] < data29.words[14] + 10))
    end;
    if odd(poll_input(1)) then switch_room_context(false)
  end
end;
