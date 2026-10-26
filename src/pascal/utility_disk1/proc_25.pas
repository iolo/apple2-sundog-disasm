{ utility_disk1:25 $0B4A..$0CFB, attributes$0D08. Four local words:
  1 x,2 y,3 index,4 loop limit. Initialize each attribute to30, then overwrite
  luck with0. Keep display reads after the corresponding text calls. }
procedure util1_25;
var
  x: integer;
  y: integer;
  index: integer;
  limit: integer;
begin
  proc22_44;
  proc22_48('||Attribute setting\|\');
  proc22_48('-- Select attribute with cursor\|\');
  proc22_48('-- Use arrows to raise or lower\|\');
  proc22_48('-- Press button 1 when done');
  util1_5(9000);
  proc22_44;
  proc22_48('Strength     (S');
  attrwork.words[6] := data29.words[19];
  attrwork.words[5] := data29.words[18];
  proc22_48('T):\|');
  x := data29.words[19];
  y := data29.words[18];
  proc22_45;
  proc22_48('Intelligence (IQ):\|\');
  proc22_48('Dexterity    (DX):\|\');
  proc22_48('Charisma     (CH):\|\');
  proc22_48('Luck         (LK):');
  proc22_45;
  proc22_45;
  proc22_48('Points: ');
  index := 0;
  limit := 4;
  while index <= limit do
  begin
    data29.bytes[94 + index] := 30;
    if index = 4 then data29.bytes[94 + index] := 0;
    proc22_18(attrwork.bars[index], x, x + 100, y - 6, y - 2);
    y := y + 16;
    util1_23(index, 10);
    index := index + 1
  end;
  attrwork.words[8] := 440;
  proc22_18(attrwork.points, data29.words[19], data29.words[19] + 55,
            data29.words[18] - 6, data29.words[18] - 2);
  util1_24;
  attrwork.words[35] := 0
end;
