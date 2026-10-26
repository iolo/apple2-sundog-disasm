{ game_16 procedure9, $0216..$0227, attributes $0232.
  Nested in8: write its shared roll at slot8 only after MOD100, then read
  that stored value for the comparison. One local holds the native result. }
function roll_dialog_chance(percent: integer): boolean;
var
  chance_draw: integer;
begin
  chance_draw := random_word;
  percent_roll := chance_draw mod 100;
  roll_dialog_chance := percent_roll < percent
end;
