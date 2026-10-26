# Game 8 condition display and text helpers

This group adds four game-8 bodies and nine library-22 bodies, bringing source
coverage to 58 procedures and 4,057 original instructions. It is the first
dependency group for game 18:23's call into game 8. Game 8's entry body remains
unrecovered; no replacement entry point is supplied.

The `game_8` component rebuilds to SHA-256
`49588749543660839355c65b1acaacc2cb5679ae726d914ed1c1c2a5be92d89d`.
Its disk-2 extents are recorded in `src/pcode/game_8.adopt.json`. Assembly revision
remains `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`; library-22 identity is recorded
in the [first group](game_18.md).

| Procedure | Entry through return | Attributes | Instructions | Pascal |
| --- | --- | --- | ---: | --- |
| game 8:2 | `$0000..$006D` | `$0078` | 75 | [proc_02.pas](../../src/pascal/game_8/proc_02.pas) |
| game 8:5 | `$010A..$0120` | `$012A` | 20 | [proc_05.pas](../../src/pascal/game_8/proc_05.pas) |
| game 8:6 | `$012C..$0171` | `$017C` | 48 | [proc_06.pas](../../src/pascal/game_8/proc_06.pas) |
| game 8:7 | `$017E..$0249` | `$0258` | 95 | [proc_07.pas](../../src/pascal/game_8/proc_07.pas) |
| library 22:10 | `$001C..$0044` | `$0050` | 25 | [proc_10.pas](../../src/pascal/library_22/proc_10.pas) |
| library 22:38 | `$0602..$0668` | `$0674` | 69 | [proc_38.pas](../../src/pascal/library_22/proc_38.pas) |
| library 22:39 | `$0676..$06B1` | `$06BE` | 35 | [proc_39.pas](../../src/pascal/library_22/proc_39.pas) |
| library 22:43 | `$0806..$0829` | `$0834` | 30 | [proc_43.pas](../../src/pascal/library_22/proc_43.pas) |
| library 22:44 | `$0836..$0852` | `$085C` | 14 | [proc_44.pas](../../src/pascal/library_22/proc_44.pas) |
| library 22:45 | `$085E..$0879` | `$0884` | 14 | [proc_45.pas](../../src/pascal/library_22/proc_45.pas) |
| library 22:46 | `$0886..$089E` | `$08A8` | 17 | [proc_46.pas](../../src/pascal/library_22/proc_46.pas) |
| library 22:47 | `$08AA..$08D7` | `$08E2` | 24 | [proc_47.pas](../../src/pascal/library_22/proc_47.pas) |
| library 22:48 | `$08E4..$09C4` | `$09DA` | 140 | [proc_48.pas](../../src/pascal/library_22/proc_48.pas) |

## Strings and text drawing

Library 10 copies an 80-character value parameter, captures its length, and
passes each byte to native 9. The captured loop limit and native-call order
remain intact. Library 44 sets bounds/mode and initializes external cursor
words 19/18/17. Library 45 advances to the next line and calls 44 on overflow.
Library 46 derives cursor coordinates from two scalar parameters. Library 47
checks horizontal bounds before and after drawing; external cursor and bounds
values are reread after calls, and no extra mode restore is introduced.

Library 48 also copies its 80-character value parameter before effects. It sets
mode 3 and interprets three delimiters: space is emitted only away from the
left margin; backslash advances a line only away from that margin; vertical bar
always emits a space. An ordinary run is collected without consuming its final
delimiter, moved to a new line when its six-pixel-per-byte width exceeds the
current boundary, then drawn byte by byte. The next outer iteration processes
the delimiter. These are the behaviors of this routine, not a generic wrapping
algorithm or repaired text layout.

The original local frame is retained: string copy in slots 2..42, counters in
43..46, unused words 47..48, 20-byte run buffer in 49..58, current byte in 59,
stop flag in 60, and captured print limit in 61. Compilation confirms 120 local
bytes and the same buffer/adjacent-variable offsets. No buffer enlargement,
truncation, or new check is added. Validation assumes runs fit the 20-byte
buffer; arbitrary overflowing runs are not claimed equivalent merely because
the frame layout matches.

Library 38 retains the original signed negation, decimal MOD/DIV loop, and
digit-prepend order. Zero still produces one digit, and the original 16-bit
negation behavior is retained for the most-negative integer. Library 39 selects
a one-character padding string and prepends it until the requested width is
reached, then calls 10. Width is not clamped to the 15-character destination.

String semantics were checked against the supplied runtime. SAS at
`pcode_primitives.s:$D94B..$D989` handles a byte-valued character or a string
pointer and checks the destination capacity. `system_core` procedure 23 at
`$05F2` appends only when the combined length fits its supplied capacity;
procedure 25 at `$0676` initializes an empty result and copies the requested
substring only when its range fits the source. The reference compiler emits
the same CXP 0,23/25 calls. For prepending, it copies the one-character prefix
with SAS before appending, instead of clearing a temporary and appending that
prefix first. Both constructions give the same temporary string here, followed
by the original SAS 15 capacity check. These runtime bodies remain authoritative;
they are not counted as newly recovered procedures.

## Game 8 storage and condition display

The parent has two parameter words and 118 local bytes, slots 3..61. The
[local declarations](../../src/pascal/game_8/locals.pas) retain raw storage where
meanings are unresolved. Four bounds records at slots 46..61 use the observed
four-word stride; earlier bounds views occupy slots 22..45. At this group's checkpoint the compile fixture
had an empty parent body. The [completion group](game_8_complete.md) now supplies
the recovered game8:1 and all remaining children.

Procedure 2 captures a bounds pointer, reads a byte from external word 60's
byte view, selects the original strict thresholds 64/128/192, and draws the
filled and remaining portions. Native drawing calls remain between their
original loads. Procedure 5 performs the same inclusive signed bounds test as
game 18:2 with its own four-word value parameter.

Procedure 6 copies both bounds and its 15-character caption before drawing.
The compiler places these copies in different local slots, but retains the
original order: MOV 4 first, then SAS 15. It draws the expanded border, selects
the inner bounds, computes the caption position using its byte length, emits
the caption, and selects mode 1.

Procedure 7 saves four external bounds words, draws `|Condition`, and extracts
four six-character labels from the exact 24-byte text
`Vigor Rest  HealthNoursh`. It retains trailing spaces and the original spelling.
The first loop builds the four bounds; the second draws their values. It then
draws `Sleep`, restores only the saved bounds via MOV 4, and sets parent slot
15. It does not restore other drawing state. Its explicit six-character label
local adds a SAS 6 after the runtime substring call; all four requested ranges
are exactly six characters and within the constant source.

Library 43, needed by game 8's entry loop, is also recovered. It obtains new
coordinates through 61, redraws only when a coordinate differs, performs the
two VAR stores in order, and rereads both arguments for the second draw. This
retains aliasing behavior when both outputs designate the same word.

## Verification and next dependencies

All 58 maintained bodies compile without diagnostics. Parameter byte counts
and lexical levels match original metadata. Game-18 parent/global sizes are
unchanged, and the new game-8 parent is 118 bytes. The five earlier exact body
matches still pass; no new exact-body match is claimed for this group.

The existing [fixture](checks/game_18_compile.pas),
[receipt](checks/game_18_receipt.json), and [verifier](checks/verify_game_18.py)
now include game 8. In addition to the [existing commands](game_18.md#validation-and-reproduction),
rebuild its source component before running the verifier:

```sh
ca65 -I src/pcode -o build/decompile/game_18/game_8.o src/pcode/game_8.s
ld65 -C src/pcode/game_8.cfg -o build/decompile/game_18/game_8.bin \
  build/decompile/game_18/game_8.o
```

The verifier checks string-copy prefixes, the formatter's frame and buffer
offset, game 8:6's copy order, and game 8:7's constant labels and final bounds
restore. These checks supplement static path review; they do not run native
drawing, the game, or a text-formatting simulation.

Game 8:1 still requires other game-8 bodies and library 27/24 dependencies.
The inspected inventory allocates 152 bytes for DATASEG31, which those future
routines use; it has not been replaced with guessed global declarations in this
group. Game 18:23 and the full recovery inventory remain outstanding.
