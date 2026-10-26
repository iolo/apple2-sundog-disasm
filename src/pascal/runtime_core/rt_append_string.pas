{ system_core0:23 $05F2..$0614, attributes$061E. Parameters: destination3,
  source2, capacity1; no original locals; RBP0. Append only if the sum fits.
  MOVELEFT is the forward copy CSP2, including overlapping arguments.
  Both lengths are reread AFTER copying; do not replace with concatenation.
  Source-only pointer views do not copy either string. }
procedure rt_append_string(var dest, source: integer; capacity: integer);
var d, s: s0strptr;
begin
  d.word := @dest;
  s.word := @source;
  if s.bytes^[0] + d.bytes^[0] <= capacity then
  begin
    moveleft(s.bytes^[1], d.bytes^[d.bytes^[0] + 1], s.bytes^[0]);
    d.bytes^[0] := s.bytes^[0] + d.bytes^[0]
  end
end;
