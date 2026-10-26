{ library_22 procedure 53, $0B86..$0BAA, attributes $0BB4.
  buffer is a raw 16-bit address; one local word captures it as a pointer.
  CSP 5/6 perform unit I/O with the original count, block offset and mode. }
procedure disk_blocks_io(buffer, blocks, block: integer; reading: boolean);
var
  target: address16;
begin
  target.word := buffer;
  if reading then
    unitread(4, target.bytes^, 512 * blocks, block + 3, 0)
  else
    unitwrite(4, target.bytes^, 512 * blocks, block + 3, 0)
end;
