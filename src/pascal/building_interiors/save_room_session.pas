{ game_18 procedure 22, $1068..$113C, attributes $1148. }
procedure save_room_session;
var
  save_byte_count: integer;
  resume_buffer: address16;
begin
  if (data29.nibbles45[2] < 7) or (data29.nibbles45[2] > 10) then
  begin
    if odd(room_controls[142]) then
    begin
      window_image_transfer(1);
      data29.words[20] := 0
    end
    else pop_text_window;
    apply_bounds(data29.bounds7, 0);
    if not odd(data29.words[347]) then
    begin
      if data29.nibbles45[2] = 11 then
      begin
        if data29.nibbles45[0] <> 11 then
          data29.nibbles45[1] := data29.nibbles45[0]
        else if data29.bits37.mid6 <> 0 then data29.nibbles45[1] := 3
        else data29.nibbles45[1] := 4
      end
      else
      begin
        data29.nibbles45[2] := data29.nibbles45[1];
        data29.nibbles45[1] := 5
      end;
      data29.nibbles45[0] := 11
    end;
    data29.words[351] := room_layout_state[117];
    data29.words[353] := room_layout_state[112];
    data29.flags82[57] := false
  end
  else
  begin
    room_save_state[152] := -9408;
    save_byte_count := word_address(room_save_state[151]) - word_address(room_actors[0].words[0]);
    resume_buffer.word := room_save_state[152];
    moveleft(room_actors, resume_buffer.bytes^, save_byte_count);
    data29.bytes[551] := 1
  end
end;
