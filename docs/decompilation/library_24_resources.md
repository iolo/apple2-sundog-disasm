# Library 24: record checks and resource updates

The initial group recovered library24 procedures7/8/11/14–17 and native interface22:4:
seven bodies and755 original instructions. It brought coverage to92 of570 bodies,
6,480 instructions, and15 of38 native interfaces. Subsequent [update work](library_24_updates.md)
and the completion below finish all14 p-code bodies and3 native contracts.
The full plan remains incomplete; the [progress index](README.md) has current totals.

The rebuilt library24 component has SHA-256
`acaadfd85907933575a035fe67f716630e3c3695430008f90a4b48ea6b1fd68c`.
Its disk extents are recorded in `src/pcode/library_24.adopt.json`. Assembly
revision remains `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`. All findings are static.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 24:7 | `$00F8..$013F` | `$014A` | 50 | [proc_07.pas](../../src/pascal/library_24/proc_07.pas) |
| 24:8 | `$014C..$0261` | `$0272` | 197 | [proc_08.pas](../../src/pascal/library_24/proc_08.pas) |
| 24:11 | `$0274..$02A8` | `$02B2` | 42 | [proc_11.pas](../../src/pascal/library_24/proc_11.pas) |
| 24:14 | `$0AAC..$0AC1` | `$0ACC` | 20 | [proc_14.pas](../../src/pascal/library_24/proc_14.pas) |
| 24:15 | `$0BE2..$0DF4` | `$0E04` | 291 | [proc_15.pas](../../src/pascal/library_24/proc_15.pas) |
| 24:16 | `$0ACE..$0B4C` | `$0B58` | 72 | [proc_16.pas](../../src/pascal/library_24/proc_16.pas) |
| 24:17 | `$0B5A..$0BD6` | `$0BE0` | 83 | [proc_17.pas](../../src/pascal/library_24/proc_17.pas) |

## Storage and native interface

The existing DATASEG29 view now overlays a clock at word 78, two two-word stock
entries at 234, two 16-byte string slots at 238, and bounds at 311/315/319. These
views remain within the known 760-byte allocation. Stock entries expose only
their five-bit kind field; other bits and the second word are retained. The
two-entry extent follows nested16's loop over indices 1 and 2, not an invented
complete inventory schema.

Bounds fields use names `bnd311`, `bnd315`, and `bnd319`, distinct within the
compiler's first eight significant characters. Emitted addresses are checked
individually: fixture globals 313/317/321. Merely compiling longer names that
shared an eight-character prefix did not establish correct field resolution.

[Native22:4](../../src/pascal/library_22/native_world_interfaces.pas) at `$0D26`
pops 16 bytes including the return address, consumes seven argument words, and
returns no result. The original body accesses the speaker and its own mutable
state. Its arguments retain ordinal names because the observed constants do
not establish their units. The interface is unlinked in the checking fixture;
the native implementation remains authoritative.

## Helpers and record checks

Procedure7 copies its four-word bounds before testing state nibble 2. For states
0/1 it computes an edge with the original native right shift, draws each region
only on its strict comparison (`edge > lower`, `edge + 1 < upper`), then selects
external bounds7. No drawing or bounds reset occurs on the other state path.

Procedure8 scans the original 28-byte record layout at external word90. It
evaluates four rows using shared expected bytes, code 23, the special column,
and the match code; writes each row's remaining count and their total; then
updates the original three flag bands and selected words 222/226/224. All byte
offsets, branch precedence, and store order are preserved. Names describe loop
roles; the complete logical meaning of these records remains unresolved.

Procedure11 reads its VAR argument before calling the random generator, then
applies MOD, the native shift, and ordered lower/upper tests using `4-word214`.
It adds no repair for an invalid divisor or reversed bounds. Procedure14 retains
both signed multiplications and the exact comparison before writing its VAR
result. Its 23-byte body matches the original exactly, including the return.

## Resource updater and shared lexical state

Procedure15's first phase tests bit0 of external word 352, not nonzero. Later
phases compare its full value with 2/3/4. It retains signed deltas, costs, native
shift/random calls, state flags, and calls to nested17 in their original order.

Nested17 copies its bounds before subtracting the cost from the parent's VAR
amount. It calls nested16, updates the target through its VAR address with the
original 0..255 clamp, draws through7, and optionally draws a marker line. The
target is reread after writes and calls; aliased outputs are not cached away.

Nested16 uses parent slot 15 as its index. For nonpositive amount it searches
at most two stock entries when flag 7 allows it, consumes at most one matching
entry, adds 255, clears that entry's kind and label, and sets the index to 3.
It clamps a still-negative amount to 0 afterward.

The caller also uses slot 15 to save external word 223 before calling nested17,
and reads that same slot afterward in a flag-setting condition. Nested17 can
call16 and overwrite it. The Pascal intentionally retains this shared local;
introducing a separate saved-value variable would change behavior. The 30-byte
parent frame and lexical stores/loads verify that relationship.

The final timestamp test executes even when flag 25 is false. The source saves
the flag first, always calls 22:27 with a value copy of clock78, then combines
the two results. On success it sets amount 255, calls native22:4, and performs
the original subsequent flag/global updates. An ordinary short-circuit AND
around the function call would omit an original call and is not used.

## Verification

At that milestone, all92 recovered bodies compiled without diagnostics. New parameter widths and
lexical levels match original metadata. Procedures7/8/14/15/16 have matching
local sizes. Procedure11 uses six local bytes instead of four to retain the
pre-call value and random result explicitly. Procedure17 uses 12 instead of 14,
omitting an unread local word. Fixture globals remain 912 bytes.

The [receipt](checks/game_18_receipt.json) currently maps fixture native 95 to 22:4 and
procedures 96–102 to this group. The [verifier](checks/verify_game_18.py) checks
value-copy prefixes, all three bounds addresses, shared slot 15 across the
nested call, stock-field/string offsets, the low-bit phase gate, unconditional
timestamp evaluation, and the VAR read before random3. Procedure14 is a new
exact body match; the six earlier matches still pass. Short-circuiting of pure
comparisons, fixture global accesses, relocated calls, and packed-array index
expansion are reviewed differences. There is no runtime execution or general
equivalence claim; valid caller storage remains an assumption.

Use the [fixture commands](game_18.md#validation-and-reproduction), now including:

```sh
ca65 -I src/pcode -o build/decompile/game_18/library_24.o src/pcode/library_24.s
ld65 -C src/pcode/library_24.cfg -o build/decompile/game_18/library_24.bin \
  build/decompile/game_18/library_24.o
python3 docs/decompilation/checks/verify_game_18.py
```

Library24:12/13, native24:4, library24:9, and game8's remaining update callers
were subsequently recovered in the linked update/completion groups. Assembly
and disk-build inputs are unchanged.


## Shared-library completion

The remaining seven p-code bodies add179 original instructions. Library22 now
has all45 bodies and18 native contracts reviewed; library24 has all14 bodies and3
native contracts reviewed. This brought the full plan to252 of570 recovered bodies,
22,981 instructions, and24 of38 reviewed native interfaces. See the
[progress index](README.md) for subsequent totals. These
are static source/interface claims; no new runtime execution was performed.

| Procedure | Entry through return | Instructions | Recovered behavior |
| --- | --- | ---: | --- |
| 22:1 | `$0BEA` | 1 | Original return-only entry. |
| 22:20 | `$022C..$0247` | 17 | Store the selected raw buffer address, then read two blocks at relative index `pair*2`. |
| 22:54 | `$0BB6..$0BDE` | 18 | Select graphics, load the row-table block, call its raw initializer, then reset global20 and buffer addresses. |
| 24:1 | `$0E5C` | 1 | Original return-only entry. |
| 24:2 | `$0040..$009A` | 69 | Circle stepping with signed16-bit native shifts and the original strict decision test. |
| 24:10 | `$0000..$0034` | 29 | Four symmetric pixel calls, nested in24:2. |
| 24:6 | `$00A8..$00E9` | 44 | Sum three squared packed-coordinate differences, then call22:36 for its rounded integer root. |

Procedure22:20 uses the selector's low bit, stores through native23 to
DATASEG29 word355 or356, and only then calls53. The disk wrapper adds3 to the
relative block; it still reads1024 bytes. Procedure54 preserves native55 before
I/O, passes the address of global20 followed by3904 to the raw-call trampoline,
and clears global20 only after that target returns. It then sets global373 to
6144 and372 to16384. The loaded target is identified by the existing
[raw screen initializer analysis](../raw-screen-init.md); its pointer argument
is consumed but unused. A separate `callinit` declaration keeps this contract
distinct from game21's checksum target, though both bind through native22:25.

The circle parent retains its6-byte local frame and center arguments at slots2/1
for nested10. Each octant pair calls10 twice; the final equal-offset case also
calls it twice. Each call performs all four pixel writes, including coincident
points. These duplicates matter under XOR drawing. Negative and zero radii keep
their original paths; no clamping or deduplication was introduced. The distance
routine retains nibble indices0..2 at word8 of20-byte rows. Two additional local
address views expand its locals from6 to10 bytes without nested consumers.
The subtraction, square, accumulation, and final helper call retain16-bit order.

### Remaining native contracts

- [22:8](../../src/pascal/library_22/native_display_interfaces.pas) consumes two
  coordinate words and returns no Pascal result. It reads shared drawing modes,
  uses fixed row tables, and may plot one or two pixels. Its second coordinate
  uses only the low byte; no new clipping is implied.
- 22:55's public entry is only `$1600..$1606`: reads `$C054`, reads `$C050`,
  then returns without arguments. Its subsequent `$1607` helper and lookup
  tables are dependencies of other native graphics code, not extra arguments.
- [24:3](../../src/pascal/library_24/native_effect_interfaces.pas) consumes one
  selector word. Low bits choose XOR7F, fillFF, or fill00; bit2 enables speaker
  reads. It writes the twelve table-defined shapes through the HGR row tables.
- 24:5 consumes no Pascal arguments. It reads stride/run data at `$4000` and
  writes columns beginning at `$2000`. Repeat and literal runs retain their
  native counts and destination-boundary handling. Game15 loads the encoded
  input before calling it. No replacement decoder or invented status is added.

The [second fixture](checks/game_21_compile.pas) checked88 recovered bodies at this milestone;
new declarations/bodies are appended so existing game21 procedure numbers stay
stable. The [receipt](checks/game_21_receipt.json) pins their source hashes, original
component hashes, mappings, and frames. Both verifiers pass. Compiler disassembly
was reviewed for every new p-code body; focused checks retain buffer-store/I/O
order, initialization-call/reset order, nested center accesses, all four plot
calls, signed shift arithmetic, packed coordinate differences, and native stack
contracts. The two new return-only entries match their original two bytes,
bringing the combined total to eight substantive and four return-only matches.

The only second-fixture compiler diagnostic remains the intentional game21
checksum-failure goto warning. Native code, raw loader targets, and external
storage remain unlinked. Use the [existing second-fixture commands](game_21_map.md#continuation-checks)
with library24's component binary from the commands above. The next milestone is the [game16 helper group](game_16_helpers.md);
full-plan progress remains recorded in the inventory.
