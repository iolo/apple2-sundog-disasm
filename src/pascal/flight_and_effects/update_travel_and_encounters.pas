{ library_24 procedure12, $02B4..$0676, attributes $068E.
  Movement/arrival and conditional encounter state update. Extra scalar
  temporaries preserve loads before effectful calls. No inferred host model. }
procedure update_travel_and_encounters(var amount: integer);
var
  temp: integer;
  newsec: integer;
  newfirst: integer;
  midsec: integer;
  midfirst: integer;
  oldsec: integer;
  index: integer;
  eligible: boolean;
  drawflag: boolean;
  phase: integer;
  randomv: integer;
  threshold: integer;
  tableptr: tableaddr;
begin
  if data29.flags82[1] then begin
    { $02BE: phase is loaded before random; the byte threshold after it. }
    phase := data29.words[352];
    randomv := random_word;
    randomv := word_and(randomv, 15);
    if odd(phase) and (randomv < data29.bytes[230]) then begin
      drawflag := data29.flags82[5] and (data29.map_view_kind = 2) and
                  (data29.map_object_id = data29.loc73.low4);
      if drawflag then begin
        midfirst := right_shift_word(data29.words[345] + data29.words[346], 1);
        midsec := right_shift_word(data29.words[343] + data29.words[344], 1);
        apply_bounds(data29.bnd343, 0);
        project_polar_point(data29.bytes[142], data29.bytes[143], index, oldsec)
      end;
      { $0332: advance packed coordinates only in mode 2. }
      if data29.travel_kind = 2 then begin
        data29.travel_progress := data29.travel_progress + 1;
        data29.bytes[143] := data29.travel_progress * data29.radial_delta div
                             data29.travel_span + data29.start_radius;
        temp := data29.travel_progress * data29.heading_delta div
                data29.travel_span + data29.start_heading;
        if temp < 0 then data29.bytes[142] := 256 + temp
        else data29.bytes[142] := word_and(temp, 255)
      end;
      if drawflag then begin
        project_polar_point(data29.bytes[142], data29.bytes[143], newfirst, newsec);
        if (index <> newfirst) or (oldsec <> newsec) or
           (data29.travel_progress = data29.travel_span) then begin
          set_glyph_mode(1);
          move_pen(index + midfirst - 3, oldsec + midsec + 3);
          draw_glyph(data29.words[294]);
          move_pen(newfirst + midfirst - 3, newsec + midsec + 3);
          draw_glyph(data29.words[294]);
          if data29.travel_progress = data29.travel_span then begin
            move_pen(newfirst + midfirst - 3, newsec + midsec + 3);
            if data29.loc67.mid5 = 0 then draw_glyph(43)
            else draw_glyph(data29.words[297])
          end
        end
      end
    end;
    { $0416: independent of whether this tick moved/drew anything. }
    if data29.words[352] = 3 then amount := amount - 1;
    if data29.travel_progress = data29.travel_span then begin
      data29.rec72 := data29.rec66;
      index := data29.words[40];
      oldsec := data29.bytes[80];
      data29.rec36 := data29.rec66;
      data29.words[40] := index;
      data29.bytes[80] := oldsec;
      if data29.flags82[7] then data29.rec228 := data29.rec66;
      for index := 1 to 3 do begin
        play_sound(1, 200, 50, 0, 0, 0, 0);
        play_sound(25, 0, 25, 0, 0, 10, 0)
      end;
      data29.flags82[1] := false;
      if data29.flags82[40] then data29.target_motion_ticks := 0;
      data29.travel_kind := 0;
      if odd(data29.words[349]) then data29.words[350] := 1
    end;
    { $04BA: still runs after arrival clears flag 1. }
    eligible := not (data29.flags82[40] or data29.flags82[12] or
                     data29.flags82[36]);
    if eligible then begin
      eligible := data29.loc73.mid5 = 0;
      randomv := random_word;
      randomv := word_and(randomv, 15);
      eligible := eligible and (randomv = 13)
    end;
    if eligible then begin
      eligible := false;
      for index := 1 to 2 do
        eligible := eligible or ((data29.stock234[index].kind > 1) and
                                  (data29.stock234[index].kind < 31))
    end;
    if eligible then begin
      tableptr := data29.tbl23;
      { WITH captures the selected row once, as local11 does at $053B. }
      with tableptr.rows^[data29.loc73.low4] do begin
        eligible := false;
        threshold := nibbles8[3];
        randomv := random_word;
        randomv := word_and(randomv, 15);
        if threshold <= randomv then begin
          threshold := nibbles8[7];
          randomv := random_word;
          randomv := word_and(randomv, 7);
          if threshold <= randomv then eligible := true
          else nibbles8[7] := nibbles8[7] - 1
        end
      end
    end;
    if eligible then begin
      randomv := random_word;
      data29.target_class := word_and(randomv, 3);
      data29.flags82[40] := true;
      data29.flags82[41] := true;
      data29.flags82[44] := true;
      data29.flags82[45] := false;
      data29.flags82[46] := false;
      data29.flags82[47] := false;
      data29.target_range := 127;
      data29.bytes[371] := data29.target_range;
      randomv := random_word;
      data29.words[206] := word_and(randomv, 1023);
      randomv := random_word;
      data29.words[205] := word_and(randomv, 1023);
      data29.target_hull := random_between(150, 255);
      data29.words[209] := 0;
      data29.words[208] := 0;
      data29.words[207] := -1;
      data29.target_motion_ticks := 40;
      apply_bounds(data29.bnd303, 9)
    end;
    { $0629: final display update does not depend on encounter eligibility. }
    if data29.loc73.mid5 > 0 then index := 0
    else index := left_shift_word(data29.bytes[143] + 7, 1);
    if data29.words[309] > 0 then begin
      set_glyph_mode(3);
      apply_bounds(data29.bnd307, 0);
      move_pen(data29.words[310] + 2, data29.words[307]);
      draw_integer(index, 3, true);
      apply_bounds(data29.bounds7, 0)
    end
  end
end;
