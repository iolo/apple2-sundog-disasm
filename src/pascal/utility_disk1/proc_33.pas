{ utility_disk1:33 $1258..$1345, attributes$1350, nested in31.
  Locals1 unused,2 x,3 y. Preserve full bounds save and setup order. }
procedure util1_33;
var
  unused: integer;
  x: integer;
  y: integer;
begin
  namework.saved156 := data29.bounds11;
  proc22_44;
  proc22_48('Spell character name\|using cursor\Button 1 deletes\');
  proc22_48('Press + when done');
  y := data29.words[11];
  x := data29.words[14] + 2;
  util1_32(0, x, y - 24, 'abcdefghij');
  util1_32(1, x, y - 12, 'klmnopqrst');
  util1_32(2, x, y - 0, 'uvwxyz ` +');
  namework.name161 := '';
  namework.length171 := 0;
  namework.shift170 := 0;
  proc22_18(namework.cursor152, data29.words[14] + 4, data29.words[14] + 133,
              data29.words[11] - 36, data29.words[11] - 4);
  proc22_50(data29.words[14], data29.words[13],
              data29.words[11] - 52, data29.words[11] - 40);
  namework.unused160 := 1
end;
