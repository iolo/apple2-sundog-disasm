{ game_18 procedure 16, $0B78..$0CC3, attributes $0CCE.
  Parent slots 4/3 are addresses consumed here. The unrecovered parent keeps
  raw-word parameter declarations; address16 supplies explicit local views.
  The setup table is loaded at byte address $4000, with a 16-word stride. }
procedure load_room_layout;
var
  layout_table: setupaddr;
  layout_index: integer;
  decoded_bounds: bounds4;
  caller_word: address16;
  window_x, window_y: integer;
(*$include src/pascal/building_interiors/unpack_room_bounds.pas*)
begin
  caller_word.word := window_x_address;
  window_x := caller_word.value^;
  caller_word.word := window_y_address;
  window_y := caller_word.value^;
  push_text_window(window_x, window_y);
  layout_table.word := 16384;
  disk_blocks_io(16384, 1, data29.words[27], true);
  data29.flags82[116] := false;
  if venue_kind = 11 then layout_index := 1
  else
    { $0BA8..$0BBF: byte loads and MOD expose the low 6 and low 5 bits.
      Both byte values are unsigned, so MOD agrees with the packed masks. }
    layout_index := 4 * (venue_kind - 7) +
                ((data29.bytes[74] mod 64) +
                 (data29.bytes[76] mod 32)) mod 4;
  with layout_table.table^[layout_index] do
  begin
    { $0BC1..$0C00: retain the table-entry pointer across drawing calls. }
    room_background_pattern := modes.high8;
    on_station_pattern := modes.next4;
    off_station_pattern := modes.low4;
    apply_bounds(data29.bounds11, modes.high8);
    unpack_room_bounds(bounds[4], modes.next4, decoded_bounds);
    room_left := decoded_bounds.lower_first;
    room_layout_state[130] := decoded_bounds.upper_first;
    room_layout_state[129] := decoded_bounds.lower_second;
    room_layout_state[128] := decoded_bounds.upper_second;
    unpack_room_bounds(bounds[3], modes.next4, decoded_bounds);
    unpack_room_bounds(bounds[2], modes.low4, decoded_bounds);
    unpack_room_bounds(bounds[1], 0, room_walk_bounds);
    unpack_room_bounds(bounds[0], 0, decoded_bounds);
    room_layout_state[127] := decoded_bounds.lower_first;
    room_layout_state[126] := decoded_bounds.lower_second;
    room_layout_state[121] := decoded_bounds.upper_first;
    room_layout_state[120] := decoded_bounds.upper_second;
    room_controls[140] := ord(word_abs(room_walk_bounds.lower_first -
                                 room_walk_bounds.upper_first) > 4);
    room_layout_state[115] := bytes11[0] - 128;
    room_layout_state[114] := bytes11[1] - 128;
    room_layout_state[113] := bytes11[2];
    if room_layout_state[113] < 3 then room_layout_state[113] := 3;
    room_layout_state[122] := bytes11[3];
    if room_layout_state[122] <= 0 then room_layout_state[122] := 128;
    actor_count := random_between(3, room_layout_state[113]);
    room_controls[139] := ord(venue_kind = 8);
    room_controls[136] := ord(venue_kind = 11);
    apply_bounds(data29.bounds11, 0)
  end
end;
