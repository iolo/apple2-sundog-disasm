# Mutable workspace after the base dialogue dictionary

Disk-2 dictionary-buffer offsets **808–996** are initialized workspace for
supplemental dialogue text. They correspond to block 89 offsets 296–484, 189
bytes in total. The original bytes are all zero and are reconstructed by
`src/data/dialogue_workspace.s`. Their data classification follows an actual
copy destination in the shipped p-code, not their zero values alone.

The [base dictionary](dialogue-dictionary.md) has 65 low-byte pointers and 743
text bytes, ending at offset 808. Entries 52–63 are initially empty: pointer
indices 52–64 all resolve to 808. During initialization, game-16 code at
`$1676–$1697` starts from index 64 and scans backward through equal pointer
bytes. It stops at index **52**, storing that first free entry index in parent
local 26. The dictionary itself is loaded at `$4A00` in a two-block allocation.

## Supplement-copy consumer

Game-16 procedure 32 performs the following operations:

- `$0EE7–$0EF4` reads the supplement count and word-addressed source offset.
  `$0EF6–$0EF9` initializes the destination entry index from parent local 26.
- `$0F00–$0F0A` reads the current text length and calls procedure 12 to resolve
  that entry's dictionary destination. Procedure 12 reads the pointer at
  `$0584–$058B` and accounts for the previously established page wraps.
- `$0F0C–$0F16` calls MOVELEFT with the supplement text source, dictionary base,
  destination offset and text length. This writes into the dictionary tail.
- `$0F18–$0F26` updates the next low-byte pointer to the end of the copied text.
  The source advances past the length/text record and its word alignment;
  the destination entry index advances and the supplement count decreases.
- `$0F42–$0F5B` fills the remaining pointer slots through index 64 with the
  final end pointer. `$0F5C–$0F67` rebuilds the dictionary's wrap-index data.

For the supplied supplements, every destination remains on the same fourth
dictionary page. The copy model therefore matches the pointer helper without
inventing a new wrap before the final rescan.

| Supplemental disk block | Entries | Text bytes copied | Destination end, exclusive |
| --- | ---: | ---: | ---: |
| 90 | 1 | 9 | 817 |
| 91 | 7 | 66 | 874 |
| 92 | 5 | 69 | 877 |
| 93 | 3 | 78 | 886 |
| 94 | 5 | 83 | 891 |
| 95 | 9 | 189 | 997 |
| 96 | 3 | 84 | 892 |
| 97 | 3 | 39 | 847 |
| 99 | 5 | 83 | 891 |
| 100 | 9 | 180 | 988 |
| 101 | 5 | 65 | 873 |
| 102 | 2 | 57 | 865 |

Block 95's nine records establish writes to every byte of the adopted 189-byte
workspace. These are static results from the current code and supplied data,
not a new emulator trace or a claim that every dialogue branch was played.
The retained initial zeros are not substituted with any supplement's text.

The final **27 bytes at offsets 997–1023** remain unclassified. Their initial
contents are 26 zeros and `$A0`; no current supplement reaches them. This audit
does not extend the maximum write range or infer a terminator for that final
byte. The renderer-facing text asset continues to end at its established
base/supplement record boundaries.

## Verification

`src/data/evidence/dialogue_workspace.json` records bounded consumer windows
from the already disassembled game-16 component. `tools/dialogue_workspace.py`
checks those bytes, all supplemental records against the exact disk and their
classified asset, and the base-pointer scan. It replays copies and pointer
updates independently for all twelve banks, verifies the final offsets, and
requires their write union to cover exactly 808–996. It also checks fresh
assembly and manifest ownership. Full per-entry write ranges and resulting
buffer hashes are in `docs/reference/dialogue-workspace.json`.

```sh
python3 tools/test_dialogue_workspace.py
python3 tools/dialogue_workspace.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests reject changed initial pointers/workspace, truncation, removal of the only
supplement reaching offset 996, and a supplement extending beyond the reviewed
range. They vary the excluded 27 bytes to confirm that the model preserves
them without classifying or normalizing them. Both disk images remain exact.
