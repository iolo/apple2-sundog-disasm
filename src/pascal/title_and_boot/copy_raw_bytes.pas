{ Both library26 variants: procedure4, $01F6..$0203, attributes $020E.
  Raw byte addresses, source then destination; CSP2 MOVELEFT preserves the
  original forward-copy behavior, including overlap. }
procedure copy_raw_bytes(source, destination, count: integer);
var
  dest: address16; {4}
  src: address16; {5}
begin
  src.word := source;
  dest.word := destination;
  moveleft(src.bytes^, dest.bytes^, count)
end;
