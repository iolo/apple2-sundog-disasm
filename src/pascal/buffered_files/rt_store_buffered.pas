{ system2:5 $0180..$02FF, attributes$030E. Same result/VAR/local layout as2.
  sysio must alias the pointer obtained by LOD2,1 in the original runtime;
  sysio^ is its error word, not a new private status. Core0:33 may extend the
  file; core0:8 consumes its current value. Both are recovered core bodies,
  declared before this routine through system_core/io_forwards.pas.
  $01D3's unreachable UJP to$01DE is the dead join after the error exit.
  Low-bit NOT of word13 at$02E4 is preserved; it is not a zero comparison. }
(*$I-*)
function rt_store_buffered(var f: sysfile): boolean;
label 999;
var
  count: integer;
  avail: integer;
  offset: integer;
  remain: integer;
  done: boolean;
  fileptr: sysfptr;
  entryptr: syseptr;
begin
  rt_store_buffered := true;
  fileptr := @f;
  entryptr := @fileptr^.entry16;
  remain := fileptr^.words[4];
  offset := 0;
  repeat
    if odd(ord(entryptr^.words[0] + fileptr^.words[13] = entryptr^.words[1]) and
           ord(fileptr^.words[31] + remain > entryptr^.words[11])) then
      if rt_extend_file(f) then
      begin
        sysio^ := 8;
        goto 999
      end;
    if entryptr^.words[0] + fileptr^.words[13] = entryptr^.words[1] then
    begin
      if fileptr^.words[31] + remain > entryptr^.words[11] then
      begin
        sysio^ := 8;
        goto 999
      end;
      avail := entryptr^.words[11] - fileptr^.words[31]
    end
    else avail := 512 - fileptr^.words[31];
    count := remain;
    if count > avail then count := avail;
    if count > 0 then
    begin
      fileptr^.words[32] := 1;
      moveleft(fileptr^.current.bytes^[offset],
               fileptr^.sector33[fileptr^.words[31]], count);
      fileptr^.words[31] := fileptr^.words[31] + count;
      offset := offset + count;
      remain := remain - count
    end;
    done := remain = 0;
    if not done then
    begin
      if odd(fileptr^.words[32]) then
      begin
        fileptr^.words[32] := 0;
        fileptr^.words[15] := 1;
        unitwrite(fileptr^.words[7], fileptr^.sector33, 512,
                  entryptr^.words[0] + fileptr^.words[13] - 1, 0)
      end;
      if ioresult <> 0 then goto 999;
      if fileptr^.words[13] < fileptr^.words[12] then
        unitread(fileptr^.words[7], fileptr^.sector33, 512,
                 entryptr^.words[0] + fileptr^.words[13], 0)
      else fillchar(fileptr^.sector33, 512, 0);
      if ioresult <> 0 then goto 999;
      fileptr^.words[13] := fileptr^.words[13] + 1;
      fileptr^.words[31] := 0
    end
  until done;
  if fileptr^.words[13] > fileptr^.words[12] then
  begin
    fileptr^.words[30] := fileptr^.words[31];
    fileptr^.words[12] := fileptr^.words[13]
  end
  else if odd(ord(fileptr^.words[13] = fileptr^.words[12]) and
              ord(fileptr^.words[31] > fileptr^.words[30])) then
    fileptr^.words[30] := fileptr^.words[31];
  if fileptr^.words[4] = 1 then
    if fileptr^.current.bytes^[0] = 13 then
      if entryptr^.kind2.kind = 3 then
        if odd(ord(fileptr^.words[31] >= 512 - 127) and
               not fileptr^.words[13]) then
        begin
          fileptr^.words[31] := 512 - 1;
          fileptr^.current.bytes^[0] := 0;
          rt_put_file_element(f)
        end;
  rt_store_buffered := false;
999:
end;
(*$I+*)
