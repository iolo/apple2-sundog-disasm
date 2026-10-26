# Game14 complete source recovery

All 12 procedures are recovered directly from
[`ship_components.s`](../../src/pcode/ship_components.s), covering 1,300 original instructions.
The maintained [entry](../../src/pascal/ship_components/run_component_panel.pas) supplies the parent
and all children. It replaces the temporary external interface used by game15.
All required library bodies and native contracts were already recovered.

| Procedures | Reviewed behavior |
| --- | --- |
| 2/3 | Toggle wrapper, mode-dependent setup, signed DIV alignment, original bounds and title literals. |
| 4/5 | Inclusive row/column loops, byte-table drawing, status cases and meter boundaries. Procedure5 retains its previous or uninitialized mode for values outside0..4. |
| 6 | Save/install/restore bounds, capture each stock row across calls, resolve `Unknown` captions by kind, and use the original city-name stride. |
| 7/8 | Page selection, normalization only above144, raw item writes, recalculation before high-code restoration and pending-index writes. |
| 9/10 | Initial pending repair followed by a descending19..0 scan; capture each item pointer before drawing/sound; reread its code after the sound call; preserve nested frame access. |
| 11/12 | Masked item-fit checks, unconditional fit call after captured eligibility, value/VAR aliasing in item exchange, mandatory input polling and ordered restoration. |
| 1 | Inner interaction loop and outer page loop, conditional clock/update calls, mode restoration, screen restoration and final VAR action write. |

The parent has three parameter words: a VAR action at slot3 and value words at
slots2/1. Its204 local bytes occupy slots4..105. The type view overlays eight
text15 captions at10..73, bounds at74/78/82, and four lamp bounds at86..101.
Flags remain raw words interpreted by their low bit. The original title
`Tactical Disply` and other literals are retained verbatim.

Procedure10 is nested inside9 at lexical level3. Its row pointer remains in
local4, while coordinates and scan index remain in parent9 slots5/6/7 and the
byte-table base in grandparent slot4. Procedure6 similarly captures its stock
row in local9. Both pointers remain stable across calls even when their pointed
contents change. Source indexing uses existing packed storage views and keeps
the original byte widths and strides.

Procedure12 captures eligibility in unused local3, calls11 unconditionally,
and saves that result in unused value parameter1 before testing both. Its
20-byte local frame is unchanged. Calls to library27:7 load the held value
before passing that same variable as a VAR result. Selector1 is polled on every
loop path, including paths with no selected item. No initialization or default
was invented for values the original leaves unwritten.

The [second fixture](checks/game_21_compile.pas) compiles all 12 bodies as
procedures197..208. Game15 now occupies209..224 and calls the recovered197.
Current fixture coverage is recorded in the receipt and progress index.
All game14 local sizes, parameter sizes and lexical levels match the
original metadata. Source and emitted disassembly were reviewed against each
original path. The [receipt](checks/game_21_receipt.json) records mapping, hashes,
compiler revision and options; the [existing verifier](checks/verify_game_21.py)
checks captured pointers, nested access, post-call reads, unconditional fit and
input calls, value/VAR operands and the final action write.

Compilation succeeds with the existing game21 checksum-failure `goto` warning.
Both verifiers pass. No new exact-byte or runtime-execution claim is made.
Native code, DATASEG storage and existing segment-runtime interfaces remain
unlinked in the compile fixture. Game14 itself has no segment-load/release
epilogue. The assembly and disk reconstruction inputs are unchanged.

Use the [existing compile/check commands](game_21_map.md#continuation-checks);
the original game14 binary is built by the [game15 commands](game_15.md).
Next: game13 and its required dependencies. Current full-scope totals are in
the [progress index](README.md).
