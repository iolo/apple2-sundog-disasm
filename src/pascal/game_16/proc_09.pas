{ game_16 procedure9, $0216..$0227, attributes $0232.
  Nested in8: write its shared roll at slot8 only after MOD100, then read
  that stored value for the comparison. One local holds the native result. }
function proc16_9(percent: integer): boolean;
var
  drawn: integer;
begin
  drawn := proc22_3;
  roll := drawn mod 100;
  proc16_9 := roll < percent
end;
