# First recovery group: game 18 and immediate library dependencies

These findings are static derivations from the assembly and supplied interpreter.
No new emulator session was run. Assembly revision:
`5c64227e095e86ba1e8c79b8e4425986cf9ae58f`.

| Component | SHA-256 | Provenance |
| --- | --- | --- |
| `game_18` | `452d8de86b4fc68e6c9827200418b67ca0f8a8c9fea1a86964baa667fafb37e4` | Disk 2, header block 140, segment 18, first block 218. Physical extents: `src/pcode/building_interiors.adopt.json`. |
| `library_22` | `7d52f0e6959d0a8b9ac3f08bc78ced7e7af44ed87a00d80d4d82025ab7735f49` | Shared library; physical extents: `src/pcode/graphics_and_io.adopt.json`. |

Offsets are segment-relative. Existing assembly/audits account for data and
attributes; those bytes are not counted as recovered instructions.

| Procedure | Entry through return | Attributes | Instructions | Pascal |
| --- | --- | --- | ---: | --- |
| game 18:2 | `$0000..$0016` | `$0020` | 20 | [inside_actor_area.pas](../../src/pascal/building_interiors/inside_actor_area.pas) |
| game 18:5 | `$0068..$00E2` | `$00F0` | 86 | [reindex_room_references.pas](../../src/pascal/building_interiors/reindex_room_references.pas) |
| game 18:15 | `$0AC2..$0B1F` | `$0B2A` | 58 | [set_service_indicator.pas](../../src/pascal/building_interiors/set_service_indicator.pas) |
| game 18:25 | `$1438..$148D` | `$1498` | 53 | [refresh_service_area.pas](../../src/pascal/building_interiors/refresh_service_area.pas) |
| library 22:14 | `$0088..$009C` | `$00A6` | 9 | [set_clip_bounds.pas](../../src/pascal/graphics_and_io/set_clip_bounds.pas) |
| library 22:19 | `$020C..$021F` | `$022A` | 15 | [apply_bounds.pas](../../src/pascal/graphics_and_io/apply_bounds.pas) |

## Calling convention and first function

`native_shared.s` at `$E18C..$E214` allocates a frame using local/parameter byte
counts, then pops parameter bytes into ascending addresses from `mark + 12`.
The last pushed word becomes frame slot 1. Local address/store handlers at
`$D315`/`$D33B` use `mark + 10 + 2*slot`. Return code at `$E38F..$E3A0` pushes
the requested result words from slot 1 upward. `RNP 1` returns one word; it
does not describe an argument count.

Game 18:25 at `$1449..$1452` pushes entry word 5, entry word 4, the address of
parent slot 103, and two zero words before calling procedure 2. Its second call
at `$1481..$148A` substitutes slot 99. Callers 12 and 26 use the same pattern
with slot 107. Procedure 2's frame is therefore:

| Slot | Evidenced role |
| --- | --- |
| 1 | Boolean result, written by `STL 1`, returned by `RNP 1`. |
| 2 | Reserved second word of caller-provided result storage; unread here. |
| 3 | Address of the incoming four-word aggregate. |
| 4 | Second scalar argument. |
| 5 | First scalar argument. |
| 6..9 | Local copy of the four aggregate words. |

`LLA 6; SLDL 3; MOV 4` copies eight bytes into local storage. MOV at `$D59B`
pops source before destination; `$E8AA..$E8CE` copies forward. This supports a
Pascal aggregate value parameter whose private copy is used in comparisons.
Signed LEQI at `$DF77..$DFA7`, its 0/1 result construction, and wordwise LAND
at `$D5AF` support the inclusive comparisons and Boolean result.

The aggregate's memory order is upper-second, lower-second, upper-first,
lower-first. Fields are declared separately: the inspected compiler reverses
allocation within grouped record-field declarations. Separate declarations
give the evidenced offsets. Recompilation has the same three-instruction
copy, eight local bytes, and ten parameter bytes.

## Shared storage and packed accesses

Game 18:1 has eight parameter bytes and 298 local bytes. Its local slots span
5..153. The [local declarations](../../src/pascal/building_interiors/locals.pas) preserve
that span; the parent's four parameters remain raw words. The
[completion group](game_18_complete.md) now supplies the full parent body.

| Storage | Evidence and interpretation |
| --- | --- |
| Parent slots 5..94 | Base slot 5 and `IXA 10`; nine 10-word storage views before slot 95, not proof of the original array declaration. |
| Entry word 7 | `LDP`/`STP` widths 1, offsets 2, 3, 5 in procedure 5; other bits and upper byte are preserved. |
| Parent slots 95..97 | Outer stride one word, `IXP 4,4` four-bit fields. Procedure 5 visits columns 0..1 in rows 0..2. |
| Parent slot 98 | `IXP 16,1` packed flags indexed by `index - 1`. |
| Parent slots 99, 103, 107 | Four-word value parameters passed to procedure 2. |
| DATASEG29 | Existing inventory: 760 allocated bytes. `shared_game_state.pas` overlays raw words, bounds at word 11, and flags starting at word 82, preserving aliases. |
| External flag 57 from word 82 | Word `82 + 57 div 16 = 85`, bit `57 mod 16 = 9`. The 128-bit view is an access view, not a recovered original declaration. |

Handlers `$DA1D`, `$DA60`, and `$DAB6` establish packed indexing, width, offset,
masking, and neighboring-bit preservation. WITH captures the entry address once
in procedures 5 and 25; compiled output retains a pointer across calls.

## Reviewed paths and dependencies

Procedure 5 visits the nibble table only when entry bit 2 is set. With
`clear_reference=true`, it clears bit 2, searches for `index`, and replaces
matches with zero. Otherwise it searches for `index+1` and replaces matches
with `index`. On both paths, a true `clear_reference` subsequently sets bit 5
and clears bit 3, even if bit 2 was initially false. The while loops retain the
observed visits/increment order. Upper nibbles and unmentioned bits remain
unchanged. Original bound temporaries contain constants 2 and 1 and do not
need semantic Pascal variables.

Procedure 25 clears external flag 57 before its first bounds test. Inside the
bounds it computes `((entry[5] - (parent[131] - 2)) div 28) + 1`, calling
procedure 15 with true only on equality with parent slot 111. The outside path
calls procedure 15 with false, then rereads entry words and tests the other
bounds before assigning flag 57. No loads move ahead of the effectful call.

Procedure 15 compares the requested Boolean with a packed parent flag. On a
change it computes four boundary words, calls library 22:14, invokes native
22:7 with parent slot 146 or 144, and updates the flag. Both paths then call
22:19 with the bounds at DATASEG29 word 11 and mode zero. Arithmetic grouping
is preserved; no reassociation of word arithmetic was introduced.

Library 22:14 writes its four arguments to external words 363, 362, 360, 361.
Its unused local word has no recovered semantic role. Library 22:19 copies its
value parameter before writing globals, passes the copied words in reverse
memory order to 22:14, and calls native 22:7 only for nonzero mode. Copy-before-
write preserves aliasing when the aggregate refers into DATASEG29.

Native 22:7 at `$11C4..$11CD` removes its return address and one 16-bit argument,
retaining the low argument byte. The zero-mode path restores the return address
and returns at `$11DC`; other paths perform native work. There is no Pascal
result. Global-relative operands `$02CE`, `$02D0`, `$02D2`, `$02D4` address the
boundary words 360..363. The original native body remains authoritative; the
[interface](../../src/pascal/graphics_and_io/native_interfaces.pas) introduces no
purity assumption or replacement implementation.

## Validation and reproduction

The [compile fixture](checks/game_18_compile.pas) includes the actual sources.
Its empty main and standalone data storage are scaffolding;
game8, game17, game18, game19, and game20 use their recovered entries and enclosing scopes.
It now includes the [second recovery group](game_18_dependencies.md),
[movement group](game_18_movement.md), [setup group](game_18_setup.md), and
[state group](game_18_state.md), [condition-display group](game_8_condition.md),
the [library-27 group](library_27.md), the [clock group](game_8_clock.md), and
the [resource group](library_24_resources.md), and the
[update group](library_24_updates.md), and [game8 completion](game_8_complete.md),
and [game18 completion](game_18_complete.md), plus the
[game17 helpers](game_17_helpers.md) and [completion](game_17_complete.md),
and the [game19 dependencies](game_19_dependencies.md) and
[completion](game_19_complete.md), and the [game20 warehouse group](game_20_warehouse.md),
plus [game20 completion](game_20_complete.md) and the [game21 group](game_21_map.md),
for230 recovered bodies. Game21 uses a compile-only parent scaffold.
The compiler reports the expected game20:31 string-capacity warning described
in its completion notes. Sixteen native interfaces
are external and unlinked, as are two explicit segment-runtime operations.
From the repository root:

```sh
mkdir -p build/decompile/game_18
../../tmp/ucsd-psystem-xc/build/ucsdpsys_compile/ucsdpsys_compile \
  --p-machine=ii.1 -f no-range-check -f no-efj-nfj \
  -o build/decompile/game_18/check.code \
  docs/decompilation/checks/game_18_compile.pas
../../tmp/ucsd-psystem-xc/build/ucsdpsys_disassemble/ucsdpsys_disassemble \
  --p-machine=ii.1 -o build/decompile/game_18/check.dis \
  build/decompile/game_18/check.code
```

`no-range-check` avoids checks absent from these original bodies. `no-efj-nfj`
suppresses generic opcodes `$D3/$D4`, rejected by SunDog's interpreter. This is
a syntax/layout/code-generation check, not a runnable game build. The fixture
uses host globals instead of external data, yielding SRO/LAO instead of STE/LAE.
Its data starts at global slot 3, so external word 85 appears as slot 87.

The [receipt](checks/game_18_receipt.json) pins source/output hashes and checked
frame sizes, including the current fixture-to-original procedure mapping.
Fixture procedures 2–12, 44–46, 71, and 79 are unlinked native interfaces;101/102 are
unlinked runtime operations. The 1,254-byte
global allocation (760 bytes DATASEG29, 152 bytes DATASEG31, 342 bytes DATASEG30),
298-byte game-18 parent locals, 118-byte game-8 parent locals, 196-byte game17
parent locals, packed
accesses, lexical levels, argument widths, and pilot instruction sequences
were checked. The initial compilation completed without diagnostics; the current
fixture retains only the documented game20:31 string-capacity warning.

The compiler short-circuits the pilot's Boolean expression. Its operands are
copied locals or scalar arguments, with no calls, indirect loads, arithmetic,
or effects. All four signed predicates and the final 0/1 result agree; skipping
later pure local comparisons changes no observable result/storage here. This
is a scoped static argument, not a general rule for other Boolean expressions.

Other explained differences: local numbering in procedures 5/15, constant loop
bounds instead of stored temporaries, omitted unused storage in 22:14, fixture
global accesses, procedure numbering, and alignment. Complete procedure-byte
equality is not claimed. Review assumes valid Pascal storage/caller context;
arbitrary out-of-bounds calls and native corruption are not covered.

Reproduce the source components used for analysis and verify the artifacts:

```sh
ca65 -I src/pcode -o build/decompile/game_18/original.o src/pcode/building_interiors.s
ld65 -C src/pcode/building_interiors.cfg -o build/decompile/game_18/original.bin \
  build/decompile/game_18/original.o
sha256sum build/decompile/game_18/original.bin
ca65 -I src/pcode -o build/decompile/game_18/library_22.o src/pcode/graphics_and_io.s
ld65 -C src/pcode/graphics_and_io.cfg -o build/decompile/game_18/library_22.bin \
  build/decompile/game_18/library_22.o
ca65 -I src/pcode -o build/decompile/game_18/game_8.o src/pcode/personal_panel.s
ld65 -C src/pcode/personal_panel.cfg -o build/decompile/game_18/game_8.bin \
  build/decompile/game_18/game_8.o
ca65 -I src/pcode -o build/decompile/game_18/library_27.o src/pcode/item_panels.s
ld65 -C src/pcode/item_panels.cfg -o build/decompile/game_18/library_27.bin \
  build/decompile/game_18/library_27.o
ca65 -I src/pcode -o build/decompile/game_18/library_24.o src/pcode/flight_and_effects.s
ld65 -C src/pcode/flight_and_effects.cfg -o build/decompile/game_18/library_24.bin \
  build/decompile/game_18/library_24.o
ca65 -I src/pcode -o build/decompile/game_18/game_17.o src/pcode/street_encounters.s
ld65 -C src/pcode/street_encounters.cfg -o build/decompile/game_18/game_17.bin \
  build/decompile/game_18/game_17.o
ca65 -I src/pcode -o build/decompile/game_18/library_25.o src/pcode/menus.s
ld65 -C src/pcode/menus.cfg -o build/decompile/game_18/library_25.bin \
  build/decompile/game_18/library_25.o
ca65 -I src/pcode -o build/decompile/game_18/library_28.o src/pcode/amount_arithmetic.s
ld65 -C src/pcode/amount_arithmetic.cfg -o build/decompile/game_18/library_28.bin \
  build/decompile/game_18/library_28.o
ca65 -I src/pcode -o build/decompile/game_18/game_19.o src/pcode/civic_services.s
ld65 -C src/pcode/civic_services.cfg -o build/decompile/game_18/game_19.bin \
  build/decompile/game_18/game_19.o
ca65 -I src/pcode -o build/decompile/game_18/game_20.o src/pcode/cargo_exchange.s
ld65 -C src/pcode/cargo_exchange.cfg -o build/decompile/game_18/game_20.bin \
  build/decompile/game_18/game_20.o
ca65 -I src/pcode -o build/decompile/game_18/game_21.o src/pcode/surface_maps.s
ld65 -C src/pcode/surface_maps.cfg -o build/decompile/game_18/game_21.bin \
  build/decompile/game_18/game_21.o
python3 docs/decompilation/checks/verify_game_18.py
```

The components match the hashes above and in the condition-display/library-27/resource/game17 notes.
The focused verifier checks source/output hashes, 230 interfaces, eight exact
bodies, collision-call order, low-bit branches, storage views, byte copies/fills,
string copies, and EXIT targets. It does not translate source
or establish general semantic equivalence.
No shared decoder, assembly, or disk-build
inputs changed. Runtime behavior and save/reload equivalence of the recovered
Pascal remain untested.
