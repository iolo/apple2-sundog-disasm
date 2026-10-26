{ system6:4 $0972..$0C5C, attributes$0C70. VAR file4, VAR caption3,
  mode2, unused pointer1. Caption is passed to11, which performs its value copy;
  copying it on entry here would change aliasing and early-error behavior.
  Locals5 directory,6 unit,7 index,8 gap,9 amount,10 kind,11 heap mark,
  12 swapped,13 saved IO,14..17 volume,18..25 name,26 file,27 file/unit view,
  28 entry,29 date pointer. Mode>1 normalizes to (2 or4); other raw values
  retain their low-bit tests. Labels800/900 are$0C0F/$0C29 cleanup entries.
  Swapping writes/reads2028 bytes and preserves prior IO status on restore.
  The text-file path clears514 bytes at word33 before two512-byte writes.
  Dead joins$0A86/$0AA0 are documented in pcode-unreachable-branches.md.
  Nonlocal EXIT targets$0C5C and skips the local cleanup, as in the original. }
(*$I-*)
procedure rt_open_file(var f: integer; var caption: text80; mode: integer;
                 extra: s6wptr);
label 800, 900;
var
  cache: s6cache;
  unitnum: integer;
  index: integer;
  gap: integer;
  amount: integer;
  kind: integer;
  heap: s6heap;
  swapped: boolean;
  savedio: integer;
  volume: s4text7;
  filename: text15;
  view: s6fview;
  other: s6fview;
  entry: s6eptr;
  dateptr: ^s6date;
(*$include src/pascal/file_manager/rt_reserve_extent.pas*)
begin
  sy6e.state^.words[0] := 0;
  view.word := @f;
  if odd(view.fileptr^.words[5]) then
  begin
    sy6e.state^.words[0] := 12;
    exit(rt_open_file)
  end;
  if not rt_parse_file_spec(caption, volume, filename, amount, kind) then
  begin
    sy6e.state^.words[0] := 7;
    exit(rt_open_file)
  end;
  if mode > 1 then mode := ord(mode = 2) or ord(mode = 4);
  swapped := false;
  other.head := sy6e.file6;
  if odd(other.fileptr^.words[5] and ord(sy6e.state^.directory = nil)) then
  begin
    mark(heap.pointer);
    gap := sy6e.state^.words[7] - heap.word;
    if odd(ord(gap > 0) and ord(gap < 2028 + 400)) then
    begin
      gap := heap.word - sy6e.words[5];
      if odd(ord(gap > 0) and ord(gap > 2028) and
             ord(sy6e.units31[other.fileptr^.words[7]].caption =
                 other.rich^.volume8)) then
      begin
        unitwrite(other.fileptr^.words[7], sy6e.heap5^, 2028,
                  other.fileptr^.words[16], 0);
        release(sy6e.heap5);
        swapped := true
      end
    end
  end;
  unitnum := rt_resolve_volume(volume, 1, cache.header);
  if unitnum = 0 then
  begin
    sy6e.state^.words[0] := 9;
    goto 900
  end;
  other.device := @sy6e.units31[unitnum];
  view.fileptr^.words[5] := 1;
  view.fileptr^.words[15] := 0;
  view.fileptr^.words[7] := unitnum;
  view.rich^.volume8 := volume;
  view.fileptr^.words[13] := 0;
  view.fileptr^.words[6] := other.device^.flag4;
  view.fileptr^.words[29] := other.device^.flag4 and
                            ord(view.fileptr^.words[4] <> 0);
  if odd(ord(cache.directory <> nil) and ord(length(filename) > 0)) then
  begin
    index := rt_find_dir_entry(filename, mode, cache.directory);
    if odd(mode) then
    begin
      if index = 0 then
      begin
        sy6e.state^.words[0] := 10;
        goto 800
      end;
      view.rich^.entry16 := cache.directory^[index]
    end
    else
    begin
      if index > 0 then
      begin
        sy6e.state^.words[0] := 11;
        goto 800
      end;
      if kind = 0 then kind := 5;
      index := rt_reserve_extent(filename, amount, kind, cache.directory);
      if odd(ord(index > 0) and ord(kind = 3)) then
      begin
        entry := @cache.directory^[index];
        if odd(entry^.words[1] - entry^.words[0]) then
          entry^.words[1] := entry^.words[1] - 1;
        if entry^.words[1] - entry^.words[0] < 4 then
        begin
          rt_remove_dir_entry(index, cache.directory);
          index := 0
        end
      end;
      if index = 0 then
      begin
        sy6e.state^.words[0] := 8;
        goto 800
      end;
      view.rich^.entry16 := cache.directory^[index];
      view.fileptr^.words[15] := 1;
      rt_write_directory(unitnum, cache.directory)
    end
  end
  else
  begin
    if odd(ord(cache.directory = nil) and ord(length(filename) <> 0)) then
      if odd(sy6e.units31[unitnum].flag4) then
      begin
        sy6e.state^.words[0] := 10;
        goto 800
      end;
    entry := @view.rich^.entry16;
    entry^.words[0] := 0;
    entry^.words[1] := 32767;
    if odd(other.device^.flag4) then entry^.words[1] := other.device^.word5;
    entry^.kind2.kind := kind;
    entry^.caption := '';
    entry^.words[11] := 512;
    dateptr := @entry^.bits12;
    dateptr^.low4 := 0;
    dateptr^.middle5 := 0;
    dateptr^.high7 := 0
  end;
  if odd(mode) then
    view.fileptr^.words[12] := view.fileptr^.words[17] - view.fileptr^.words[16]
  else view.fileptr^.words[12] := 0;
  if odd(view.fileptr^.words[29]) then
  begin
    view.fileptr^.words[31] := 512;
    view.fileptr^.words[32] := 0;
    if odd(mode) then view.fileptr^.words[30] := view.fileptr^.words[27]
    else view.fileptr^.words[30] := 512;
    entry := @view.rich^.entry16;
    if entry^.kind2.kind = 3 then
    begin
      view.fileptr^.words[13] := 2;
      if not odd(mode) then
      begin
        fillchar(view.rich^.tail33, 514, 0);
        unitwrite(view.fileptr^.words[7], view.fileptr^.sector33, 512,
                  entry^.words[0], 0);
        unitwrite(view.fileptr^.words[7], view.fileptr^.sector33, 512,
                  entry^.words[0] + 1, 0)
      end
    end
  end;
  if odd(mode) then rt_rewind_file(f)
  else rt_flush_file(f);
800:
  if sy6e.state^.words[0] <> 0 then
  begin
    view.fileptr^.words[5] := 0;
    view.fileptr^.words[2] := 1;
    view.fileptr^.words[1] := 1
  end;
900:
  if swapped then
  begin
    release(heap.pointer);
    sy6e.state^.directory := nil;
    savedio := sy6e.state^.words[0];
    unitread(sy6e.file6^.words[7], sy6e.heap5^, 2028,
             sy6e.file6^.words[16], 0);
    sy6e.state^.words[0] := savedio
  end
end;
(*$I+*)
