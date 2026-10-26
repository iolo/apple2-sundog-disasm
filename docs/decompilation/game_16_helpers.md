# Game16 complete source recovery

All48 procedures are recovered directly from `src/pcode/dialogue.s`, including
the [enclosing entry](../../src/pascal/dialogue/run_dialogue_session.pas). Their bodies cover
3,856 original instructions. At game16 completion, recovery totaled
300 of570 p-code procedures,26,837 instructions, and24 reviewed native
interfaces; current totals are maintained in the [progress index](README.md).

## Storage and calling context

The parent has three value words and278 local bytes. Startup_disk1 `$0039..$003C`
and `$0140..$0143` pass three words to16:1. The recovered entry retains that
frame and includes all47 children. Raw slots4..142
preserve child accesses. The [frame view](../../src/pascal/dialogue/types.pas)
adds overlapping views only where these bodies establish their offsets:

- Four-word saved bounds at56/64, dialogue bounds at60, panel bounds at68, and button bounds at72
  with a four-word stride.
- Two-word amounts at100/102/104/106, followed by31-character strings at108/124.
- A15-character prefix view of108 for library22:38's VAR formatter interface.
- Address words140/141 for byte streams and tables. Thresholds starting at47
  remain raw parent words, preserving reads beyond the six slots written by31.

DATASEG31 reuses the existing152-byte view. Its word1 points to16-byte caption
rows; byte15 also supplies the pricing weight in2. Packed items start at word17
and retain two-word strides and three ordered byte-field writes. The compiler
uses only eight significant identifier characters, so the amount fields are
named `fund100` and `fund102`; emitted addresses independently confirm100/102.

## Reviewed behavior

- Procedure2 masks the item code, clamps shared slots5/4 before scaling, reads
  the raw row weight, chooses the original42/64/128 ceiling, then multiplies.
  Procedure3 distinguishes direct amount updates at100 from item-caption updates
  at124, writes the price at106, formats108, and appends ` Cr` through a34-char
  temporary before the original31-char destination assignment. The compiler
  copies the already formatted prefix directly into that temporary; the
  formatter limits it to15 characters, below the original first-append limit31.
- Procedure4 copies both amount words before changing graphics mode. Procedure5
  draws the encoded caption before masking its code. Procedures6/7 preserve the
  five-column item layout, captured packed-item address, store order, drawing
  origins reread after mode selection, zero stop meaning14, and non-incrementing
  zero/negative item codes. Both zero/false buffer-selection calls remain.
- Procedure12 adds256 for each crossed raw threshold without an invented scan
  bound. Procedure15 writes through its VAR destination before rereading and
  incrementing parent38; aliasing that index is preserved.
- Procedure31 reads the byte table before testing the inner index limit65, and
  rereads byte65 on loop exit. Procedure32 skips header16, copies records with
  MOVELEFT before storing their next byte offsets, advances odd source offsets
  to even, propagates trailing bytes forward, and rebuilds thresholds. Copy
  direction and the low-bit alignment test are retained.
- Procedure35 calls nested36 before testing the signed enable word. On selection
  it writes the VAR flag before sound/drawing, then updates parent35 and the VAR
  selection. Its loop rereads the flag. Nested36 captures the grandparent's
  rectangle address and preserves inclusive bounds. Procedure40 keeps the raw
  byte store at DATASEG29 word62 and its unused third argument.
- Procedures30/44 retain mode-dependent clock updates, unconditional random
  consumption per wait iteration, and input4 polling before the stop flag.
  Procedure45 copies/clears bounds around the clock display and wait. Procedure46
  retains ` no money`, ` Cr on hand`, and the original amount formatting choices.
- Procedure47 restores modes in order, transfers both cash words, restores saved
  bounds and bytes549/552, and preserves both discarded input4/input5 calls.
  Procedure48 retains the low-bit mode branch and unmasked flag-table index.

The parent frame and nested35/36 frames retain their original sizes. Procedure2
adds one raw-address local;44 adds one random-result local. Procedures5/31/46
omit unused locals with no nested consumers. Procedure47 uses its unused first
local for an address view. Procedure3 retains38 local bytes including its concat
temporary;6 retains10 including the compiler's captured item pointer. No native
implementation, decoder, or translation pipeline was added.

## Conditions, variant text, and names

Procedures8–11,13–14,16 add749 original instructions to the initial19 helpers.

- Procedure8 normalizes the encoded condition once, then dispatches cases0–20.
  Failed chance tests in1/16/17 can dispatch the fallback0, which sets the code
  to-1 to end the loop. Input0 instead returns1 without a random call. Negative
  input leaves the result unwritten. Cases4/6 return raw parent words20/18;
  callers that branch on them must test bit0. Case7 captures parent5/36 before
  its second random call. Case9 always calls the native mask helper, and case18
  always performs both chance tests, preserving random consumption.
- Nested9 writes its MOD100 result to8's original local slot8 before comparing
  it. Nested10 captures DATASEG29 byte94+index before calling9 and halves that
  captured byte afterward for index4, regardless of the test result.
- Procedure11 retries item selection with fixed bounds and the original packed
  flags. It captures eligibility before both unconditional8(30)/8(166) calls,
  then rereads the item before adding128. Direction uses parent18's low bit.
  Its24-byte frame is retained; unused locals hold evaluation temporaries.
- Procedure13 extracts a variant from table141. The skip scan deliberately has
  no remaining-length guard. High-bit bytes emit a converted byte plus a space;
  low-byte96 instead rereads the last output byte and terminates. A leading96
  therefore reads the destination's previous length byte. The length is stored
  only at the end. Raw writes have no added31-character clamp and can extend
  beyond the declared view, as in the original unchecked p-code. The `g16text`
  overlay provides both the string and its raw length/data bytes.
- Nested14 counts65..96 markers through13's original glyph slot4, then always
  calls random and reads the VAR divisor afterward. Procedure16 selects a name
  table with the random low bit, retries until the name differs from the current
  packed location, and retains20/16-byte row strides and SAS15 assignments.

Procedure8 keeps original slots4..8 and adds five temporaries;9 and14 each add
one random-result local. Procedure13 preserves its12-byte frame for14's lexical
access. Procedure16 adds one address-view local. These additions do not change
the shared ancestor slots. Original routines, compiler disassembly, and source
were reviewed together; the declarations retain the original parameter sizes
and lexical levels.

## Dialogue and interaction callers

Procedures17–29 add905 original instructions. Their original local-frame sizes,
parameter widths, and lexical levels are all retained. Forward declaration18
preserves the recursive18/21 relationship within17;22 remains nested in18.
Procedure25 is nested in24, and24/26–29 are nested in23.

- Procedure17 saves DATASEG29 bounds11, installs parent60's bounds, and restores
  them after the final flush. Its104-byte frame retains the shared buffer at13,
  next position5, first-flush state10, and capitalization state12. A high-bit
  stream byte is expanded and followed by a space. Procedure19 initializes the
  display on the first flush, writes the raw length, prints, and resets position1.
  The final flush is unconditional, including empty text.
- Procedure20 flushes on a space only when the position exceeds60. It subtracts32
  from any code>=97 while capitalization is set; there is no extra upper bound.
  Raw byte writes and buffer overflow behavior remain unchecked. Procedure18
  preserves the32..47 token table, recursive variant expansion, punctuation state,
  amount/item captions, and name substitution. The15-character name view aliases
  its31-character phrase buffer without an intermediate copy.
- Procedure21 makes the original SAS31 value copy before reading its length.
  Expanded text walks that copy with a saved limit. Literal text always sends
  byte1 through20, then performs MOVELEFT of length-1 bytes and adjusts position;
  no empty-string guard or invented replacement behavior is added. Procedure22
  extracts into18's slot3 and passes that same buffer to21.
- Procedure23 decodes the header, applies26's effects, and preserves its early
  self EXIT before dialogue/options. It saves/restores the stream cursor around17,
  consumes both trailing actions, disables unused buttons, and reads remaining
  captions/actions in order. Flag tests use the low bit after division, including
  bit1 tests that must not become quotient-nonzero tests.
- Procedure24 retains the inclusive threshold scan and consumes discarded bytes
  after a choice. Random selection reuses parent14 when parent15's low bit is set;
  otherwise it calls random before reading the VAR divisor. A zero divisor is
  not silently repaired. Conditional alternatives continue consuming the stream
  after selection and retain the final condition0 fallback. Nested25 writes
  threshold3 before limit2; its complete10-byte body matches the original.
- Procedure26 applies bit flags, clamps33, optionally resets/selects41, then
  updates the two-word amounts. Procedure27 stores the caption selector before
  drawing and the action afterward, captures the bounds pointer at local22,
  and reads the first label byte without a length guard.
- Procedure28 preserves all display/action cases, including parent23's work10,
  parent30 captured before the random price calculation, action-byte reads, and
  raw table indices. Its unused slots hold evaluation temporaries without changing
  the14-byte frame. Procedure29 reads a replacement only for positive conditions
  and tests8's result by its low bit before writing through the VAR argument.

These are recovered p-code routines operating on the existing dialogue data.
The dialogue data itself and its custom bytecode remain outside source-recovery
scope. No new translator or runtime implementation was introduced.

## Setup, trading, and enclosing entry

Procedures1,33–34,37–39,41–43 add1,387 original instructions and complete game16.

- Procedure33 keeps the VAR action rereads, flags, decimal amount-step loop,
  and amount comparison directions. The random flag index is captured before
  the random call. Procedure34 resets redirect21 on each dispatch, while its
  clock reset and enable22 initialization occur only once. It stores bank39
  before reading the block and repairing the table, and stores the rewritten
  action44 after the redirect loop.
- Procedure37 saves/restores context through the existing cleanup47, sets the
  two-word amounts and bounds, and captures the20-byte system-row pointer at
  local24. Its row view preserves word5 bit7, word8 nibble3, and word9 nibbles0/1/3.
  The amount at row word6 overlaps the caption bytes used by other views. The
  low-bit argument3 adjustment, four flag-range calls, repeated flag117 clear,
  pointer stores, block read, and table repair retain their order. Its backwards
  equal-offset scan has no invented lower bound. Mask calls in the item scan
  remain conditional and are repeated where the original repeats them.
- Nested38 fills an inclusive packed-flag range while incrementing the compared
  value. Nested39 preserves the mode12..23 dispatch, overlapping cash source,
  parent30 captured before random/mask/root calls, and the unconditional8(101)
  test before the one-time award decision. It adds one local word for the saved
  results; all other new routines retain their original local-frame sizes.
- Procedure41 retains its24-byte frame and the slots shared with42/43. It
  captures the target/mode predicates before the unconditional amount comparison.
  Both native mask calls run before the combined transfer test, even when the
  mode predicate is false. Input1 is polled on every loop iteration, including
  iterations that empty the held item. Unused argument1 and locals3/4 hold these
  temporaries without changing the shared frame. Nested42 transfers the price,
  updates ticks/count, dispatches the action, and retains both buffer selections.
  Nested43 captures the old item/origin before exchange and rereads transfer
  predicates afterward.
- Entry1 loads27 then28, calls setup37, and always executes both input polls
  while waiting for release. Previously unused slots25/142 hold their results.
  The main loop preserves timer actions, cursor updates, button/menu dispatch,
  and the input1 fallback. Normal return calls47 and releases28 then27. The
  original exit attribute instead targets `$1C8F`, immediately after47, so a
  nonlocal EXIT must release the segments without repeating normal cleanup.

The existing runtime declarations describe load/release calls but do not bind
this original nonlocal-exit epilogue. As with the other recovered entries, the
compile fixture's ordinary return metadata is not a substitute for that binding.

## Validation and limits

At game16 completion, the [second fixture](checks/game_21_compile.pas) checked156 recovered bodies,
including all48 game16 bodies and20 already-reviewed library22/27/28 dependencies
added for this component.
Its main DATASEG storage is912 bytes; DATASEG29's existing addresses stay fixed
and DATASEG31 follows it. Compiled137 is the recovered entry;138..176 map to the
previous39 children, and177..184 to33,34,37,38,39,41,42,43. The
[receipt](checks/game_21_receipt.json) records original hashes,
source hashes, frame attributes, and the full mapping.

Every new body and its emitted disassembly were reviewed against the original
instruction paths. Both [verifiers](checks/verify_game_21.py) pass. Focused checks
pin distinct amount addresses, string capacities, copy-before-mode behavior,
packed-field store order, nested bounds, boundary-read order, MOVELEFT and parity
alignment, cash transfers, discarded polling, unconditional chance calls,
negative-input result handling, nested lexical stores, text-marker writes, and
name-table selection. Further checks pin dialogue frame slots, recursive calls,
copy/flush order, captured bounds, low-bit header flags, and the self EXIT.
Completion checks pin row fields, bank/write order, repeated flag-range calls,
unconditional comparison/mask/input calls, load/release order, and the original
exit-attribute target.
Procedure15's complete20-byte body and25's complete10-byte body match exactly,
bringing the combined total to ten substantive and four
return-only body matches. This does not establish whole-module equivalence.

The only second-fixture diagnostic remains the intentional game21 checksum-failure
goto warning. Native bindings, data, and nonlocal-exit release handling remain
unlinked, and no recovered runtime execution is claimed.

From the repository root, add the game16 binary to the existing
[second-fixture commands](game_21_map.md#continuation-checks):

```sh
ca65 -I src/pcode -o build/decompile/game_21/game_16.o src/pcode/dialogue.s
ld65 -C src/pcode/dialogue.cfg -o build/decompile/game_21/game_16.bin \
  build/decompile/game_21/game_16.o
```

Library27/28 binaries use the [first-fixture commands](game_18.md#validation-and-reproduction).
The next component is [game15](game_15.md). At game16 completion,270 p-code
bodies remained; see the [progress index](README.md) for current totals.
