{ system5:3 $013A..$0163, attributes$016E. Integer result1, index3,
  VAR header4, local tag pointer5. Kind0 maps to the original index; other
  kinds use the low byte, returning0 when that byte exceeds31. }
function rt_mapped_segment(var header: s5header; index: integer): integer;
var tag: ^s5tag;
begin
  tag := @header.tags128[index];
  if tag^.kind < 1 then rt_mapped_segment := index
  else if tag^.number > 31 then rt_mapped_segment := 0
  else rt_mapped_segment := tag^.number
end;
