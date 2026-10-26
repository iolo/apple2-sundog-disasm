{ system2:4 $0122..$0174, attributes$017E. VAR file1; local snapshot2..291
  is290 words, pointer292 (582 local bytes). Test word13 by its low bit, not
  by nonzero. Restore the whole record on word2's low bit, then set1/2 and
  decrement restored word31. Snapshot includes the original pointer fields. }
procedure sys2_4(var f: sysfile);
var
  saved: sysfile;
  fileptr: sysfptr;
begin
  saved := f;
  fileptr := @f;
  if odd(fileptr^.words[13]) then
    fileptr^.words[13] := fileptr^.words[13] + 1;
  fileptr^.words[31] := 512;
  sys0_7(f);
  if odd(fileptr^.words[2]) then
  begin
    f := saved;
    fileptr^.words[2] := 1;
    fileptr^.words[1] := 1;
    fileptr^.words[31] := fileptr^.words[31] - 1
  end
end;
