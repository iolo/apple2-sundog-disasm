{ system_core0:36 $0B0C..$0B64, attributes$0B70, lexical1. Unit6,
  buffer5, byte offset4, block count3, disk block2, reading1; locals7 bytes,
  8 chunk. Split at63 blocks, retaining signed16-bit offsets/count arithmetic.
  Each transfer is followed by IORESULT. The original self-EXIT(0,36) on
  failure targets the bare RNP0 at$0B64; goto999 expresses that same return
  without introducing cleanup. No lower-bound validation is added. }
(*$I-*)
procedure rt_unit_block_chunks(unitnum: integer; buffer: s0bptr;
                 offset, blocks, block: integer; reading: boolean);
label 999;
var bytes, chunk: integer;
begin
  if blocks > 63 then chunk := 63 else chunk := blocks;
  bytes := chunk * 512;
  while blocks <> 0 do
  begin
    if reading then unitread(unitnum, buffer^[offset], bytes, block, 0)
    else unitwrite(unitnum, buffer^[offset], bytes, block, 0);
    if ioresult <> 0 then goto 999;
    blocks := blocks - chunk;
    offset := offset + bytes;
    block := block + chunk;
    if blocks <= chunk then
    begin
      chunk := blocks;
      bytes := chunk * 512
    end
  end;
999:
end;
(*$I+*)
