{ system_core0:25 $0676..$069A, attributes$06A4. Parameters: source4,
  destination3, index2, count1; no original locals; RBP0.
  Clear destination with SAS80 BEFORE testing source length. This matters
  when the buffers alias. Invalid ranges leave an empty result; there is no
  clipping or additional80-character limit on the subsequent raw copy. }
procedure sys0_25(var source, dest: integer; index, count: integer);
var s, d: s0strptr;
begin
  s.word := @source;
  d.word := @dest;
  d.text^ := '';
  if odd(ord(index > 0) and ord(count > 0) and
         ord(index + count - 1 <= s.bytes^[0])) then
  begin
    moveleft(s.bytes^[index], d.bytes^[1], count);
    d.bytes^[0] := count
  end
end;
