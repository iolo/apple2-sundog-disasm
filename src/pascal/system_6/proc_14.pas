{ system6:14 $0876..$0962, attributes$0970, nested in4. Result1,
  directory3,kind4,blocks5,VAR name6. Locals7 runner-up cursor,8 best cursor,
  9 count,10 cursor,11 halve,12 runner-up size,13..25 newent,26 limit.
  Nonpositive requests search largest gaps; an initially negative request
  selects the runner-up if at least half as large, otherwise rounds half up.
  Positive requests take the first fitting gap. Count77 forbids insertion.
  Only the newkind's low four bits are initialized; preserve the other twelve
  unspecified bits and the unused bytes after the assigned newname. }
function sys6_14(var newname: text15; blocks: integer; newkind: integer;
                 directory: s6dptr): integer;
var
  nextidx: integer;
  bestidx: integer;
  count: integer;
  cursor: integer;
  halve: boolean;
  nextsz: integer;
  newent: s6entry;
  limit: integer;
(*$include src/pascal/system_6/proc_15.pas*)
begin
  bestidx := 0;
  count := directory^[0].words[8];
  nextidx := 0;
  nextsz := 0;
  if blocks <= 0 then
  begin
    halve := blocks < 0;
    cursor := 1;
    limit := count;
    while cursor <= limit do
    begin
      sys6_15(cursor, directory^[cursor - 1].words[1],
              directory^[cursor].words[0]);
      cursor := cursor + 1
    end;
    sys6_15(count + 1, directory^[count].words[1], directory^[0].words[7]);
    if halve then
    begin
      if blocks div 2 <= nextsz then
      begin
        blocks := nextsz;
        bestidx := nextidx
      end
      else blocks := (blocks + 1) div 2
    end
  end
  else
  begin
    cursor := 1;
    while cursor <= count do
    begin
      if directory^[cursor].words[0] - directory^[cursor - 1].words[1]
           >= blocks then
      begin
        bestidx := cursor;
        cursor := count
      end;
      cursor := cursor + 1
    end;
    if bestidx = 0 then
      if directory^[0].words[7] - directory^[count].words[1] >= blocks then
        bestidx := count + 1
  end;
  if count = 77 then bestidx := 0;
  if bestidx > 0 then
  begin
    newent.words[0] := directory^[bestidx - 1].words[1];
    newent.words[1] := newent.words[0] + blocks;
    newent.kind2.kind := newkind;
    newent.caption := newname;
    newent.words[11] := 512;
    newent.bits12.low4 := 0;
    newent.bits12.middle5 := 0;
    newent.bits12.high7 := 100;
    sys6_7(newent, bestidx, directory)
  end;
  sys6_14 := bestidx
end;
