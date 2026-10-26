{ system_core0:26 $06A6..$06DD, attributes$06E8. Parameters: string3,
  index2, count1; local4 tail count; RBP0. Delete only a fully contained
  positive range. A range extending past the end is NOT clipped.
  The tail==0 path only writes length; the positive-tail path copies forward
  and rereads length afterward. Pointer s is a source-only storage view. }
procedure sys0_26(var source: integer; index, count: integer);
var tail: integer;
    s: s0strptr;
begin
  s.word := @source;
  if odd(ord(index > 0) and ord(count > 0)) then
  begin
    tail := s.bytes^[0] - index - count + 1;
    if tail = 0 then s.bytes^[0] := index - 1
    else if tail > 0 then
    begin
      moveleft(s.bytes^[index + count], s.bytes^[index], tail);
      s.bytes^[0] := s.bytes^[0] - count
    end
  end
end;
