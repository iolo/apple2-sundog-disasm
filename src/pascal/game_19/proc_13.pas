{ game_19 procedure13, $06C8..$0703, attributes $070C; nested in12.
  Parent work at24 selects city/planet/system; placename occupies8..15. }
procedure proc19_13(caption: text15; placeidx: integer);
var
  row: integer;
begin
  proc19_8(work, placeidx, placename);
  row := 5 + 2 * work;
  proc22_46(0, row);
  proc22_48(caption);
  proc22_46(22 - length(placename), row);
  proc22_48(placename);
  work := work + 1
end;
