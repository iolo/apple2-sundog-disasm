{ utility_disk1:43 $1ADE..$1B19, attributes$1B24,512-byte local sector.
  Only clear the selected64-byte slot after confirmation. Read block80 and
  replace byte1 with low-byte(-1) iff it names the selected slot, then write.
  The stored255 preserves STB truncation; no signed byte type is introduced. }
procedure util1_43;
var sector: utilsector;
begin
  if util1_4 then
  begin
    fillchar(u1.slots[u1.words[6]], 64, 0);
    util1_7(true);
    proc22_53(proc22_24(sector.words[0]), 1, 80, true);
    if sector.bytes[1] = u1.words[6] then
    begin
      sector.bytes[1] := 255;
      proc22_53(proc22_24(sector.words[0]), 1, 80, false)
    end
  end
end;
