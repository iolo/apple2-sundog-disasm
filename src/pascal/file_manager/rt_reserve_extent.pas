{ system6:14 $0876..$0962, attributes$0970, nested in4. Result1,
  directory3,kind4,blocks5,VAR name6. Locals7 runner-up cursor,8 best cursor,
  9 count,10 cursor,11 halve,12 runner-up size,13..25 newent,26 limit.
  Nonpositive requests search largest gaps; an initially negative request
  selects the runner-up if at least half as large, otherwise rounds half up.
  Positive requests take the first fitting gap. Count77 forbids insertion.
  Only the newkind's low four bits are initialized; preserve the other twelve
  unspecified bits and the unused bytes after the assigned newname. }
function rt_reserve_extent(var newname: text15; blocks: integer; newkind: integer;
                 directory: s6dptr): integer;
var
  runner_index: integer;
  best_index: integer;
  count: integer;
  cursor: integer;
  half_request: boolean;
  runner_size: integer;
  newent: s6entry;
  limit: integer;
(*$include src/pascal/file_manager/rt_rank_extent_gap.pas*)
begin
  best_index := 0;
  count := directory^[0].words[8];
  runner_index := 0;
  runner_size := 0;
  if blocks <= 0 then
  begin
    half_request := blocks < 0;
    cursor := 1;
    limit := count;
    while cursor <= limit do
    begin
      rt_rank_extent_gap(cursor, directory^[cursor - 1].words[1],
              directory^[cursor].words[0]);
      cursor := cursor + 1
    end;
    rt_rank_extent_gap(count + 1, directory^[count].words[1], directory^[0].words[7]);
    if half_request then
    begin
      if blocks div 2 <= runner_size then
      begin
        blocks := runner_size;
        best_index := runner_index
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
        best_index := cursor;
        cursor := count
      end;
      cursor := cursor + 1
    end;
    if best_index = 0 then
      if directory^[0].words[7] - directory^[count].words[1] >= blocks then
        best_index := count + 1
  end;
  if count = 77 then best_index := 0;
  if best_index > 0 then
  begin
    newent.words[0] := directory^[best_index - 1].words[1];
    newent.words[1] := newent.words[0] + blocks;
    newent.kind2.kind := newkind;
    newent.caption := newname;
    newent.words[11] := 512;
    newent.bits12.low4 := 0;
    newent.bits12.middle5 := 0;
    newent.bits12.high7 := 100;
    rt_add_dir_entry(newent, best_index, directory)
  end;
  rt_reserve_extent := best_index
end;
