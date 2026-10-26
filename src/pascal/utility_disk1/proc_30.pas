{ utility_disk1:30 $101E..$115B, attributes$1166. Five local words:
  1 choice,2 bottom,3 row,4 right,5 left. Confirmation is choice=1 only;
  retain the points warning at >=8 and always close the window afterward. }
procedure util1_30;
var
  choice: integer;
  bottom: integer;
  row: integer;
  right: integer;
  left: integer;
begin
  proc22_51(20, 12);
  proc22_48('Strength:    ');
  proc22_49(data29.bytes[94], 3, false);
  proc22_45;
  proc22_48('Intelligence:');
  proc22_49(data29.bytes[95], 3, false);
  proc22_45;
  proc22_48('Dexterity:   ');
  proc22_49(data29.bytes[96], 3, false);
  proc22_45;
  proc22_48('Charisma:    ');
  proc22_49(data29.bytes[97], 3, false);
  proc22_45;
  proc22_48('Luck:        ');
  proc22_49(data29.bytes[98], 3, false);
  proc22_45;
  proc22_48('Points left: ');
  proc22_49(attrwork.words[8], 3, false);
  proc22_45;
  if attrwork.words[8] >= 8 then proc22_48('||Don''t waste! `');
  left := 4;
  right := data29.words[13] - data29.words[14] - 4;
  bottom := data29.words[11] - data29.words[12] - 3;
  row := bottom - 25;
  proc25_2;
  proc25_3(1, 'All done', left, right, row, row + 10);
  row := row + 15;
  proc25_3(2, 'Adjust', left, right, row, row + 10);
  proc26_5(choice, 0);
  attrwork.words[35] := ord(choice = 1);
  proc22_52
end;
