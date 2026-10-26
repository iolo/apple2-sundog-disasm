{ game_21 procedure31, $15B0..$1673, attributes $1682.
  Six XOR rectangle steps. The delay path retains its45-iteration empty loop;
  the sound path preserves sign and argument order on the two directions. }
procedure pulse_teleport_box(xpos, ypos: integer; expanding, quiet: boolean);
var
  delay_index, frame_index, left_byte_column, right_byte_column, top, bottom: integer;
begin
  clamp_word(42, xpos, 231);
  clamp_word(30, ypos, 161);
  xpos := xpos div 7;
  if expanding then
  begin
    left_byte_column := xpos - 1;
    right_byte_column := xpos + 1;
    top := ypos - 5;
    bottom := ypos + 5
  end
  else
  begin
    left_byte_column := xpos - 6;
    right_byte_column := xpos + 6;
    top := ypos - 30;
    bottom := ypos + 30
  end;
  frame_index := 1;
  while frame_index <= 6 do
  begin
    xor_map_rectangle(left_byte_column, right_byte_column, top, bottom);
    if expanding then
    begin
      left_byte_column := left_byte_column - 1;
      right_byte_column := right_byte_column + 1;
      top := top - 5;
      bottom := bottom + 5
    end
    else
    begin
      left_byte_column := left_byte_column + 1;
      right_byte_column := right_byte_column - 1;
      top := top + 5;
      bottom := bottom - 5
    end;
    if quiet then
    begin
      delay_index := 1;
      while delay_index <= 45 do delay_index := delay_index + 1
    end
    else if expanding then play_sound(4, (8 - frame_index) * 34, 8, -8, 0, 1, 0)
    else play_sound(4, (frame_index + 1) * 34, 8, 8, 0, 1, 0);
    frame_index := frame_index + 1
  end
end;
