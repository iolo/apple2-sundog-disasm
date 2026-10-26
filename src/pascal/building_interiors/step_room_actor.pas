{ game_18 procedure 12, $0498..$075D, attributes $0778.
  Include in procedure 1 after procedures 2, 6, 10, and 11.
  WITH retains the original entry address across native calls. }
procedure step_room_actor(index: integer);
var
  delta_y, delta_x, scratch_y, scratch_x, step_y, step_x: integer;
  random_value: integer;
  inside_room: boolean;
begin
  with room_actors[index] do
  begin
    { $04A0..$0525: derive signed steps toward words 1/0. Keep word arithmetic. }
    if (words[5] <> words[1]) or (words[4] <> words[0]) then
    begin
      if index = 1 then
        toggle_pointer_glyph(room_controls[134], room_controls[133]);
      delta_x := words[1] - words[5];
      step_x := word_sign(delta_x);
      step_x := step_x + step_x;
      if word_abs(step_x) > word_abs(delta_x) then step_x := delta_x;
      delta_y := words[0] - words[4];
      step_y := word_sign(delta_y);
      step_y := step_y + step_y;
      if word_abs(step_y) > word_abs(delta_y) then step_y := delta_y;
      scratch_x := words[5];
      scratch_y := words[4];
      step_glyph_pair(split6.high, split6.low, step_x, step_y, words[5], words[4]);
      if index = 1 then
      begin
        { $052D..$0568: retry only axes whose coordinates did not change. }
        if scratch_x <> words[5] then step_x := 0;
        if scratch_y <> words[4] then step_y := 0;
        step_glyph_pair(split6.high, split6.low, word_sign(step_x),
                  word_sign(step_y), words[5], words[4]);
        toggle_pointer_glyph(room_controls[134], room_controls[133])
      end
      else if (scratch_x = words[5]) and (scratch_y = words[4]) then
      begin
        { $0578..$05AD: surround the second movement attempt with calls 41. }
        toggle_pointer_glyph(room_controls[134], room_controls[133]);
        step_glyph_pair(split6.high, split6.low, step_x, step_y, words[5], words[4]);
        toggle_pointer_glyph(room_controls[134], room_controls[133]);
        if (scratch_x = words[5]) and (scratch_y = words[4]) then
        begin
          { $05B0..$05C4: the bounds call is evaluated on either flag value. }
          inside_room := inside_actor_area(words[5], words[4], room_walk_bounds);
          if (flags.high_byte = 3) and inside_room then
          begin
            words[1] := words[5];
            words[0] := words[4];
            words[3] := words[5];
            words[2] := words[4]
          end
          else
          begin
            { $05DE: FJP tests bit 0 of the random word, not nonzero. }
            random_value := random_word;
            if odd(random_value) then
            begin
              words[1] := words[5] + random_between(-7, 7);
              words[0] := words[4] + random_between(-7, 7);
              if words[1] = words[5] then
                words[0] := words[4] + random_between(-2, 2);
              if words[0] = words[4] then
                words[1] := words[5] + random_between(-2, 2)
            end
            else
            begin
              { $062D..$0641: reread the flag after procedure 10. }
              flags.bit5 := false;
              redirect_room_actor(index);
              if not flags.bit5 then send_actor_to_exit(index)
            end
          end
        end
      end
      { All moving paths join $0643 and return at $075D. }
    end
    else if (words[3] <> words[1]) or (words[2] <> words[0]) then
    begin
      { $0645..$065C. }
      words[1] := words[3];
      words[0] := words[2]
    end
    else
    begin
      { $065E..$067D: only the first matching parent reference is cleared. }
      flags.bit5 := false;
      if index = room_layout_state[124] then room_layout_state[124] := 0
      else if index = room_layout_state[123] then room_layout_state[123] := 0;
      if flags.high_byte = 1 then
      begin
        words[3] := room_actors[1].words[5];
        words[2] := room_actors[1].words[4];
        flags.bit5 := true
      end
      else if flags.high_byte = 2 then
        remove_room_actor(index)
      else if flags.high_byte = 3 then
      begin
        flags.bit3 := true;
        flags.bit4 := false;
        bytes9[0] := 0;
        room_layout_state[125] := room_layout_state[125] + 1;
        flags.high_byte := 0
      end
      else if flags.high_byte >= 4 then
      begin
        { $06EF..$075C; old1/old2 are now row/column temporaries. }
        flags.bit2 := true;
        if room_actors[1].flags.bit2 then
        begin
          scratch_x := (flags.high_byte - 4) div 2;
          scratch_y := (flags.high_byte + 1) mod 2;
          if counter_slots[scratch_x][scratch_y] = 1 then
          begin
            if flags.bit0 then
            begin
              if flags.bit1 then room_layout_state[116] := 17
              else room_layout_state[116] := 22
            end
            else room_layout_state[116] := 21;
            room_controls[141] := 1;
            data29.bytes[550] := index
          end
        end;
        flags.high_byte := 0
      end
    end
  end
end;
