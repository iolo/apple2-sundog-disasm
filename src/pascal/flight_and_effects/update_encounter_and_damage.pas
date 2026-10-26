{ library_24 procedure13, $0690..$0A8D, attributes $0AAA.
  Retains the original damage-loop variable reuse and effectful call order.
  Byte offsets are relative to DATASEG29, whose word90 starts at byte178. }
procedure update_encounter_and_damage;
var
  base: integer;
  offset: integer;
  group: integer;
  column: integer;
  saved: integer;
  work: integer;
  before: integer;
  randomv: integer;
  testflag: boolean;
  savedflag: boolean;
begin
  if (data29.target_range > 128) or (data29.target_hull = 0) then begin
    data29.flags82[40] := false;
    if data29.nibbles45[2] >= 2 then begin
      move_pen(32, 103);
      set_glyph_mode(0);
      draw_glyph(32);
      set_glyph_mode(1)
    end else apply_bounds(data29.bnd303, 5)
  end;
  saved := data29.target_hull;
  if (data29.target_motion_ticks > 0) and (data29.nibbles45[2] <> 1) then begin
    before := data29.words[206];
    data29.words[206] := word_and(before + left_shift_word(data29.words[209], 3), 1023);
    before := data29.words[205];
    data29.words[205] := word_and(before + left_shift_word(data29.words[208], 3), 1023);
    before := data29.target_range;
    data29.target_range := before + left_shift_word(data29.words[207], 2);
    if data29.target_range < 5 then data29.target_range := 5;
    data29.target_motion_ticks := data29.target_motion_ticks - 4
  end else if data29.target_motion_ticks <= 0 then begin
    perturb_target_velocity(data29.words[209]);
    perturb_target_velocity(data29.words[208]);
    { $075C..$0786: both random-producing calls always execute. }
    testflag := saved < random_between(20, 80);
    testflag := testflag or (data29.loc73.mid5 > 0);
    savedflag := data29.flags82[12];
    randomv := random_word;
    testflag := testflag or (savedflag and odd(randomv)) or data29.flags82[29];
    if testflag then begin
      data29.words[207] := 2;
      data29.target_motion_ticks := 130;
      data29.flags82[44] := false;
      data29.flags82[29] := false;
      if data29.flags82[12] then data29.flags82[46] := true
    end else begin
      work := right_shift_word(data29.bytes[371] + 40, 1);
      if data29.target_range < 40 then data29.words[207] := 1
      else if data29.target_range >= work then data29.words[207] := -1
      else begin
        randomv := random_word;
        data29.words[207] := word_and(randomv, 1) - 1
      end;
      if data29.words[207] < 0 then
        data29.target_motion_ticks := data29.target_range - 10
      else begin
        randomv := random_word;
        data29.target_motion_ticks := randomv mod (work - data29.target_range);
        data29.bytes[371] := work
      end;
      if data29.target_class = 0 then begin
        data29.words[207] := left_shift_word(data29.words[207], 1);
        data29.target_motion_ticks := right_shift_word(data29.target_motion_ticks, 1)
      end
    end
  end;
  { $084C: processing a pending event and scheduling one are distinct paths. }
  if data29.flags82[45] then begin
    data29.flags82[45] := false;
    data29.flags82[43] := true;
    before := data29.target_range;
    testflag := before < random_between(15, 70);
    randomv := random_word;
    if testflag and odd(randomv) then begin
      if data29.nibbles45[2] = 1 then begin
        apply_bounds(data29.bnd343, 3);
        apply_bounds(data29.bnd343, 3)
      end;
      randomv := random_word;
      work := 1 + word_and(randomv, 3);
      offset := left_shift_word(data29.target_class, 1);
      work := left_shift_word(work, offset + 9);
      if work <= 0 then work := 32767;
      work := work div data29.target_range;
      if work <= data29.shield_charge then begin
        play_sound(5, 50, 50, 0, 0, 0, 1);
        data29.shield_charge := data29.shield_charge - work
      end else begin
        play_sound(5, 80, 50, 0, 0, 0, 1);
        work := work - data29.shield_charge;
        data29.shield_charge := 0;
        { $08FD: execute at least once; work is also the selected byte below. }
        repeat
          randomv := random_word;
          group := word_and(randomv, 7);
          if group = 7 then group := 6;
          base := 28 * group;
          if data29.bytes[178 + base + 24] = 0 then group := 6;
          { $0922 changes group only: deliberately do not recompute base. }
          if group = 6 then begin
            before := data29.bytes[178 + base + 24];
            randomv := random_word;
            offset := before - (randomv mod 3 + 1);
            if offset <= 0 then begin
              offset := 0;
              work := 0;
              data29.words[347] := 1;
              apply_bounds(data29.bounds7, 3);
              use_linear_row_tables(true);
              apply_bounds(data29.bounds3, 3);
              use_linear_row_tables(false);
              data29.nibbles45[2] := 12
            end;
            data29.bytes[178 + base + 24] := offset
          end else begin
            column := data29.bytes[178 + base + 27];
            randomv := random_word;
            offset := 5 * word_and(randomv, 3);
            if data29.bytes[178 + base + offset + column] <>
               data29.bytes[178 + base + 26] then begin
              randomv := random_word;
              column := word_and(randomv, 3)
            end;
            offset := offset + column;
            work := data29.bytes[178 + base + offset];
            if work = 23 then begin
              column := base;
              repeat
                testflag := data29.bytes[178 + column] = 23;
                randomv := random_word;
                if testflag and odd(randomv) then
                  data29.bytes[178 + column] := 23 + 128;
                column := column + 1
              until column = base + 20
            end;
            if (work > 7) and (work < 128) then begin
              data29.bytes[178 + base + 25] := offset;
              data29.bytes[178 + base + offset] := work + 128;
              recompute_component_group(group)
            end
          end;
          work := work - 512
        until work <= 0
      end;
      draw_vertical_gauge(data29.shield_gauge_bounds, data29.shield_charge, 4, 5)
    end
  end else if data29.flags82[44] and not data29.flags82[12] then begin
    before := data29.target_range;
    testflag := before < random_between(15, 70);
    randomv := random_word;
    data29.flags82[45] := testflag and odd(randomv)
  end;
  { $0A51: independent phase signal, then restore the saved word216. }
  if not data29.flags82[2] and (data29.words[352] = 2) then begin
    play_sound(15, 150, 20, 253, 0, 0, 0);
    if data29.nibbles45[2] >= 2 then begin
      move_pen(32, 103);
      set_glyph_mode(1);
      draw_glyph(42)
    end
  end;
  data29.target_hull := saved
end;
