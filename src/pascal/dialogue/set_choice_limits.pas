{ game_16 procedure25, $0994..$099C, attributes $09A6; nested in24. }
procedure set_choice_limits(start_level, stop_index: integer);
begin
  level_threshold := start_level;
  choice_limit := stop_index
end;
