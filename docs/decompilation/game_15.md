# Game15 complete source recovery

All16 procedures are recovered directly from
[`ship_interior.s`](../../src/pcode/ship_interior.s), covering1,310 original instructions.
The maintained [entry](../../src/pascal/ship_interior/run_ship_interior.pas) now supplies the
parent and all15 children. The first nine helpers covered424 instructions;
the remaining seven add886. No translator was added.

| Procedures | Reviewed behavior |
| --- | --- |
| 2/3 | Value bounds copied before drawing; procedure3 then copies its80-character string and draws exactly four bytes without a length guard. |
| 4 | Original bounds, FUEL/GUNS/SHLD/WARP labels, bar arguments, conditional display and unconditional library24:9 update. |
| 5/6/7/15 | Ordered mode/coordinate/code accesses, low-bit word347 gate, packed flags/bytes and complete six-word location copy. |
| 8 | Clear the existing string pointer before retargeting; preserve disk-read order, conditional raw initializer, decode call and bounds reset. |
| 9 | Visit18 table rows; capture each16-byte row pointer, multiply unsigned byte11, preserve signed overflow and repeated +256, truncate to byte12; restore flags even on the date-equal path. |
| 10 | Scan two stock rows, set word227 before clearing the matching5-bit kind and15-character caption, and retain index4 termination. |
| 11 | Two early paths skip loading and table work but reach the common tail; preserve string comparison, case0/3/4/11, six-word copy and cursor setup. |
| 12 | Mode2 draw/query followed by returning the whole DATASEG29 word1. |
| 13/14 | Signed16-bit movement steps and fallback only when both coordinates are unchanged; signed DIV, case columns6..17, original row priority and default action0. |
| 16/1 | Self EXIT before writes for unchanged action; VAR game14 call; ordered segment loads/releases, repeated input polls and low-bit transition comparison. |

The parent retains52 local bytes with no parameters. Its raw-word view overlaps
bounds14..17, text18..25 and string-address26. All children have lexical level2.
The additional DATASEG29 bounds views at331/335/339 preserve the760-byte storage
extent and all previous offsets.

Procedure3's reference-compiler copies occupy different private slots from the
original: bounds3..6 rather than44..47, caption7..47 rather than3..43. Copy order,
capacity, and total90-byte frame are retained. No nested child or raw slot
access observes those offsets. Unused local bytes are omitted in6/8/11/16;
compiled local sizes are0/2/4/0 respectively. Other local sizes, all parameter
sizes and all lexical levels match the original metadata.

Procedure9 reads the table base anew for each iteration and each selected
lookup. The last lookup, selected by word229 bits4..8, has no zero guard.
Do not substitute signed8-bit velocity or a host-language modulo for the
original arithmetic. Procedure11 does not initialize action1 or flag10 on its
early paths; no inferred initialization was added. Short-circuit predicates
omit only side-effect-free reads and preserve every effectful call.

Procedure11 sets native entry7 to3904 before calling8. That conditional
library22:25 call reuses the reviewed raw screen-initializer contract: one
unused VAR address (here DATASEG29 word58), no Pascal result. The later5120
value is a disk-read destination, not another raw call in this component.
Game14's [recovered entry](../../src/pascal/ship_components/run_component_panel.pas) accepts a
VAR action plus two value words, established by both caller and callee accesses
and its six-byte parameter metadata. The [complete game14 recovery](game_14.md)
has replaced its temporary external declaration.

The parent loads8/14/27 and normally writes mode nibble1 before releasing27/14/8.
The original exit attribute points at `$0A13`, directly to the release epilogue,
skipping the nibble write. Nonlocal EXIT therefore needs a runtime binding to
that epilogue; the reference compiler's ordinary return metadata does not
supply it. Every original input poll remains, including four distinct selector4
call sites per loop and the selector1 call before the mode test. The transition
comparison retains typed low-bit `NEQ6` behavior.

The [second fixture](checks/game_21_compile.pas) now checks205 recovered bodies,
including all16 game15 bodies and11 previously reviewed library dependencies.
Compiled209 is game15's recovered parent;210..218 are the first nine helpers,
and219..224 are4/8/9/10/11/16. Game14's recovered scope is197..208.
Current full-scope coverage is recorded in the [progress index](README.md).
The [receipt](checks/game_21_receipt.json) records input hashes, compiler revision,
options, frames and mapping. Source and emitted disassembly were reviewed
against the original paths. The [existing verifier](checks/verify_game_21.py)
checks copies, field offsets, pointer capture, call ordering, polling and the
original exit target. Recompiling the first fixture after adding the storage
views produced identical output bytes. Both verifiers pass.

The expected diagnostics remain game21's checksum-failure `goto` warning and,
in the first fixture, game20:31's string-capacity warning. This group adds no
exact-byte or runtime-equivalence claim. External data, native code, segment
operations and nonlocal-exit handling remain unlinked in the fixtures.

Build the original components, then use the
[existing compilation/disassembly/check commands](game_21_map.md#continuation-checks):

```sh
ca65 -I src/pcode -o build/decompile/game_21/game_15.o src/pcode/ship_interior.s
ld65 -C src/pcode/ship_interior.cfg -o build/decompile/game_21/game_15.bin \
  build/decompile/game_21/game_15.o
ca65 -I src/pcode -o build/decompile/game_21/game_14.o src/pcode/ship_components.s
ld65 -C src/pcode/ship_components.cfg -o build/decompile/game_21/game_14.bin \
  build/decompile/game_21/game_14.o
```

Game14 is now recovered; next is game13. The full target inventory remains
in scope; current totals are maintained in the [progress index](README.md).
