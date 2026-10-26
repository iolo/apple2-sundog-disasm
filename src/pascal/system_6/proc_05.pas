{ system6:5 $0C72..$0DFE, attributes$0E16. VAR file2, mode1; locals
  3 duplicate index,4 index,5 directory,6 found,7 file view,8 entry pointer.
  Eligibility compares the current buffer word with ancestor file7's buffer.
  Preserve mode3's pre-flush edits, full-word date copies, duplicate deletion
  and index adjustment, and the raw flag OR tests. Errors5/6 jump straight
  to final flags; a deleted entry jumps straight to the directory write.
  Nonlocal EXIT targets$0DFE, after all local close/cleanup operations. }
procedure sys6_5(var f: integer; mode: integer);
label 800, 900;
var
  dupidx: integer;
  index: integer;
  cache: s6cache;
  found: boolean;
  view: s6fview;
  entry: s6eptr;
begin
  sy6e.state^.words[0] := 0;
  view.word := @f;
  if odd(view.fileptr^.words[5] and
         ord(view.fileptr^.words[0] <> sy6e.file7^.words[0])) then
  begin
    if odd(view.fileptr^.words[6]) then
    begin
      entry := @view.rich^.entry16;
      if length(entry^.caption) > 0 then
      begin
        if mode = 3 then
        begin
          view.fileptr^.words[12] := view.fileptr^.words[13];
          entry^.date12.high7 := 100;
          mode := 1;
          if odd(view.fileptr^.words[29]) then
            view.fileptr^.words[30] := view.fileptr^.words[31]
        end;
        sys6_13(f);
        if odd(view.fileptr^.words[15] or ord(entry^.date12.high7 = 100) or
               ord(mode = 2)) then
        begin
          if view.fileptr^.words[7] <>
               sys6_6(view.rich^.volume8, 0, cache.header) then
          begin
            sy6e.state^.words[0] := 5;
            goto 900
          end;
          index := 1;
          found := false;
          while odd(ord(index <= cache.directory^[0].words[8]) and
                    (not ord(found))) do
          begin
            found := odd(ord(cache.directory^[index].words[0] = entry^.words[0])
                         and ord(cache.directory^[index].words[1] =
                                 entry^.words[1]));
            index := index + 1
          end;
          if not found then
          begin
            sy6e.state^.words[0] := 6;
            goto 900
          end;
          index := index - 1;
          if odd((ord(mode = 0) and
                  ord(cache.directory^[index].date12.high7 = 100)) or
                 ord(mode = 2)) then
          begin
            sys6_8(index, cache.directory);
            goto 800
          end;
          dupidx := sys6_12(entry^.caption, 1, cache.directory);
          if odd(ord(dupidx <> 0) and ord(dupidx <> index)) then
          begin
            sys6_8(dupidx, cache.directory);
            if dupidx < index then index := index - 1
          end;
          if cache.directory^[index].date12.high7 = 100 then
          begin
            if entry^.date12.high7 = 100 then entry^.words[12] := sy6e.words[18]
          end
          else if odd(view.fileptr^.words[15] and
                      ord((sy6e.words[18] and 15) <> 0)) then
            entry^.words[12] := sy6e.words[18]
          else entry^.words[12] := cache.directory^[index].words[12];
          entry^.words[1] := entry^.words[0] + view.fileptr^.words[12];
          if odd(view.fileptr^.words[29]) then
            entry^.words[11] := view.fileptr^.words[30];
          view.rich^.entry16.kind2.spare := 0;
          view.fileptr^.words[15] := 0;
          cache.directory^[index] := view.rich^.entry16;
800:
          sys6_10(view.fileptr^.words[7], cache.directory)
        end
      end
    end;
    if mode = 2 then
      if length(view.rich^.entry16.caption) = 0 then
        sy6e.units31[view.fileptr^.words[7]].caption := '';
900:
    view.fileptr^.words[2] := 1;
    view.fileptr^.words[1] := 1;
    view.fileptr^.words[5] := 0
  end
end;
