# Raw viewscreen transition

`src/native/viewscreen_transition.s` reconstructs the first 944 bytes of disk-2
blocks 86–87, loaded at `$1800`. The two-block read also fetches 80 bytes after
this component. Those bytes are now separately classified as
[native output-buffer storage](native-output-storage.md), using historical
assembler allocation/clear/write behavior as additional evidence for the
79 zero bytes and retained final `$04`.

## Entry and load evidence

Game segment 13 at `$1DF9` passes `119,2,7,0,1` to procedure 31. The loader at
`$15DC` uses count 2 and relative block `data29.word27 + 7`. Startup 7 initializes
that word to 76; library 22 procedure 53 adds 3, selecting absolute block 86.
The caller displays “Switching to viewscreen” at `$1F23` and calls `$1800` through
library 22 procedure 25 at `$1F60`, passing the address of its four-byte state.
This replaces the earlier warp overlay at the same load address.

The entry saves the return address, consumes a pointer, and reads four parameter
bytes. The first selects zero, positive, or negative animation paths. All three
paths reach the shared return at `$193D`, which updates parameter byte 3 and
restores the return address. The routine copies and fills HGR row strips, uses
the row address tables at `$0DC0/$0E80`, and contains a delay loop at `$1B34`.
This supports the transition role without claiming detailed gameplay semantics.

The external JSR at `$1B2E` calls `$09F5`. Game 13 at `$25EA` loads the two-block
`$0800` overlay from `word27 + 2 + 3 = 81`. In those bytes, `$09F5` reads the
transition's `$2B/$2D/$2C` parameters, calls `$091A`, and writes through `($24),Y`,
returning at `$0A53`. This records the external dependency; the complete overlay
at blocks 81–82 is now reconstructed in [viewscreen-io.md](viewscreen-io.md).

## Classification

The adopted 944 bytes comprise 843 instruction bytes (410 instructions) and
101 data bytes. All instruction bytes are reachable through the evidenced entry.

| Memory range | Classification evidence |
| --- | --- |
| `$1800`–`$1B4A` | Native instructions with bounded internal branches/calls, plus the explicit external `$09F5` call |
| `$1B4B`–`$1B6A` | 32 destination-column values read at `$1A75`; the index wraps with AND `$1F` at `$1A7F` |
| `$1B6B`–`$1B8A` | 32 pixel-pattern bytes read at `$1A78` and stored through the row pointer at `$1A7B` |
| `$1B8B`–`$1B9E` | 20-byte row-copy buffer, written by `$198C` and read by `$199D` with X=19 down to 0 |
| `$1B9F` | One zero alignment byte between the buffer and word-aligned relocation metadata |
| `$1BA0`–`$1BA7` | Four empty native relocation lists |
| `$1BA8`–`$1BAF` | Backward entry pointer to `$1800`, native attributes, dictionary pointer, and segment/procedure trailer `1,1` |

The existing Pascal dictionary and relocation parsers independently validate the
944-byte container, its entry at offset zero, and relocation start at offset 928.
The source expresses metadata as typed words and symbolic pointers. Preparation,
adoption, and full-disk comparison retain the original bytes. No fresh emulator
trace of this transition is claimed.
