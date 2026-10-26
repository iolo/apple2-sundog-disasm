{ Game 18:9, $032A..$03A9, attributes $03B6. Four argument words:
  index plus three VAR words. Both collision calls in each trial are effectful. }
procedure find_open_room_position(index: integer; var firstpos, secondpos, remaining: integer);
var
  probe_y_step: integer;
  probe_x_step: integer;
  code: integer;
  first_probe_hit: boolean;
  second_probe_hit: boolean;
begin
  remaining := 10;                         { $032A..$032C }
  code := 24;                              { $032D..$032E }
  probe_x_step := 5 * word_sign(
    (room_walk_bounds.upper_first - room_walk_bounds.lower_first) div 4); { $0330..$0340 }
  probe_y_step := 3 * word_sign(
    (room_walk_bounds.upper_second - room_walk_bounds.lower_second) div 4); { $0342..$0352 }
  repeat
    firstpos := random_between(room_walk_bounds.lower_first, room_walk_bounds.upper_first);
    secondpos := random_between(room_walk_bounds.lower_second, room_walk_bounds.upper_second);
    remaining := remaining - 1;            { $0354..$0373 }
    { $0374..$038C: evaluate both calls, in this order, before OR.
      Re-read VAR arguments for the second call, after native effects. }
    first_probe_hit := query_actor_mask(code, firstpos - probe_x_step, secondpos - probe_y_step);
    second_probe_hit := query_actor_mask(code, firstpos + probe_x_step, secondpos + probe_y_step)
  until (not (first_probe_hit or second_probe_hit)) or (remaining = 0); { $038E..$0395 }
  if remaining > 0 then                    { $0397..$03A8 }
    room_actors[index].flags.high_byte := 3
end;
