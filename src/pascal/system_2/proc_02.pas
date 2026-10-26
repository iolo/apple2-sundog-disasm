{ system2:2 $0000..$00CF, attributes$00DE. Boolean result1, VAR file3;
  locals4 count,5 available,6 offset,7 remaining,8 done,9 file,10 entry.
  Preserve partial copies and IORESULT checks even when no write occurred.
  $0028's unreachable UJP to$0033 is a dead compiler join after goto999;
  it adds no executed effect (docs/pcode-unreachable-branches.md). }
(*$I-*)
function sys2_2(var f: sysfile): boolean;
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
  sys2_2 := true;
  fileptr := @f;
  entryptr := @fileptr^.entry16;
  remain := fileptr^.words[4];
  offset := 0;
  repeat
    if fileptr^.words[13] >= fileptr^.words[12] then
    begin
      if fileptr^.words[31] + remain > fileptr^.words[30] then goto 999;
      avail := entryptr^.words[11] - fileptr^.words[31]
    end
    else avail := 512 - fileptr^.words[31];
    count := remain;
    if count > avail then count := avail;
    if count > 0 then
    begin
      moveleft(fileptr^.sector33[fileptr^.words[31]],
               fileptr^.current.bytes^[offset], count);
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
      unitread(fileptr^.words[7], fileptr^.sector33, 512,
               entryptr^.words[0] + fileptr^.words[13], 0);
      if ioresult <> 0 then goto 999;
      fileptr^.words[13] := fileptr^.words[13] + 1;
      fileptr^.words[31] := 0
    end
  until done;
  sys2_2 := false;
999:
end;
(*$I+*)
