# Runtime architecture and reconstruction boundary

Step 04 establishes the architecture needed for source reconstruction. It does
not finish per-procedure disassembly, asset classification, or gameplay analysis.
Those remain in steps 06–09, with unresolved bytes retained in the coverage map.

## Confirmed path into startup

The boot and initialization captures in [bootstrap.md](bootstrap.md) lead from
the three-page native loader through the `$4000` component and banked
SYSTEM.APPLE interpreter, then into SYSTEM.PASCAL p-code at `$F248`.
The [first dispatch trace](pcode-toolchain.md) confirms the initial external call.

`reference/overlay-loads.json` continues that same unpatched apple2ts session
at native segment-reader entry `$E46D` and read completion `$E4DE`:

| Segment | Disk-1 block | Length | Observed destination |
| ---: | ---: | ---: | --- |
| 2 | 261 | 808 | `$B4F4` |
| 6 | 272 | 3,652 | `$A6A0` |
| 5 | 268 | 1,670 | `$A01A` |
| 1 (SYSTEM.STARTUP) | 141 | 576 | `$B2B4` |
| 22 | 104 | 6,126 | `$95CE` |
| 23 | 116 | 606 | `$AB5E` |
| 24 | 118 | 4,306 | `$9CEA` |
| 25 | 127 | 958 | `$A9FE` |
| 26 | 129 | 3,058 | `$A1CA` |
| 27 | 135 | 1,616 | `$A76C` |
| 28 | 139 | 328 | `$AC74` |
| 22 again | 104 | 6,126 | `$95BE` |

Each complete capture equals its on-disk segment bytes before the loader's
subsequent relocation processing. This covers 29,830 loaded bytes, including
the repeated segment 22. Read completions all report `X=0`.

Immediately after loading the startup segment, a breakpoint at bank-1 `$D293`
confirms p-code pointer `$B49C` and attribute pointer `$B4E4`. Those equal load
base `$B2B4` plus procedure 1's entry offset 488 and attribute offset 560 from
the independent procedure dictionary. Its 32-byte instruction capture matches
disk-1 block 141 at offset 488. The next seven loads are library segments 22–28.

This distinguishes the real startup from SYSTEM.PASCAL's tiny placeholder
segment 1 at block 260. A segment number alone is not a globally unique module
identity: retain the header, source disk, and extent in every source mapping.

The [reference play session](reference/README.md) supplies the behavioral
boot/menu/play-side-swap path. The [segment inventory](pascal-segments.md) locates
the remaining startup segments on that play side. The captures here establish
startup and library loading; they do not trace every later gameplay overlay.

## Memory and load conventions

- At `$E46D`, A is the segment-table index. The six-byte entry at
  `$BE3E + 6*A` contains device, absolute block, and byte length, all words.
- `$5C/$5D` is the downward allocation pointer used by this loader. It subtracts
  the byte length to get the destination, puts it in `$98/$99`, and calls the
  block service. The recorded addresses are individual load events, not a map
  of simultaneously resident segments. Segment 22's different destinations
  demonstrate why reconstruction must preserve relocation information.
- `$E4E9` manages loaded-segment state, with two-byte entries at `$BD1E`,
  `$BD5E`, and `$BD9E` indexed by segment number. Its nonzero-loaded case
  increments the `$BD1E` entry. Its unloaded case calls `$E46D` for stored
  segments; a zero disk block instead allocates the declared data size.
- Main RAM holds transient segments and data; native interpreter bank 1 lives
  at `$D000`–`$DFFF`, native I/O bank 2 shares that address range, and common
  language-card RAM occupies `$E000`–`$FFFF`. SYSTEM.PASCAL's initial core
  replaces initialization bytes at `$F248`–`$FE7B`.
- `$58/$59` is the p-code instruction pointer, `$54/$55` the current procedure
  attribute pointer. The hardware stack also carries p-code operands and
  native service parameters. They are not ordinary cc65 C calling conventions.

See the earlier captures for initialization erasure, bank-switch accesses, the
split procedure at `$BC72`, and the dispatcher's self-modifying operand.

## Reconstruction choices and remaining detail

| Representation | Reconstruction approach | Existing evidence |
| --- | --- | --- |
| Native bootstrap / `$4000` component | ca65 6502 source at verified load addresses | Whole load captures and native entry breakpoints |
| Banked SYSTEM.APPLE | Separate ca65 bank/common segments, preserving vectors and tables | Both banks captured before initialization |
| P-code | ca65 instruction macros plus explicit dictionaries, jump tables, and constants | First procedure assembles exactly; structural inventory and live dispatch |
| Native Pascal procedures | ca65 plus original native relocation records and attributes | Zero procedure-number markers in valid dictionaries; native handlers |
| Other bytes | Classified assets or explicitly temporary preservation inputs | Full disk-sector inventory; no completeness claim yet |

The matching assembler is available, and p-code exact encoding has been proved
without recompiling from a guessed Pascal source. Detailed native relocation
decoding, full opcode support, all remaining executable boundaries, alternate
utility/demo paths, and disk-2 overlay behavior are required during module
reconstruction and final validation. They are not silently counted as finished.

Recheck all recorded source comparisons with:

```sh
python3 tools/verify_runtime_evidence.py
python3 tools/test_pascal_inventory.py
python3 tools/build_pcode_probe.py
```

To repeat the coarse trace, continue from the first external-call trace, replace
breakpoint `$D293` with `$E46D`, record A/table/zero page, then move the breakpoint
to `$E4DE` and capture the computed destination. Move back to `$E46D` for each
next load. After segment 1's block-141 read, stop once at `$D293` to record its
entry. Never patch the p-code pointer to force an entry.
