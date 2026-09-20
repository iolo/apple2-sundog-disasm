# Saved-game state and slot descriptors

Disk 1 contains four saved-game banks starting at logical blocks 27, 37, 47,
and 57. Each spans ten blocks (5,120 bytes). The first 5,024 bytes of each
bank have evidenced data consumers and serialization paths. They are extracted
in `assets/save-states/payloads.bin`, with reversible structured word records
in `records.json`. The final 96 bytes of the first three banks are now mapped to
[preserved p-code source copies](preserved-pcode-copies.md); the fourth bank's
96-byte tail remains unresolved.

Four corresponding 64-byte descriptors occupy the first 256 bytes of block 26,
extracted as `slots.bin`. The remaining zero half of that block is separately
reconstructed as [bounded descriptor-block storage](asset-block-storage.md).
The original asset extraction classified `4*5024 + 4*64 = 20,352`
disk bytes. No executable region is adopted by this component.

## State layout and evidence

Offsets below are relative to each ten-block bank. Endpoint offsets are exclusive.

| Range | Size | Data classification and consumer |
| --- | ---: | --- |
| 0–512 | 512 | Snapshot of the globals beginning at data-segment 29 word 36 |
| 512–1536 | 1,024 | Gameplay record bank; 64 records of 16 bytes |
| 1536–3584 | 2,048 | Gameplay record bank; 64 records of 32 bytes |
| 3584–3824 | 240 | World-table data addressed by segment-29 word 23 |
| 3824–4112 | 288 | World-table data addressed by segment-29 word 24 |
| 4112–5024 | 912 | Remaining world-table data addressed by segment-29 word 25 |
| 5024–5120 | 96 | Excluded from the state asset; preserved p-code in slots 0–2, unresolved in slot 3 |

The word arrays retain every bit, including packed fields, text storage, and
unused storage inside the typed records. Many individual field meanings remain
undecoded. Their classification as data is based on the following load/save
paths and indexed data consumers, not on apparent strings, zeroes, or checksums:

- `src/pcode/library_26_body.inc`, procedure 6, derives the selected save-bank
  relative block as `24 + 10*slot` at `$02F8`–`$02FD`. The one-block read at
  `$0305`–`$0312` targets the address of data-segment 29 word 36 directly.
  The same procedure reads all ten blocks into `$4000` at `$033D`–`$0345`.
  Library 22 procedure 53 adds three to disk block numbers, yielding the four
  physical logical starts above.
- `src/pcode/startup_7.s`, procedure 6, restores the buffered state: `$0302`–
  `$0310` writes six blocks from `$4200` to the play-side working-state area
  (word30+3+3 = block 48, through block 53). `$0313`–`$0321` copies 1,440
  bytes from `$4E00` into the world-table storage at `$E901`.
- The inverse save path is explicit in procedure 8 of the same segment:
  `$05B3`–`$05C1` copies 512 bytes from segment-29 word 36 to `$4000`;
  `$05C4`–`$05D2` reads six working-state blocks into `$4200`;
  `$05D5`–`$05E3` copies 1,440 bytes from `$E901` to `$4E00`.
  `$05EE`–`$05F6` writes the ten-block bank. The 96 bytes beyond the last
  explicit table copy do not gain a data classification from that write alone.
- Startup procedure 6 at `$02D1`–`$02F7` installs the three world-table pointers
  at `$E901`, `$E901+240`, and `$E901+240+288`. The total transfer size is 1,440,
  establishing the last table's 912-byte extent. Utility initialization uses
  the same offsets and size at `$0074`–`$00B7` in `src/pcode/utility_disk1.s`.
- `src/pcode/game_20.s`, procedure 5, reads two working blocks at `$0280`–
  `$028A` and addresses their data in 16-byte records (`IXA 8`) at `$02E2`–
  `$02E8`. `$02F4`–`$0302` selects a subsequent block with `5+city_index//16`,
  then selects a 32-byte record with `city_index%16`. Procedure 3 performs
  the actual block read and record copy at `$002C`–`$0057`; the inverse
  `$005C`–`$0065` copies the edited record back. Procedure 7 writes the first
  two working blocks at `$0468`–`$0472` and selects the same 32-byte record
  layout at `$0490` onward. Thus the middle six blocks are serialized gameplay
  data, distinct from native overlay loads elsewhere on the disks.

## Descriptors and checksums

Utility initialization explicitly iterates four slots, indexed by `IXA 32`
(64 bytes), in `src/pcode/utility_disk1.s` at `$00D3`–`$00E0`. The first
16 bytes contain a counted name and its fixed-width residual storage. The next
48 bytes are preserved as 24 little-endian words. The status word at offset 16
is tested at `$00E2`–`$00EC`; the checksum word at offset 30 is compared with
library 26 procedure 3's result at `$0128`–`$0134`. Other descriptor fields are
kept without assigning unverified semantics.

Library 26 procedure 3 is native code at segment offset `$07BA`. It sums even
and odd byte positions independently modulo 256 across the requested blocks;
the even sum is the low result byte. Startup's save path updates the descriptor
at `slot*64+30` at `$0618`–`$0632`. All four original banks match:

| Slot | Descriptor name | First block | Stored and computed checksum |
| --- | --- | ---: | --- |
| 0 | Hawkmoon | 27 | `$8CAF` |
| 1 | Starrion | 37 | `$EE29` |
| 2 | Brother Wolf | 47 | `$F411` |
| 3 | Blackblade | 57 | `$B77A` |

These checksums independently support the bank/descriptor pairing. They cover
all 5,120 bytes, including the unresolved tail, and are not themselves evidence
that an arbitrary byte is data. The extraction manifest records both whole-bank
and excluded-tail hashes, without adopting the tail.

## Verification and limits

```sh
python3 tools/test_save_state_asset.py
python3 tools/save_state_asset.py --verify assets/save-states
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Maintenance extraction with `--extract` requires a new repository-local output
directory and the current exact rebuilt disk. It verifies all four full-bank
checksums, exclusive temporary ownership, and lossless structured-record
round trips before writing assets. Normal builds read only committed data.
Asset verification covers the adopted payload/descriptor bytes, not the
excluded tails; full-disk verification includes their separately recorded
source or temporary inputs.
The extraction checkpoint did not execute a save. Step 09a subsequently records
a [MAME save and fresh-process reload](save-reload-validation.md), including the
changed slot checksum. Step 09b adds the corresponding
[Apple2TS saved-disk reload](apple2ts-behavior-validation.md). Final integration
and remaining classification requirements still apply.
