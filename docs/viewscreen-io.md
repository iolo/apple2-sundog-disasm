# Shared viewscreen drawing and joystick overlay

`src/native/viewscreen_io.s` reconstructs all 1,024 bytes of disk-2 blocks 81–82
at `$0800`–`$0BFF`. Game 13 at `$25EA` reads two blocks to 2048, from relative
`data29.word27 + 2`; startup sets word 27 to 76 and library 22 procedure 53
adds 3, selecting block 81. The following `$25F7` call initializes the table
workspace described below. These are raw reads and address calls outside the
inventoried Pascal segment loads.

## Executable entries

- `$0800`: called through library 22 procedure 25 by game 12 at `$02DA/$02E5`.
  Consumes a pointer argument and draws symmetric, masked XOR patterns into HGR
  strips, with optional speaker reads at `$08A0`.
- `$09D6`: called by game 12 at `$041F`, `$0627`, and other sites. Copies the
  low bytes of four argument words into `$2D` down through `$2A`, then falls
  through to the drawing helper.
- `$09F5`: also called directly by the viewscreen transition at `$1B2E`, using
  the already prepared zero-page parameters. Draws rows using the `$0B00` table,
  optionally adds eight marks, and returns at `$0A53`.
- `$0A73`: called by game 12 at `$09FE`. Reads Apple II paddle timers: `$C070`
  starts the measurement, then `$C064/$C065` are polled. The two counters are
  limited and divided by four, then mapped through the signed 32-entry table
  at `$0ADF`. It stores two sign-extended word results through its pointer.

The native HGR row helper at `$091A` uses the earlier initializer's low/high
address tables at `$0DC0/$0E80`, adding 12 to the low address for the strip.
All 290 instructions (545 distinct bytes) have control-flow paths from these
confirmed entries. All native calls and branches remain within this overlay.
No new runtime trace of these routines is claimed.

## Data boundaries and consumers

| Memory range | Stored data and evidence |
| --- | --- |
| `$0937`–`$096B` | 53 drawing-column values read at `$08A5/$08B0` |
| `$096C`–`$09A0` | 53 first-byte drawing masks read at `$08BA/$08D3` |
| `$09A1`–`$09D5` | 53 second-byte drawing masks read at `$08C6/$08E2/$08E7` |
| `$0A54`–`$0A5A` | Seven pixel masks indexed only when the unsigned index is below 7, at `$0A1A` |
| `$0A5B`–`$0A62` | Eight destination address high bytes read at `$0A44` |
| `$0A63`–`$0A6A` | Eight destination address low bytes read at `$0A3F` |
| `$0A6B`–`$0A72` | Eight OR masks read at `$0A49`; the loop index runs from 7 down to 0 |
| `$0ADF`–`$0AFE` | 32 signed paddle-to-motion values, read at `$0AB7/$0AC7` with indices bounded to 0–31 |
| `$0AFF` | One zero alignment byte before the word-aligned native metadata |
| `$0B00`–`$0B07` | Four empty native relocation lists in the stored image |
| `$0B08`–`$0B0F` | Backward entry pointer, native attributes, procedure dictionary pointer, and trailer `1,1` |
| `$0B10`–`$0BFF` | Stored initial contents of the remainder of a 256-byte drawing-table workspace; overwritten before use |

The Pascal dictionary and relocation parsers independently validate a 784-byte
native container, entry offset zero, with relocation lists starting at offset
768. The remaining 240 stored bytes are zero except the final `$04`; they are
preserved exactly, not normalized into zero padding.

The whole `$0B00`–`$0BFF` page becomes data workspace at runtime, including the
former container metadata. Game 13 procedure 2 at `$002E` computes `$0800+768`,
then loops over indices 0 through 255 (`$0037`–`$0059`), storing one generated
byte per index at `$0053`. Game 13 calls this procedure immediately after the
block read. Native `$0A06` later reads `$0B00,X`. This writer/reader evidence
classifies the full page as data; its last stored `$04` byte is not treated as
an executable opcode or an unexplained padding exception. No on-disk bytes are
changed to simulate the runtime-generated table.

Preparation checks all 479 data bytes and 545 code bytes, followed by exact
assembly, adoption, and full-disk comparison. Source ownership of this overlay
is complete; classification of other disk regions and older provisional native
source regions remains separate work.
