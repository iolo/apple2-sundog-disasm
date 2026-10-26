{ utility_disk1:17 $0650..$0674, attributes$067E, nested in9.
  Four unused local bytes. Initialize systems, planets, templates, inventory
  in that order; write the same three-block table to both original locations. }
procedure util1_17;
var unused: array[1..2] of integer;
begin
  util1_12;
  util1_13;
  util1_14;
  util1_16;
  proc22_53(-5887, 3, data29.words[30] + 1, false);
  proc22_53(-5887, 3, initwork.words[2] + 7, false)
end;
