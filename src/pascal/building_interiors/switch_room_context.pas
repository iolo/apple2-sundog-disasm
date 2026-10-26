{ game_18 procedure23, $114A..$1363, attributes $1370.
  Parent arguments4/3/2 hold addresses; caller-owned words remain aliased.
  Choice false opens the recovered game8 scope after preserving bounds. }
procedure switch_room_context(open_interaction: boolean);
var
  window_direction: integer;
  saved_bounds: bounds4;
  caller_x: address16;
  caller_y: address16;
  caller_result: address16;
begin
  caller_x.word := window_x_address;
  caller_y.word := window_y_address;
  caller_result.word := resume_address;
  if not odd(data29.words[347]) then begin
    data29.nibbles45[0] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[2]
  end;
  room_controls[143] := 1;
  room_layout_state[119] := caller_x.value^;
  room_layout_state[118] := caller_y.value^;
  clamp_word(10, caller_x.value^, 39);
  clamp_word(7, caller_y.value^, 23);
  window_direction := 5 - 3 * word_sign(caller_x.value^ - 20) -
               word_sign(caller_y.value^ - 12);
  case window_direction of
    1, 2, 4, 5: begin
      caller_x.value^ := caller_x.value^ - 2;
      caller_y.value^ := caller_y.value^ - 2
    end;
    3, 6: begin
      caller_x.value^ := caller_x.value^ - 2;
      caller_y.value^ := caller_y.value^ + 2
    end;
    7, 8: begin
      caller_x.value^ := caller_x.value^ + 2;
      caller_y.value^ := caller_y.value^ - 2
    end;
    9: begin
      caller_x.value^ := caller_x.value^ + 2;
      caller_y.value^ := caller_y.value^ + 2
    end
  end;
  if not odd(caller_x.value^) then
    caller_x.value^ := caller_x.value^ + word_sign(20 - caller_x.value^);
  if open_interaction then begin
    if odd(room_controls[142]) then data29.nibbles45[2] := 8
    else begin
      data29.nibbles45[2] := 9;
      room_actors[1].flags.bit4 := true
    end;
    if odd(room_controls[141]) then begin
      caller_result.value^ := room_layout_state[116];
      selected_actor := data29.bytes[550]
    end else begin
      selected_actor := 0;
      caller_result.value^ := 21;
      case venue_kind of
        8: caller_result.value^ := 12;
        9: caller_result.value^ := 13;
        10: caller_result.value^ := 14;
        11: caller_result.value^ := 23;
        16: begin caller_result.value^ := 7; selected_actor := 1 end
      end
    end;
    with room_actors[selected_actor] do begin
      data29.bytes[548] := split8.high;
      data29.bytes[549] := split8.low;
      data29.bytes[550] := selected_actor;
      data29.bytes[551] := 1;
      data29.bytes[552] := ord(flags.bit1)
    end
  end else begin
    if not odd(data29.words[347]) then data29.nibbles45[2] := 7;
    if data29.nibbles45[2] <> 12 then begin
      toggle_pointer_glyph(room_controls[134], room_controls[133]);
      saved_bounds := data29.bounds11;
      run_personal_panel(caller_x.value^, caller_y.value^);
      initialize_pointer(room_controls[134], room_controls[133], data29.words[298], saved_bounds);
      data29.bounds11 := saved_bounds;
      room_controls[143] := ord(data29.nibbles45[2] > 10)
    end
  end
end;
