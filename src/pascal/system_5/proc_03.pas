{ system5:3 $013A..$0163, attributes$016E. Integer result1, index3,
  VAR header4, local tag pointer5. Kind0 maps to the original index; other
  kinds use the low byte, returning0 when that byte exceeds31. }
function sys5_3(var header: s5header; index: integer): integer;
var tag: ^s5tag;
begin
  tag := @header.tags128[index];
  if tag^.kind < 1 then sys5_3 := index
  else if tag^.number > 31 then sys5_3 := 0
  else sys5_3 := tag^.number
end;
