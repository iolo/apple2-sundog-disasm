# Retained world-map cache in the Blackblade save

The last **96 bytes** of disk-1 save slot 3, Blackblade, retain world-map cache
data. They occupy block 66, offsets 416–511. The saved buffer begins at $4000,
so the tail corresponds to **$53A0–$53FF**: cache offsets **928–1023** in the
world-map buffer at $5000. This classification follows actual producers and
saved state, rather than the sparse pattern or the disk write alone.

| Cache offsets | Tail offsets | Bytes | Producer-backed classification |
| --- | --- | ---: | --- |
| 928–959 | 0–31 | 32 copies of $0C | Map row 23, columns 8–39 |
| 960–999 | 32–71 | 40 zeros | Cleared storage after the map |
| 1000 | 72 | $01 | Cached world identifier |
| 1001–1023 | 73–95 | 23 zeros | Cleared cache storage |

## Producer and retention chain

1. Startup 7 at $00E2–$00E6 initializes segment-29 word 293 to zero. Game 21
   at $1418–$1429 assigns $5000 to a pointer and invokes CSP 10 with offset zero,
   length 2,048 and that zero value. Its native FILLCHAR implementation at
   $E68A–$E6CE writes exactly that count, establishing the cleared storage.
2. Game 21 procedure 29 at $12D8–$12DE sets parent local 55 to $5000. Both
   address assignments use library 22 procedure 23, which stores the supplied
   two-byte address through its destination pointer.
3. Game 21 procedure 28 reads the cached identifier at $1101–$1105. For a changed
   world, it reads the packed map and calls library 23 procedure 2 at $1133,
   passing local 55 as destination. The native decoder writes 24 rows of 40
   cells using the independently verified [world-map format](world-maps.md).
4. Blackblade's globals encode world **1** in word 37, bits 4–8. Its map's final
   32 cells decode to $0C. The variant loop at $1167–$11A6 changes only cells
   initially equal to 13, so these cells need no random-generator replay.
5. The saved world-1 record selects cities 1–5, at cache offsets 292, 368, 398,
   225 and 771. Special city 60 is at offset 312. Its relocation flag, bit 112
   of the array beginning at word 82, is zero. The marker writes at
   $11E7–$11F9 and $125B–$126D therefore cannot change the final 32 cells.
6. $126E–$127D writes the world identifier to $5000+1000 = $53E8, exactly the
   position of the saved tail's single $01.
7. Startup 7 copies the globals into $4000, six working blocks into $4200 and
   1,440 world-table bytes into $4E00. The final copy ends at **$53A0**; the
   ten-block save extends through $53FF. It therefore retains the following
   96-byte cache fragment. See [save-state-banks.md](save-state-banks.md).

The static model reproduces all 96 bytes; the original bank checksum remains
$B77A. The checksum corroborates the bank pairing, not the code/data decision.
This is a retained-cache inference backed by the exact producers and values,
not a new trace of the historical save. The model does not reconstruct random
variants in other map cells or claim a complete final runtime map. The other
three save slots retain independently disassembled p-code tails.

## Reconstruction and checks

`src/data/saved_map_cache.s` names the retained tile row, cleared gap, identifier
and cleared suffix. Its 96 bytes replace only the former temporary tail.
`src/data/evidence/saved_map_cache.json` freezes producer windows from six
source-built components, including the map decoder, address assignment,
FILLCHAR vector/implementation and save-copy boundaries. The generated report
is `docs/reference/saved-map-cache.json`.

```sh
python3 tools/test_saved_map_cache.py
python3 tools/saved_map_cache.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The audit checks producer hashes/bytes, the native transition table, existing
asset hashes and saved-payload ownership, modeled tail values, the full-bank
checksum, fresh assembly and adopted ownership. Tests reject each altered tail
byte and wrong save extents, apply a city write moved into the retained row,
and refuse an unmodeled random relocation. Original bytes are preserved exactly.
