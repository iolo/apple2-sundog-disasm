{ game_8 procedure17, $0944..$0ADC, attributes $0AF2.
  Local5 changes role from rest byte to item index on the later path; retain
  this reuse and the four-entry masked search even though the start is MOD3. }
procedure sleep_and_risk_theft;
var
  theft_threshold: integer;
  search_start: integer;
  item_code: integer;
  rest_phase: integer;
  rest_or_item_index: integer;
  theft_time: clock4;
  zero_cash: wordpair;
  wake_poll: integer;
  random_value: integer;
begin
  zero_cash.first := 0;
  zero_cash.second := 0;
  apply_bounds(sleep_button_bounds, 3);
  data29.bounds327 := data31.bounds6;
  apply_bounds(data29.bounds327, 8);
  rest_or_item_index := data29.bytes[119];
  data29.flags82[59] := true;
  rest_phase := 0;
  theft_time := data29.clock42;
  repeat
    data29.words[347] := 0;
    tick_personal_panel(false, false);
    rest_phase := rest_phase + 1;
    if rest_phase = 2 then begin
      if rest_or_item_index < 255 then begin
        rest_or_item_index := rest_or_item_index + 1;
        data29.bytes[119] := rest_or_item_index;
        if (rest_or_item_index + 1) mod 8 = 0 then data29.flags82[60] := true
      end;
      rest_phase := 0
    end;
    if (data29.nibbles45[2] = 10) and (rest_or_item_index > 128) then
      data29.nibbles45[2] := 7;
    wake_poll := poll_input(1)
  until odd(wake_poll) and (data29.nibbles45[2] <> 10);
  if data29.nibbles45[2] = 12 then personal_state[19] := 1
  else if data29.flags45[13] and
          ((data29.nibbles45[1] = 3) or (data29.nibbles45[1] = 5)) and
          not data29.flags82[57] then begin
    theft_threshold := data29.tbl23.rows^[data29.loc37.low4].nibbles8[3];
    add_clock_minutes(theft_time, 10 + 4 * theft_threshold);
    while clock_has_reached(theft_time) do begin
      apply_bounds(data31.bounds6, 8);
      random_value := random_word;
      random_value := word_and(random_value, 15);
      if theft_threshold < random_value then begin
        random_value := random_word;
        if odd(random_value) and ((data29.words[46] <> zero_cash.first) or
                            (data29.words[47] <> zero_cash.second)) then
          data29.money46 := zero_cash
        else begin
          random_value := random_word;
          rest_or_item_index := random_value mod 3;
          search_start := rest_or_item_index;
          repeat
            item_code := data29.bytes[122 + rest_or_item_index];
            if item_code > 0 then begin
              lift_inventory_item(1 + rest_or_item_index + data31.words[14]);
              select_drawing_buffer(0, false);
              plot_item_icon(personal_state[7], personal_state[6]);
              select_drawing_buffer(0, false);
              rest_or_item_index := search_start
            end else rest_or_item_index := word_and(rest_or_item_index + 1, 3)
          until rest_or_item_index = search_start
        end
      end;
      add_clock_minutes(theft_time, 60)
    end
  end;
  data29.flags82[59] := false;
  assign_bounds(data29.bounds327, 0, 0, 0, 0);
  write_item_caption('');
  apply_bounds(sleep_button_bounds, 3)
end;
