{ system_core0:24 $0620..$0669, attributes$0674. Parameters: source4,
  destination3, capacity2, index1; local5 tail count; RBP0.
  Tests are eager. Index beyond length+1 leaves the destination unchanged.
  CSP3 shifts backward, then CSP2 copies forward. Reread the source length
  after shifting and both lengths after insertion to preserve aliasing. }
procedure rt_insert_string(var source, dest: integer; capacity, index: integer);
var tail: integer;
    s, d: s0strptr;
begin
  s.word := @source;
  d.word := @dest;
  if odd(ord(index > 0) and ord(s.bytes^[0] > 0) and
         ord(s.bytes^[0] + d.bytes^[0] <= capacity)) then
  begin
    tail := d.bytes^[0] - index + 1;
    if tail > 0 then
    begin
      moveright(d.bytes^[index], d.bytes^[index + s.bytes^[0]], tail);
      tail := 0
    end;
    if tail = 0 then
    begin
      moveleft(s.bytes^[1], d.bytes^[index], s.bytes^[0]);
      d.bytes^[0] := d.bytes^[0] + s.bytes^[0]
    end
  end
end;
