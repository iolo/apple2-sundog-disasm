{ game_16 procedure30, $0E4E..$0E62, attributes $0E6C. }
procedure tick_dialog_clock;
begin
  if data29.nibbles45[1] < 3 then data29.words[354] := 0
  else advance_clock_and_conditions
end;
