{ game_18 procedure 21, $0EB2..$1057, attributes $1066.
  Parent slot 2 is an address; the copied span is slots 5..150, excluding 151.
  The saved address is the original 16-bit value -9408 ($DB40). }
procedure restore_room_session;
var
  flag_index, discarded_input, random_value: integer;
  caller_word, resume_buffer: address16;
begin
  discarded_input := poll_input(4);
  discarded_input := poll_input(0);
  discarded_input := poll_input(5);
  discarded_input := poll_input(1);
  caller_word.word := resume_address;
  if caller_word.value^ > 0 then
  begin
    room_save_state[152] := -9408;
    room_save_state[153] := word_address(room_save_state[151]) - word_address(room_actors[0].words[0]);
    resume_buffer.word := room_save_state[152];
    moveleft(resume_buffer.bytes^, room_actors, room_save_state[153])
  end;
  room_controls[143] := 0;
  room_controls[138] := 0;
  room_controls[137] := 0;
  data29.words[2] := 2;
  { $0F18: reread the pointed-to value after the restore and stores. }
  caller_word.word := resume_address;
  if caller_word.value^ > 0 then
  begin
    selected_actor := data29.bytes[550];
    with room_actors[selected_actor] do
    begin
      if (selected_actor > 1) and (caller_word.value^ > 15) and data29.flags82[49] then
      begin
        room_layout_state[123] := selected_actor;
        random_value := random_word;
        if odd(random_value) then redirect_room_actor(room_layout_state[123]);
        if not flags.bit5 then send_actor_to_exit(room_layout_state[123])
      end;
      if selected_actor <> 1 then
      begin
        split8.low := data29.bytes[549];
        flags.bit1 := data29.bytes[552] <> 0
      end
    end;
    if odd(room_controls[136]) and data29.flags82[65] then
    begin
      active_station := random_between(1, 4);
      set_service_indicator(active_station, true);
      data29.flags82[65] := false
    end;
    data29.flags82[48] := false;
    data29.flags82[49] := false;
    data29.flags82[50] := false;
    data29.flags82[51] := false
  end
  else
  begin
    room_controls[142] := ord(venue_kind = 16);
    room_layout_state[124] := 0;
    room_layout_state[123] := 0;
    room_layout_state[117] := data29.words[351];
    room_layout_state[112] := data29.words[353];
    data29.words[353] := 30;
    data29.words[351] := 1;
    active_station := 0;
    data29.flags82[57] := false;
    flag_index := 64;
    while flag_index <= 71 do
    begin
      data29.flags82[flag_index] := false;
      flag_index := flag_index + 1
    end;
    prepare_room_scene;
    seed_room_actors
  end;
  selected_actor := 0;
  room_layout_state[116] := 0;
  room_controls[141] := 0;
  caller_word.word := resume_address;
  caller_word.value^ := 0;
  initialize_pointer(room_controls[134], room_controls[133], 2, data29.bounds11)
end;
