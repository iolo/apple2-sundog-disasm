{ utility_disk1:13 $033A..$0388, attributes$0396, nested in9.
  Locals1 index,2 limit,3 pointer. Clear bit15 of planet word7; reroll word6's
  low byte until its distance from parent word9 exceeds15. The first prior
  value is not initialized here. Byte arithmetic retains the16-byte stride. }
procedure seed_planet_rows;
var
  planet_index: integer;
  limit: integer;
  selected: utilwork;
begin
  planet_index := 1;
  limit := 18;
  while planet_index <= limit do
  begin
    selected.word := data29.words[24] + (planet_index - 1) * 16;
    selected.planet^.words[7] := selected.planet^.words[7] and 32767;
    repeat
      selected.planet^.bytes[12] := random_between(0, 255)
    until word_abs(selected.planet^.bytes[12] - new_game_frame.prior_planet_byte) > 15;
    new_game_frame.prior_planet_byte := selected.planet^.bytes[12];
    planet_index := planet_index + 1
  end
end;
