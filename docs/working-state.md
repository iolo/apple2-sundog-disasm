# Record templates, world defaults, and working data

`assets/working-state/` extracts three data regions whose consumers are now
traced. The source asset is 5,017 bytes, mapped to 6,027 disk bytes because the
record template has three exact copies. `fields.json` provides a reversible
word-record representation; unknown individual field meanings remain raw
numeric values rather than guessed labels.

| Data | Disk locations | Classified size per occurrence |
| --- | --- | ---: |
| Eighteen 28-byte templates and a selector byte | Disk 1 block 22; disk 2 blocks 2 and 45 | 505 |
| World-table defaults | Disk 1 blocks 23–25, first 1,440 bytes | 1,440 |
| Working gameplay records | Disk 2 blocks 48–53 | 3,072 |

The seven trailing bytes in each template block and the final 96 bytes in the
world-default allocation remain unresolved. This checkpoint does not classify
them from adjacency. The template block is not a globals snapshot: its actual
consumer uses 28-byte records, unlike the 512-byte globals area in saved banks.

## Template record consumer

Utility initialization (`src/pcode/utility_disk1.s`, `$0068`–`$0069`) sets
data-segment 29 word 30 to 19. Procedure 14 reads one block using word 30 into
`$0A00` at `$03F4`–`$0400`. With library 22 procedure 53's three-block bias,
this identifies disk-1 block 22.

At `$040A`–`$041A`, the procedure reads byte 504, adds five, takes the result
modulo 18, and stores the selector back. `$0430`–`$0445` iterates 18 entries
in that cyclic order. `$0451`–`$0457` indexes the source with `IXA 14`, i.e.
14 words or 28 bytes per record. `$0471`–`$047F` copies the two seven-word
halves into the generated 32-byte gameplay record. The record bodies occupy
exactly `18*28=504` bytes; the following byte has its own explicit consumer.

The same 505 bytes occur exactly at disk-2 blocks 2 and 45. Block 45 also has
an independent play-side consumer: game 20 procedure 5 at `$0304`–`$030A`
calls its record reader (procedure 3) with block word 30, record width 28, and
the selected index. Play startup sets word 30 to 42, making the disk block
42+3=45. The reader multiplies index by width at `$0035`–`$0038` and copies
the selected record at `$0069`–`$0072`. Block 2's occurrence is classified as
an exact stored copy; no new live read of that copy is claimed.

## World-table defaults

Utility initialization reads three blocks at `$00A0`–`$00AA`, using
word30+1+3=23. `$00AD`–`$00B7` then copies precisely 1,440 bytes into `$E901`.
The three table pointers established at `$0074`–`$009A` split that data at
offsets 240 and 528, producing regions of 240, 288, and 912 bytes. These are
the same data-table boundaries independently established by the saved-game
load/save transfers in [save-state-banks.md](save-state-banks.md).

Utility procedure 17 writes those tables back to their default allocation at
`$0658`–`$0663` and to the selected save bank at `$0666`–`$0671`. Although
the disk transfers are three full blocks, the explicitly copied table extent
is only 1,440 bytes. The remaining 96 bytes stay outside the adopted asset.

## Working gameplay records

Startup 7 procedure 6 restores six working-state blocks from the selected save
buffer at `$0302`–`$0310`, and procedure 8 reads them back into the save buffer
at `$05C4`–`$05D2`. These transfers identify disk-2 blocks 48–53. The current
on-disk values are preserved as they stand; they are not replaced with values
from one of the four saved games.

Game 20 supplies the field consumers: two blocks of 16-byte records at
`$0280`–`$028A` and `$02E2`–`$02E8`, followed by four blocks of 32-byte records
selected using index division/modulo 16 at `$02F4`–`$0302`. Procedure 3 copies
the selected record into local data and copies edits back, while procedure 7
writes the updated working blocks. The detailed save-bank evidence is linked
above. The reversible representation retains 64 records of eight words and
64 records of sixteen words, including unused storage inside those records.

## Verification

```sh
python3 tools/test_working_state_asset.py
python3 tools/working_state_asset.py --verify assets/working-state
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Maintenance extraction with `--extract` checks both current rebuilt image
hashes, equality of all three template copies, exclusive temporary ownership,
and exact structured-record round trips. Tests cover selector/record separation,
word layouts, malformed fields, and rejection of unreviewed tails. Normal
builds use the committed data without reading originals. Both images remain
exact; no new emulator observation or completion of live save/load testing is
claimed by this checkpoint.
