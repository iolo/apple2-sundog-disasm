{ game_18 procedure 24, $1372..$142C, attributes $1436. }
procedure probe_counter_neighbor;
var
  neighbor_actor, column, row: integer;
begin
  with room_actors[1] do
  begin
    row := ((words[5] + 3 - room_left) * 3) div (room_layout_state[130] - room_left);
    if word_abs(words[5] - (room_left +
        (row * (room_layout_state[130] - room_left)) div 3)) < 10 then column := 0
    else column := 1;
    counter_slots[row][column] := 1;
    flags.high_byte := (4 + 2 * row) + column;
    neighbor_actor := counter_slots[row][(column + 1) mod 2]
  end;
  with room_actors[neighbor_actor] do
      if (neighbor_actor > 0) and flags.bit2 then
        if not flags.bit5 then
        begin
          if flags.bit0 and flags.bit1 and data29.flags82[65] then
            room_layout_state[116] := 17
          else room_layout_state[116] := 21;
          data29.bytes[550] := neighbor_actor;
          room_controls[141] := 1
        end
end;
