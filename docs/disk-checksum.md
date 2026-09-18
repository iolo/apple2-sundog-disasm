# Raw disk-integrity checker

`src/native/disk_checksum.s` reconstructs the first 135 bytes of disk-2 block 54:
a 64-byte checksum table followed by 71 instruction bytes (41 instructions),
loaded at `$1800` and entered at `$1840`. The remaining 377 fetched bytes are
not part of this classified component; their code/data role remains unresolved.

## Caller and algorithm

Startup 7 initializes data-segment 29 word 30 to `26+16 = 42`. Game 21 procedure
30 sets its parent's local 9 to `$1800` at `$1383`, then reads one block from
`word30+9` via library 22 procedure 53 at `$13B3`. The wrapper adds 3, selecting
absolute block 54. At `$13BE` it reads eight blocks into `$4000`, using the
current absolute block number minus 3. Its `$13C9` call through library 22
procedure 25 targets `local9+64`, hence `$1840`, with an output-word pointer.

The native routine clears two byte accumulators and loops across 16 pages from
`$4000` through `$4FFF`. The even-address byte is added to one accumulator and
the odd-address byte to the other, clearing carry before each addition. It
returns the two modulo-256 sums through the supplied pointer. Thus the output
is a pair of independent byte sums, not a 16-bit sum with carry propagation.

Before the block read, game 21 computes `local9 + (block >> 2)` at `$1394`–`$13A3`
and stores that pointer through library 22 procedure 23. The shift is library
22 procedure 31. The comparison at `$13D5` compares the pointed-to word against
the returned checksum. Block number divided by four selects a two-byte entry
for each eight-block group. The table covers starts 0,8,...,248.

After each successful group, game 21 adds 8 to the block index at `$1404` and
explicitly replaces 48 with 56 at `$1409`–`$140F`. The skipped group contains
this checksum table, routine, and mutable state. Do not replace its stored
checksum with a newly computed value: it does not match the supplied image,
and the caller deliberately bypasses it.

## Table validation and limits

`tools/verify_block_checksums.py` independently computes the native algorithm
against the rebuilt play disk. All 31 non-skipped entries match. It records the
stored and computed values for every group, including the skipped mismatch
(stored `$57,$92`; computed `$86,$94`), in
`docs/reference/disk-checksums.json`. This is direct evidence for all 64 table
bytes; no resemblance-based data classification is needed.

This routine validates disk content. It does not establish that every checked
byte is data or an image asset: checked groups include source modules, assets,
and still-unresolved regions. The table and routine remain byte-identical to
the supplied image. No fresh emulator execution of the checker is claimed.
