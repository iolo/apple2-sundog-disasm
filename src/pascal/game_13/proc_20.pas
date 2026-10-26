{ game_13 procedure20, $0C9E..$0D47, attributes $0D52; nested in19.
  Capture the system-row address before printing; location comparison uses
  word37, not word73. Captions retain all original spaces. }
procedure proc13_20(systemid: integer);
var
  distance: integer; {2}
  row: g13rowptr;    {3}
begin
  row.word := data29.words[23] + 20 * (systemid - 1);
  proc22_48('System:    ');
  proc22_48(row.caption^);
  proc22_45;
  if systemid = data29.loc37.low4 then proc22_48('(current location)')
  else
  begin
    proc22_48('Distance:  ');
    distance := proc24_6(systemid, data29.loc37.low4);
    proc22_49(distance, 2, false);
    proc22_48(' j-secs');
    if (systemid = data29.words[221]) and data29.flags82[0] then
      proc22_48('  (current destination)')
  end;
  proc22_45
end;
