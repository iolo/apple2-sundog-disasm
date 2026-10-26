# Game21 map, placement, selection, and update recovery

Recovered directly from `src/pcode/surface_maps.s`: all41 procedures, covering4,567
original instructions. The enclosing entry includes all40 child bodies. The
continuations also recover library22:6, library23:1, native interfaces23:2–4,
and the raw-call contract for native22:25.

## Storage and interfaces

The recovered parent has eight VAR integer parameters and114 local bytes,
matching the original frame. Startup_disk1 `$00F8..$0108` passes the eight
addresses. Parent slots9..65 retain raw access; slot55 holds the map address,
slots39/47 hold distinct16-byte glyph buffers, and slots62..65 hold bounds.
The map view has24 rows of40 bytes, matching `IXA20` and byte indexing.

The six-word location views used by game19 and game21 now live in shared
`shared_game_state.pas`, preserving the existing declarations and storage extent. Raw
six-word views remain for whole-location transfers, including spare bits.
Naming these views does not establish original record names or field meanings.
Nested procedures4,20,24 live inside3,19,23 respectively;34/35 live inside33.
Parent19 retains its28-byte locals because nested20 accesses slots5/4.
Parent33 retains bases at slots5/4 and appends polling temporaries afterward.
Parent38 retains22 local bytes, with shared button bounds at slots5..8 used by
nested39. `map_types.pas` adds the128-byte city-map view: four header words
followed by20 columns of12 nibbles, matching the three-word column stride.

## Reviewed behavior

- Procedures2–8,10–11,13 preserve single-wrap arithmetic, cached resource reads,
  coordinate low-bit tests, six-word value copies, clipped self EXIT, glyph
  order, packed writes, city-row capture, and the post-drawing result load.
- Procedures14–21 preserve both proximity calls before combined conditions,
  even when another condition already fails. Procedure16 rereads the VAR
  result through parent arg1. City60, edge priority, the six-word park/restore
  directions, and the `ABAA`/`OPOU` tables are retained.
- Procedure22 writes its ten bytes in the original order, leaving bytes10..15
  alone. Procedure23 keeps the two buffers distinct and rereads the glyph byte.
  Procedure25 retains the path that reads parent15 for both coordinates,
  rather than silently correcting it. Its expanding49-candidate search updates
  the counter/radius before probing and has no invented termination bound.
- Procedure32 draws rows6..17 and columns10..29, masks each map byte through
  native22:32, and preserves all16 case arms. The vertical drawing advance is7,
  while input conversion in35 divides the second coordinate by8.
- Procedure33 saves the first input result before the unconditional second
  input call, then rereads the VAR result after the loop. Procedure35 draws both
  old and new positions before storing either output; aliased outputs retain
  their original store order. Procedure34 reads parent bases5/4.
- Procedure37 retains the single base1000 borrow and `||Insufficient funds`
  caption. Timeout expiry does not suppress either input call. Procedure41
  keeps erase/update/cursor-refresh order before rereading the mode.

Arithmetic follows the listed16-bit operation order and SunDog's interpreter
semantics. Low-bit branches use `odd`, not nonzero tests. Pure comparisons may
short-circuit in compiled Pascal; effectful calls are explicitly sequenced.
Procedure32 omits only constant loop-bound temporaries. Procedure33 adds two
polling temporaries,37 adds three, and41 omits unused local storage. None of
these changes alters an evidenced frame access.

## Validation and limits

The [first fixture](checks/game_18_compile.pas) compiles230 recovered
bodies. Procedures223..244 map to the first22 game21 bodies;245..250 map to
32,33,34,35,41,37. Procedure222 is the empty game21 parent scaffold and is
excluded from coverage. That fixture is near the compiler's procedure
number limit, so the continuation uses the smaller fixture below.

The [receipt](checks/game_18_receipt.json) records hashes, mapping, frames, and
check scope. The [verifier](checks/verify_game_18.py) passes all230 interface
comparisons and eight exact-body comparisons. Game21:22 contributes a54-byte
exact body match; attributes and dictionaries are outside that comparison.
Focused checks cover the copies, low-bit branches, nested accesses, drawing and
polling order described above. All six newly added selection/payment/update
bodies were also reviewed in compiler disassembly against the original paths.

Compilation has only the previously documented game20:31 string-capacity
warning. The complete game21 fixture additionally warns about the intentional
checksum-failure goto described below. See the
[reproduction commands](game_18.md#validation-and-reproduction).
Native interfaces and data storage remain unbound to the original runtime.
No recovered Pascal runtime execution or whole-module equivalence is claimed.


## Map loading and teleport continuation

Nine further game21 bodies (9,26–29,31,36,38–39), library22:6, and library23:1
add1,226 instructions. This brought the inventory to241 recovered p-code bodies
covering21,498 instructions, and19 reviewed native interfaces before completion below. Coverage counts
shared dependencies once even when they appear in both compilation fixtures.

Procedure26 loads one of four128-byte city maps from a512-byte block. It saves
both random-state words, installs city-derived seed words, clears960 map bytes,
and visits columns10..29 with rows6..17 inside each column. Every cell consumes
a random value before clipping; hidden cells therefore still affect the sequence.
The original random state is restored before cache and viewport updates.
Procedure28 similarly decodes one256-byte planet-map half, randomizes tile13 in
column-major order, then restores random state. Native23:2 also rotates and
writes the packed source bytes; its input is not read-only. City markers are
written even on cache hits. Special city60 can retry random placement without
a fixed attempt limit. Destination addresses are captured before random calls.

Procedure9 retains five-word renderer calls, then draws the six-word location
from DATASEG29 word72. Procedures27/29 retain cache/regeneration selection and
timing values. Library22:6 fills8192 bytes at address8192 with byte128; its whole
17-byte body matches. Procedure31 keeps six XOR rectangle steps and either the
45-iteration delay or the signed sound arguments. Procedure36 probes after each
y decrement and retains the input4 call whose result is immediately overwritten.

Procedure38 charges before destination selection and restores both saved money
words when selection is cancelled. Its literal captions, nested39 string copy,
shared bounds, cursor operations, and final glyph redraw retain their order.
Two original unchecked paths remain visible:26 reads uninitialized found
coordinates if flag28 is set without finding tile12 (or regeneration is skipped);
38 reads its deposit flag at local slot2 before any write if input0 has not set
it. No defaults or repairs were added. Source review describes these reads;
it does not establish deterministic behavior for uninitialized storage.

### Native library23 contracts

The native source is still authoritative in `src/pcode/tile_rendering.s`:

| Procedure | Caller words | Native cleanup and effects |
| --- | ---: | --- |
| 2 | 2 address words | Pops6 bytes including the return address; writes960 destination bytes and mutates packed source bytes. |
| 3 | 5 words | Pops16 bytes including the return address, consuming four extra stack bytes beyond the five arguments; draws through the fixed scanline tables. |
| 4 | 4 coordinate words | Pops10 bytes including the return address; XORs rectangle edges using the low coordinate bytes. |

Procedure3's extra bytes go to unused zero-page locations `$0C..$0F`.
Both active game21 call sites and the retained alternate9 call site push five
words. The native prologue at `$00B6..$00BF` consumes16 bytes, and its epilogue
at `$0196..$019C` restores only the return address. Interpreter native dispatch
at `$E155..$E186` does not normalize that cleanup. The Pascal declaration keeps
the evidenced five-argument call and explicitly requires the extra consumption
when binding the original native body; ordinary external linking alone does
not establish this requirement. No two invented arguments or replacement
renderer are supplied. Library23's sole p-code entry is an actual return-only
body, not a placeholder.

### Continuation checks

The [smaller fixture](checks/game_21_compile.pas) now contains205 recovered bodies,
including all41 game21 bodies, their reviewed dependencies, and the remaining
library22/24 group described in the [library notes](library_24_resources.md#shared-library-completion),
and the [complete game16 scope](game_16_helpers.md), plus
[all16 game15 bodies](game_15.md), [all12 game14 bodies](game_14.md), and
[game13 procedures2–11](game_13.md). Game13 scaffold225 is excluded from coverage.
Game21's recovered parent is procedure62; main1 and the external game8 interface remain compile-only
scaffolding and are excluded from coverage. Game8's actual body is checked in the
first fixture. The
[receipt](checks/game_21_receipt.json) records the complete mapping and hashes.
It compiles with the expected goto warning. Both verifiers pass; the additional exact
matches are library22:6 (17 bytes), library23:1, library22:1, and library24:1
(the latter three are2-byte return-only bodies), plus game16:15
(the20-byte VAR byte-reader) and game16:25 (the10-byte nested threshold setter).
All new bodies were reviewed in compiler disassembly against their original
paths. Focused checks also pin seed copies, nibble stride, random-call order,
map addresses, native cleanup, captions, refund copies, and discarded polling.

From the repository root (the first fixture's component binaries are produced
by the [existing commands](game_18.md#validation-and-reproduction)):

```sh
mkdir -p build/decompile/game_21
ca65 -I src/pcode -o build/decompile/game_21/library_23.o src/pcode/tile_rendering.s
ld65 -C src/pcode/tile_rendering.cfg -o build/decompile/game_21/library_23.bin \
  build/decompile/game_21/library_23.o
../../tmp/ucsd-psystem-xc/build/ucsdpsys_compile/ucsdpsys_compile \
  --p-machine=ii.1 -f no-range-check -f no-efj-nfj \
  -o build/decompile/game_21/check.code docs/decompilation/checks/game_21_compile.pas
../../tmp/ucsd-psystem-xc/build/ucsdpsys_disassemble/ucsdpsys_disassemble \
  --p-machine=ii.1 -o build/decompile/game_21/check.dis build/decompile/game_21/check.code
# Also build game16, game15, game14 and game13 using their component notes.
python3 docs/decompilation/checks/verify_game_18.py
python3 docs/decompilation/checks/verify_game_21.py
```

No original assembly, decoder, disk reconstruction, or native implementation
changed. Runtime equivalence and runnable binding remain untested.


## Game21 completion

Procedures1,12,30,40 add1,304 original instructions. This brought recovery to245 of570
p-code procedures, covering22,802 instructions, with20 of38 native interfaces
reviewed. Game21 is complete as reviewed source. See the [progress index](README.md)
for current totals after subsequent library work.

- Procedure12 preserves full-step, horizontal-only, and vertical-only probe
  order. A blocked doubled step retries at one pixel. Horizontal scrolling has
  priority over vertical scrolling. Leaving city bounds calls11 and explicitly
  exits12 before viewport updates. The30-byte local frame is preserved.
- Procedure30 preserves two checksum attempts, advances the checked block by8,
  skips48, and clears2048 bytes at20480 after a successful check. Failure displays
  the original code and loops permanently at `$1401`; it does not return an
  invented error result. Captured pointers, packed location reads, shared mode
  writes, both discarded input polls, and the8-byte local frame retain their order.
- Procedure40 writes the map byte and then its modulo16 value through the VAR
  argument. Its decremented counter controls movement through bit0, so the
  gate is `odd(ticks) or every`, not `ticks <> 0`. A blocked foe move erases the
  cursor and retries the same deltas before declaring capture. The second
  outcome random call is conditional. The48-byte frame is retained; unused slot5
  holds explicit random results for compiler compatibility.
- Procedure1 loads segments8/27/23 before setup and releases23/27/8 afterward.
  Input1 skips the movement/timer path. The input-state comparison at `$1E96`
  uses typed `NEQ6`: interpreter `$DE42..$DE46` routes to `$DF5A..$DF6C`, which
  masks both words to bit0. Every clock update consumes one random value even
  when mode/flag forbids encounters; those predicates precede the random call,
  while parent35 is read afterward. Unused parent slot24 holds that result,
  preserving the114-byte frame. The original exit attribute points at `$1F45`,
  so nonlocal EXIT requires a runtime binding to the release epilogue as well.

Native22:25 (`$0F44..$0F58`) removes the target address, patches its jump, and
passes the remaining stack to that target. Its arity is target-dependent. The
[declaration](../../src/pascal/graphics_and_io/native_call_interfaces.pas) describes
this evidenced use: a VAR result word followed by the loaded checksum entry at
parent9+64. The [checksum source](../../src/native/disk_checksum.s) consumes that
one result address and writes independent modulo256 even/odd byte sums of
`$4000..$4FFF`. The existing [checksum analysis](../disk-checksum.md) identifies
the loaded block and table. No replacement checksum routine or generic raw-call
implementation was added.

All four bodies were reviewed against every original instruction path and their
compiler disassembly. The verifier additionally checks preserved local sizes,
self EXIT targets, probe call sites, low-bit branches, random-call sites, two
checksum attempts, the permanent backedge, and native trampoline bytes. The
first fixture recompiles to its previous identical output; only two shared
source comments changed. These are static and compilation checks, not execution
of the recovered program. Native calls, external storage, and segment-release
bindings remain unlinked.
