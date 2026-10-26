{ game_18 procedure 20, $0E0C..$0EA5, attributes $0EB0.
  Selects the four-block buffer path or the table/grid setup path. }
procedure prepare_room_scene;
var
  secondpos, firstpos: integer;
  buffer, argaddr: address16;
begin
  if venue_kind = 16 then
  begin
    buffer.word := 6144;
    disk_blocks_io(6144, 4, data29.words[32] + 8, true);
    argaddr.word := window_x_address;
    firstpos := argaddr.value^ - 10;
    clamp_word(1, firstpos, 19);
    argaddr.word := window_y_address;
    secondpos := argaddr.value^ * 8 - 48;
    clamp_word(8, secondpos, 88);
    set_window_image_origin(secondpos, firstpos);
    data29.words[20] := 1;
    window_image_transfer(1);
    buffer.bytes^[2000] := firstpos;
    buffer.bytes^[2001] := secondpos;
    set_text_window(firstpos * 7 + 2, firstpos * 7 + 137,
              secondpos + 2, secondpos + 93);
    room_left := data29.words[14];
    room_layout_state[130] := data29.words[13];
    room_layout_state[129] := data29.words[12];
    room_layout_state[128] := data29.words[11]
  end
  else
  begin
    load_room_layout;
    if odd(room_controls[139]) then paint_room_counter
    else if odd(room_controls[136]) then paint_service_stations
  end
end;
