{ system6:10 $03A8..$0468, attributes$0472. Unit2,directory pointer1;
  locals3 low time,4 high time,5 valid,6..18 disk header,19 unit,20 header.
  Preserve both signed age comparisons and the configuration flag's low bit.
  A failed age check falls back to a26-byte read at block2. Once validated,
  write block2 and save its IORESULT; when header word1=10, write block6 too,
  even if the first write failed. The saved FIRST result alone gates TIME
  and final unit invalidation. TIME retains SunDog's zero-output CSP9 binding. }
(*$I-*)
procedure sys6_10(unitnum: integer; directory: s6dptr);
var
  low: integer;
  high: integer;
  valid: boolean;
  diskhead: s6entry;
  device: ^s4unit;
  header: s6eptr;
begin
  device := @sy6e.units31[unitnum];
  header := @directory^[0];
  valid := odd(ord(device^.caption = header^.caption) and
               (ord(header^.kind2.kind = 0) or ord(header^.kind2.kind = 8)));
  if valid then
  begin
    time(high, low);
    valid := odd(ord(low - header^.words[9] <= 300) and
                 ord(low - header^.words[9] >= 0) and sy6e.state^.words[29]);
    if not valid then
    begin
      unitread(unitnum, diskhead, 26, 2, 0);
      if ioresult = 0 then valid := header^.caption = diskhead.caption
    end;
    if valid then
    begin
      header^.words[0] := 0;
      unitwrite(unitnum, directory^, (header^.words[8] + 1) * 26, 2, 0);
      valid := ioresult = 0;
      if header^.words[1] = 10 then
        unitwrite(unitnum, directory^, (header^.words[8] + 1) * 26, 6, 0);
      if valid then time(high, header^.words[9])
    end
  end;
  if not valid then
  begin
    device^.caption := '';
    device^.word5 := 32767
  end
end;
(*$I+*)
