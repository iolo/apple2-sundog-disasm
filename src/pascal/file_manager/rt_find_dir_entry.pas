{ system6:12 $05DC..$061A, attributes$0626. Integer result1,
  name pointer5, class4, directory pointer3; locals6 index,7 found,8 entry.
  The caption is referenced without a value copy. EQU6 compares the low bit
  of class against (packed date high7 <> 100). Both loop tests are evaluated;
  count is reread on every test, including the one after finding a match. }
function rt_find_dir_entry(var caption: text15; classflag: integer;
                 directory: s6dptr): integer;
var
  index: integer;
  found: boolean;
  entry: s6eptr;
begin
  rt_find_dir_entry := 0;
  found := false;
  index := 1;
  while odd(ord(index <= directory^[0].words[8]) and (not ord(found))) do
  begin
    entry := @directory^[index];
    if entry^.caption = caption then
      if odd(classflag) = (entry^.date12.high7 <> 100) then
      begin
        rt_find_dir_entry := index;
        found := true
      end;
    index := index + 1
  end
end;
