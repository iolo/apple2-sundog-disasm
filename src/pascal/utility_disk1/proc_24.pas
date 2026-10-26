{ utility_disk1:24 $0AF6..$0B3E, attributes$0B48. One local word.
  Display the points bar at rounded-up one-eighth scale. }
procedure util1_24;
var width: integer;
begin
  proc22_19(attrwork.points, 8);
  if attrwork.words[8] > 0 then
  begin
    width := (attrwork.words[8] + 7) div 8;
    proc22_14(attrwork.words[32], attrwork.words[32] + width,
              attrwork.words[30], attrwork.words[29]);
    proc22_7(10)
  end;
  proc22_19(data29.bounds11, 0);
  proc22_12(attrwork.words[31] + 9, attrwork.words[29] + 3);
  proc22_39(attrwork.words[8], 3, false)
end;
