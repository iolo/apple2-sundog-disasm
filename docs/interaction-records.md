# Interaction bounds and parameter records

`assets/interaction-records/` contains sixteen 32-byte records from disk-2
block 79. Disk-1 block 196 offsets 128–511 contain exact copies of records
4–15. One 512-byte source therefore reconstructs **896 disk bytes**. The first
128 bytes of that disk-1 block differ: offsets 0–126 are a separately
reconstructed [encoded native disk reader](encoded-disk-reader.md), and byte
127 is its separately evidenced native alignment byte. They are not classified
as interaction records.
The neighboring disk-2 block 80 is separately
classified as a [retained half-font](retained-font-half.md), through its complete
row-mask relationship to the verified shared font.

## Loader and field evidence

Play startup 7 procedure 5 sets segment-29 word 32 to 26, then derives word
30=42, word 29=52, word 28=61 and word 27=76 at `$0142`–`$0163`.
Game 18 procedure 16 (`src/pcode/building_interiors.s`) reads one block into $4000
using word 27 at `$0B88`–`$0B90`. Library 22 procedure 53 adds three to the
logical block number, identifying disk-2 block **79**.

The selector at `$0B9C`–`$0BBF` uses record one for type eleven; otherwise it
computes `4*(type-7) + ((word38 low6 + word39 low5) mod 4)`. At `$0BC1`–`$0BC5`,
`IXA 16` scales the record index by sixteen words, i.e. **32 bytes**.

| Record bytes | Data layout | Consumer evidence in game 18 |
| --- | --- | --- |
| 0–19 | Five four-byte packed bounds groups | Procedure 16 passes record offsets 16, 12, 8, 4 and 0 to procedure 17 at $0BF1, $0C12, $0C1F, $0C2C and $0C35 |
| 20 | Two four-bit style values | `INC 10`, four-bit `LDP` at $0BD1–$0BE0 and later drawing calls |
| 21 | Eight-bit drawing value | High byte of word ten read at $0BC7–$0BCC and $0BE8–$0BED |
| 22–23 | Two offsets biased by 128 | `INC 11`, byte reads and subtraction at $0C5D–$0C72 |
| 24 | Numeric parameter, clamped to at least three at use | $0C75–$0C85 |
| 25 | Numeric parameter, with zero/nonpositive interpreted as 128 at use | $0C88–$0C9A |
| 26–31 | Six zero bytes of unused aligned record storage | Repeated within all sixteen independently addressed 32-byte records |

Procedure 17 at `$0B2C` copies the selected four-byte group into two local
words. It unpacks four eight-bit fields, adds them to the current position
(segment-29 words 12 and 14, each minus two), and passes the bounds to
library 22 procedure 18. That routine stores the resulting four words.
When the drawing parameter is nonzero, procedure 17 passes the resulting
bounds to library 22 procedure 19 for drawing. Thus the packed groups are
coordinate data even where their exact gameplay role remains undocumented.

The six zero bytes are aligned record storage, supported by the explicit
32-byte stride, the 26-byte field extent, and the same six-byte tail in all
records. They are not inferred from arbitrary zero runs. The codec rejects
any nonzero padding. The disk-1 suffix is classified by its complete exact
record copies, without claiming a new live read of that suffix.

`fields.json` preserves the five groups in stored byte order, separates the
low/high nibbles, and expresses the two biased offsets as signed values. The
remaining parameters stay numeric; no unverified gameplay names are assigned.
Repacking reproduces all source bytes, including padding.

## Verification

```sh
python3 tools/test_interaction_record_asset.py
python3 tools/interaction_record_asset.py --verify assets/interaction-records
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Maintenance extraction with `--extract` requires a new repository-local output
directory and current exact rebuilt disks. It checks image hashes, exclusive
temporary ownership, all stored-copy bytes, and reversible field encoding.
Tests cover record boundaries, nibble order, biased offsets, padding mutation,
and invalid shapes/values. No new live interaction capture is claimed here;
the unchanged rebuilt images retain the existing behavioral baseline. Final
full classification and both-emulator validation remain required.
