{ system_core0:33 $0940..$0A2C, attributes$0A3C. File pointer3, result1/2;
  locals4 index,5 completed,6 found,7 boundary,8 directory,9 file,10 entry,
  11 matched entry. True means extension was not performed. It can return
  true WITHOUT setting flags when an extent was found but needed no extension.
  Empty names and failed lookup/search/write set flags2 then1; only lookup
  mismatch/search miss assign IO5/6. The directory is edited before writing,
  with no rollback on failure. Preserve the full-word extent fields and the
  seven-bit value100 at entry word12 bit9, leaving the low nine bits intact.
  Complete the declaration from io_forwards.pas after the system6 bodies. }
(*$I-*)
function rt_extend_file;
label 900;
var index: integer;
    completed, found: boolean;
    boundary: integer;
    directory: s6cache;
    view: s6fview;
    entry, matched: s6eptr;
begin
  rt_extend_file := true;
  completed := false;
  view.fileptr := @f;
  entry := @view.rich^.entry16;
  if length(entry^.caption) > 0 then
  begin
    if view.fileptr^.words[7] <>
       rt_resolve_volume(view.rich^.volume8, 0, directory.header) then
    begin
      sy0e.state^.words[0] := 5;
      goto 900
    end;
    found := false;
    index := 1;
    while odd(ord(index <= directory.directory^[0].words[8]) and
              not ord(found)) do
    begin
      found := odd(ord(directory.directory^[index].words[0] = entry^.words[0])
                   and ord(directory.directory^[index].words[1] = entry^.words[1]));
      index := index + 1
    end;
    if not found then
    begin
      sy0e.state^.words[0] := 6;
      goto 900
    end;
    if index > directory.directory^[0].words[8] then
      boundary := directory.directory^[0].words[7]
    else boundary := directory.directory^[index].words[0];
    if odd(ord(entry^.words[1] < boundary) or ord(entry^.words[11] < 512)) then
    begin
      matched := @directory.directory^[index - 1];
      matched^.words[1] := boundary;
      matched^.words[11] := 512;
      rt_write_directory(view.fileptr^.words[7], directory.directory);
      if ioresult <> 0 then goto 900;
      view.fileptr^.words[2] := 0;
      view.fileptr^.words[1] := 0;
      if view.fileptr^.words[3] <> 0 then view.fileptr^.words[3] := 1;
      entry^.words[1] := boundary;
      entry^.words[11] := 512;
      entry^.bits12.high7 := 100;
      rt_extend_file := false
    end;
    completed := true
  end;
900:
  if not completed then
  begin
    f.words[2] := 1;
    f.words[1] := 1
  end
end;
(*$I+*)
