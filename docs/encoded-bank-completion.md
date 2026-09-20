# Complete classification of both encoded native banks

Disk-1 blocks 197–200 and disk-2 blocks 41–44 now have complete code/data
classification and source reconstruction. Each decoded 2,048-byte bank contains
**1,475 instruction bytes and 573 data bytes**, including copied instructions
and the two previously documented clipped instruction fragments. This closes
these two banks' static reconstruction; live execution of their bodies remains
unproved and is not claimed by the classification audit.

## Final retained disk-format constants

The last six bytes per bank are data constants in the existing symbol/buffer
record and its established suffix copy:

| Primary offset | Copied offset | Value | Classification |
| --- | --- | --- | --- |
| `$05F0` | `$07F0` | `$FF` | Retained disk-fill symbol, following the eight searched symbols |
| `$05F6–$05F7` | `$07F6–$07F7` | `$D5,$D7` | Retained raw disk marker, following the five-byte read-buffer initializer |

The primary layout is a contiguous data record: retry count at `$05E7`, eight
searched symbols at `$05E8–$05EF`, the extra `$FF`, five zero buffer bytes at
`$05F1–$05F5`, the marker pair, then the consumed track index, mode and wipe
pointer at `$05F8–$05FB`. Both relocated banks preserve these data offsets and
values, as do their suffix copies. The earlier body audit already establishes
the surrounding fields' direct consumers.

There is additional positive format evidence for the final constants:

- The native disk reader at `$013C` reads `$C08C,X`, and `$0141` compares the
  incoming stream byte with immediate `$FF` while counting disk-fill bytes.
- Reads at `$047B/$0484` compare with immediate `$D5/$D7` at `$0480/$0489`.
  Another reader at `$04D7/$04E6` uses the same pair at `$04DC/$04EB`.
- The independently archived raw protection track, already validated in
  [play-disk-final-track.md](play-disk-final-track.md), contains the exact
  `$D5,$D7` pair at track-byte offset `$0350` followed by `$FF`; `$FF` is also
  its predominant fill value. Its complete sparse representation and hash are
  committed reference evidence. The nibble image's readable tracks identify
  the corresponding play-side disk layout.

Together, the data-record placement, matching native comparisons, independent
raw disk format and exact duplicated layout support **retained disk-format
data**, rather than new instructions in these slots. This is a classification
inference. The comparison instructions use immediate values; they do **not**
read these stored fields. The symbol search uses indices 7 down to 0, and the
buffer writer uses indices 5 or 2 down to 1. Neither is extended to invent a
consumer for the retained bytes. Their original reason for remaining in the
record is not established. No terminator semantics or live use of these stored
constants is claimed.

## Combined ownership audit

| Reconstruction layer | Code bytes per bank | Data bytes per bank |
| --- | ---: | ---: |
| Position-independent loader | 63 | 0 |
| Reviewed body graph and embedded data | 1079 | 418 |
| Native footer and copied suffix | 327 | 137 |
| Disconnected stubs and retained pointers | 6 | 12 |
| Final retained symbols and their copies | 0 | 6 |
| **Total** | **1475** | **573** |

`tools/encoded_bank_completion.py` reruns the loader decoder, original strict
body graph, footer/copy audit and retained-stub audit. It verifies the new
symbol evidence, then combines their byte ownership with mandatory rejection
of overlaps, gaps or unknown classifications. The generated
`docs/reference/encoded-bank-completion.json` contains full code/data ranges
and counts for both banks. Verification also checks that every disk byte maps
to ca65 source with the correct original additive-encoding phase.

The original body graph remains strict: disconnected stubs that land in known
data are documented as unused instructions, without reinterpreting that data
as an executable continuation. Exact copied instruction fragments keep their
original context and never become opaque data.

```sh
python3 tools/test_encoded_bank_completion.py
python3 tools/encoded_bank_completion.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

All newly emitted slices assemble and re-encode exactly. Tests reject changed
constants, comparison instructions, disk reads, neighboring data ownership,
raw-track evidence and incomplete/overlapping combined ownership. Historical
raw media are evidence only; normal disk builds read committed source. Both
full disk outputs are unchanged, preserving the existing emulator baseline.
