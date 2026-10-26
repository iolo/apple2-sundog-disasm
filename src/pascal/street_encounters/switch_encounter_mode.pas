{ game_17 procedure15, $07CE..$08C8, attributes $08D2.
  Parent args3/2/1 are caller-owned VAR integers.
  Read the original coordinates before clamping; apply case1..9 exactly.
  VAR references preserve aliasing between caller-owned outputs. }
procedure switch_encounter_mode(open_dialogue: boolean);
var
  window_direction: integer;
begin
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[0] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[2]
  end;
  g17.exit_requested := 1;
  g17.saved_x := window_x;
  g17.saved_y := window_y;
  window_direction := 5 - 3 * word_sign(window_x - 20) - word_sign(window_y - 12);
  clamp_word(10, window_x, 39);
  clamp_word(7, window_y, 23);
  case window_direction of
    1, 2, 4, 5:
      begin
        window_x := window_x - 2;
        window_y := window_y - 2
      end;
    3, 6:
      begin
        window_x := window_x - 2;
        window_y := window_y + 2
      end;
    7, 8:
      begin
        window_x := window_x + 2;
        window_y := window_y - 2
      end;
    9:
      begin
        window_x := window_x + 2;
        window_y := window_y + 2
      end
  end;
  if open_dialogue then
  begin
    data29.nibbles45[2] := 9;
    resume_selector := data29.ground_encounter_mode
  end
  else
  begin
    if not odd(data29.words[347]) then data29.nibbles45[2] := 7;
    resume_selector := 1
  end
end;
