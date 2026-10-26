# Library 27: item table, selection, and drawing

All 15 p-code bodies in library 27 are now recovered, together with library
22:13/21 and native interfaces 22:23/32/33. This adds 17 bodies and 954 original
instructions: total coverage is 75 of 570 bodies, 5,011 instructions, and 14 of
38 native interfaces. Game 8 and the full plan remain incomplete.

The source component's SHA-256 is
`90687f83d0ea2ae33be2e211b686b174fbf7cee15b886cebb52884f4ce687c80`.
Physical disk mappings are in `src/pcode/item_panels.adopt.json`. Assembly revision
is `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`. Library-22 identity is recorded in
the [first group](game_18.md). Findings are static; no emulator was run.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 27:1 | `$0624` | `$062E` | 1 | [item_panel_library_entry.pas](../../src/pascal/item_panels/item_panel_library_entry.pas) |
| 27:2 | `$0000..$0037` | `$0042` | 33 | [read_item_panel_position.pas](../../src/pascal/item_panels/read_item_panel_position.pas) |
| 27:3 | `$0044..$0081` | `$008C` | 35 | [plot_item_icon.pas](../../src/pascal/item_panels/plot_item_icon.pas) |
| 27:4 | `$008E..$00B5` | `$00C0` | 29 | [select_item_icon.pas](../../src/pascal/item_panels/select_item_icon.pas) |
| 27:5 | `$00C2..$00F2` | `$00FC` | 33 | [append_panel_item.pas](../../src/pascal/item_panels/append_panel_item.pas) |
| 27:6 | `$00FE..$0148` | `$0154` | 51 | [draw_panel_items_after.pas](../../src/pascal/item_panels/draw_panel_items_after.pas) |
| 27:7 | `$0156..$01D6` | `$01E0` | 97 | [replace_panel_item.pas](../../src/pascal/item_panels/replace_panel_item.pas) |
| 27:8 | `$01E2..$0241` | `$024E` | 73 | [find_panel_item.pas](../../src/pascal/item_panels/find_panel_item.pas) |
| 27:9 | `$0250..$026A` | `$0274` | 12 | [write_item_caption.pas](../../src/pascal/item_panels/write_item_caption.pas) |
| 27:10 | `$0276..$02BA` | `$02C4` | 44 | [show_item_description.pas](../../src/pascal/item_panels/show_item_description.pas) |
| 27:11 | `$0346..$03DB` | `$03E6` | 107 | [apply_item_action.pas](../../src/pascal/item_panels/apply_item_action.pas) |
| 27:12 | `$03E8..$041C` | `$0426` | 34 | [draw_empty_item_marker.pas](../../src/pascal/item_panels/draw_empty_item_marker.pas) |
| 27:13 | `$044E..$0614` | `$0622` | 279 | [setup_item_panel.pas](../../src/pascal/item_panels/setup_item_panel.pas) |
| 27:14 | `$02C6..$0338` | `$0344` | 66 | [apply_matching_item_effect.pas](../../src/pascal/item_panels/apply_matching_item_effect.pas) |
| 27:15 | `$0428..$0442` | `$044C` | 19 | [append_inventory_item.pas](../../src/pascal/item_panels/append_inventory_item.pas) |
| 22:13 | `$0196..$01C1` | `$01CC` | 20 | [set_line_mode.pas](../../src/pascal/graphics_and_io/set_line_mode.pas) |
| 22:21 | `$0254..$0281` | `$028C` | 21 | [select_drawing_buffer.pas](../../src/pascal/graphics_and_io/select_drawing_buffer.pas) |

## Storage and interfaces

The existing Pascal inventory records DATASEG31 as a 152-byte allocation.
The [storage views](../../src/pascal/item_panels/types.pas) retain all 76 words,
with overlapping bounds at words 2 and 6, and 28 two-word entries starting at
word 17. Each entry's first word contains second-coordinate offset in bits0..7
and first-coordinate offset in bits8..15. Its second word contains an item code
in bits0..7 and an unmodified high byte. Packed stores preserve adjacent fields.

Word 1 contains an existing address. Procedure 10 masks an index to 0..31,
loads that address, and indexes with an eight-word stride. A pointer view of
32 `string[15]` entries captures that contract without allocating or copying a
new table. Procedure 13 writes the original address 5632 into word 1. The
fixture does not supply runtime contents at that address.

The [additional native declarations](../../src/pascal/graphics_and_io/native_table_interfaces.pas)
come directly from the native bodies. Procedure 23 at `$0EFE` consumes a value
and destination address, writes two bytes, and returns no result. Procedures
32/33 at `$0FE0/$1008` consume two arguments and four reserved result bytes;
both combine the complete words with AND/OR respectively and return one word.
They remain native dependencies, with no substitute implementations.

Library 22:13 writes drawing-mode words 366/358 with the original signed
thresholds. Procedure 21 swaps words 355/356 for value zero; otherwise it calls
native 23 to write one selected word. Library 27 uses the zero-value swap around
several drawing operations; those calls must remain even on paths with no items.

## Reviewed behavior

Procedure 2 obtains two contiguous input words, adds DATASEG31 origins, applies
the ordered clamp helper, then writes both VAR outputs sequentially. Procedure
3 forces the first coordinate's low bit using native OR and makes four ordered
position/glyph calls. Procedure 4 derives the four glyph words with the original
signed MOD and arithmetic.

Procedure 5 increments the count only below 28, then writes the selected entry.
A full table overwrites entry 28. It stores the code modulo 256 first, then the
two coordinate fields; the spare byte is retained. Procedure 6 captures the
count and origins once, draws the entries following its argument, and performs
the final drawing-state swap even when the loop is empty.

Procedure 7 captures an entry pointer and reads coordinates before checking
whether the index exceeds the current count. That ordering has not been
"repaired." It writes the old-code output, changes the entry code, optionally
updates DATASEG29's four bytes at word 62, then performs the original drawing
and output-store sequence. Later reads of VAR outputs remain reads, including
when outputs alias each other or the entry table. Procedure 8 initializes its
two outputs in order and finds the first entry with strict distances below
10 and 8. Both distance-helper calls execute before the combined condition;
the successful index store precedes the code load/store.

Procedure 9 copies its bounded caption before clearing/drawing. Procedure 10
chooses that caption from the pointer table, and for codes 11/13 appends the
shifted numeric suffix only when positive. Procedure 12 draws a plus glyph for
indices strictly greater than word14 and at most word15. Procedure 15 copies
one DATASEG29 byte into a new entry and draws that marker only when it is zero.

Procedure 11 retains parent slots5..12 for nested procedure14. It dispatches
actions0/1/2, updates a condition byte with an ordered 0..255 clamp only after
a matching helper sets the change flag, sets external flag60, optionally clears
the caption/code, and swaps drawing state before its final draw. Uninitialized
amount/change locals are never read on the unchanged path.

Nested procedure14 matches one base code, sets flags and signed change, then
either sets one byte to100 or adjusts bytes1..3 at DATASEG29 word48. Each random
update reads its old byte before native3 and subtracts `3 + (random AND 7)`.
Explicit locals preserve that value across calls. The destination index is
reread afterward; native3 changes random-state words21/22 and native32 combines
arguments, so neither changes that lexical-parent index. Byte truncation and
signed arithmetic remain the original operations.

Procedure 13 keeps its integer mode. The first conditional tests bit0; subsequent
branches compare the full word with0/1/2. It draws the original glyph grid,
retains every position call (which can draw in the active mode), sets bounds and
the caption-table address, constructs entries in the original order, and fills
the final region. Procedure 1's empty Pascal body corresponds to its actual
single `RNP 0` instruction and is not an unrecovered placeholder.

## Validation

At this delivery all 75 recovered bodies compiled without diagnostics. New
parameter sizes and lexical levels match the original metadata. The checking
fixture preserves DATASEG29 positions; DATASEG31 follows it at global slot383,
for 912 total data bytes. Later groups can relocate procedure IDs; the current
mapping, including nested14 inside11, is in the [receipt](checks/game_18_receipt.json).

Most new local frames match exactly. Procedure8 uses eight local bytes instead
of four to retain both comparison results; nested14 uses four instead of two
to retain its byte/random values while omitting the constant loop bound;
procedure13 uses16 instead of18 by omitting captured constant bounds and reusing
WITH-pointer storage. No original caller can address these local temporaries.
The compiler expands packed-record indexing into multiplication followed by
`IXA 1` with the same two-word stride. Pure comparison short-circuiting, host
global accesses, relocated calls, and constant folding are explained differences.

The five earlier exact body matches still pass. Library27:1 also matches its
two-byte return body; this trivial match adds no evidence for other routines.
The focused verifier additionally checks packed-store order, retained VAR reads,
both distance calls, pointer loading/stride, caption copying, nested random-call
order, and the mode low-bit branch. These are scoped checks supplementing manual
path review, not an equivalence proof or runtime test. Validation assumes valid
Pascal storage and initialized table context, not arbitrary out-of-bounds calls.

Use the [fixture build commands](game_18.md#validation-and-reproduction), including
assembly of this component before the verifier:

```sh
ca65 -I src/pcode -o build/decompile/game_18/library_27.o src/pcode/item_panels.s
ld65 -C src/pcode/item_panels.cfg -o build/decompile/game_18/library_27.bin \
  build/decompile/game_18/library_27.o
python3 docs/decompilation/checks/verify_game_18.py
```

The next work is recovery of game 8's remaining callers and library24 dependencies.
Original assembly and disk reconstruction inputs remain unchanged.
