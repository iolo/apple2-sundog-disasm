{ game_16 procedure24, $09A8..$0A92, attributes $0AA2.
  Nested25 sets the original limit/threshold slots2/3. Preserve the inclusive
  counted scan, all discarded byte reads, cached random choice, and the final
  conditionless alternative. A chosen alternative still consumes later bytes. }
procedure select_dialog_alternative(var target: integer);
var
  choice_limit: integer;
  level_threshold: integer;
  candidate_id: integer;
  choice_index: integer;
  choice_kind: integer;
  direct_table: boolean;
  choice_set: boolean;
  last_choice: integer;
(*$include src/pascal/dialogue/set_choice_limits.pas*)
begin
  choice_set := false;
  choice_kind := target;
  direct_table := true;
  if (choice_kind = 22) or (choice_kind = 23) then
  begin
    choice_kind := choice_kind - 2;
    direct_table := false
  end;
  if (choice_kind = 21) or (choice_kind = 20) then
  begin
    if direct_table then
    begin
      if choice_kind = 21 then
      begin
        read_dialog_byte(target);
        choice_set := not odd(g16.words[20])
      end;
      set_choice_limits(2, 2)
    end
    else if choice_kind = 21 then set_choice_limits(3, 3)
    else set_choice_limits(2, 2);
    choice_index := 0;
    last_choice := choice_limit;
    while choice_index <= last_choice do
    begin
      if choice_set then read_dialog_byte(candidate_id)
      else
      begin
        read_dialog_byte(target);
        choice_set := g16.response_level >= level_threshold;
        level_threshold := level_threshold - 1
      end;
      choice_index := choice_index + 1
    end
  end
  else if choice_kind <= 10 then
  begin
    if odd(g16.reuse_choice) then choice_index := g16.cached_choice
    else
    begin
      choice_index := random_word;
      choice_index := choice_index mod target
    end;
    g16.reuse_choice := 0;
    g16.cached_choice := choice_index;
    while choice_kind > 0 do
    begin
      read_dialog_byte(candidate_id);
      if choice_index = 0 then target := candidate_id;
      choice_index := choice_index - 1;
      choice_kind := choice_kind - 1
    end
  end
  else
  begin
    choice_kind := choice_kind - 10;
    repeat
      read_dialog_byte(candidate_id);
      choice_kind := choice_kind - 1;
      if choice_kind > 0 then read_dialog_byte(level_threshold) else level_threshold := 0;
      if not choice_set then
      begin
        choice_set := odd(test_dialog_condition(level_threshold));
        if choice_set then target := candidate_id
      end
    until choice_kind <= 0
  end
end;
