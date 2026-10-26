{ library_22 procedure 48, $08E4..$09C4, attributes $09DA.
  The local layout retains the original 20-byte word buffer and adjacent words.
  Validation assumes runs no longer than that buffer; no truncation is added. }
procedure proc22_48(caption: text80);
var
  runcount: integer;                         { Slot 43. }
  textlen: integer;                          { Slot 44. }
  printidx: integer;                         { Slot 45. }
  cursor: integer;                           { Slot 46. }
  unused47: array[47..48] of integer;
  runbytes: packed array[0..19] of 0..255;    { Slots 49..58. }
  code: integer;                            { Slot 59. }
  done: boolean;                            { Slot 60. }
  last: integer;                            { Slot 61. }
begin
  proc22_11(3);
  textlen := length(caption);
  cursor := 1;
  while cursor <= textlen do
  begin
    code := ord(caption[cursor]);
    if code = 32 then
    begin
      if data29.words[19] > data29.words[14] + 2 then proc22_47(32);
      cursor := cursor + 1
    end
    else if code = 92 then
    begin
      if data29.words[19] > data29.words[14] + 2 then proc22_45;
      cursor := cursor + 1
    end
    else if code = 124 then
    begin
      proc22_47(32);
      cursor := cursor + 1
    end
    else
    begin
      runcount := 0;
      done := false;
      while (cursor <= textlen) and not done do
      begin
        code := ord(caption[cursor]);
        done := (code = 32) or (code = 124) or (code = 92);
        if not done then
        begin
          runcount := runcount + 1;
          runbytes[runcount - 1] := code;
          cursor := cursor + 1
        end
      end;
      printidx := runcount;
      if data29.words[19] + printidx * 6 > data29.words[17] then proc22_45;
      printidx := 1;
      last := runcount;
      while printidx <= last do
      begin
        proc22_47(runbytes[printidx - 1]);
        printidx := printidx + 1
      end
    end
  end
end;
