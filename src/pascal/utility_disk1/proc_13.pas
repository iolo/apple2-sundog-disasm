{ utility_disk1:13 $033A..$0388, attributes$0396, nested in9.
  Locals1 index,2 limit,3 pointer. Clear bit15 of planet word7; reroll word6's
  low byte until its distance from parent word9 exceeds15. The first prior
  value is not initialized here. Byte arithmetic retains the16-byte stride. }
procedure util1_13;
var
  index: integer;
  limit: integer;
  selected: utilwork;
begin
  index := 1;
  limit := 18;
  while index <= limit do
  begin
    selected.word := data29.words[24] + (index - 1) * 16;
    selected.planet^.words[7] := selected.planet^.words[7] and 32767;
    repeat
      selected.planet^.bytes[12] := proc22_40(0, 255)
    until proc22_35(selected.planet^.bytes[12] - initwork.words[9]) > 15;
    initwork.words[9] := selected.planet^.bytes[12];
    index := index + 1
  end
end;
