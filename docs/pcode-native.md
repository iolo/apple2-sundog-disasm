# Native p-code primitive bank

`src/native/pcode_primitives.s` reconstructs the alternate SYSTEM.APPLE bank at
`$D000`–`$DFFF` and its shared continuation at `$E000`–`$E0E4`. It contains
2,146 native instructions (3,899 bytes) and 426 bytes of explicit tables/data.
The build checks all 4,325 bytes against the component baseline before placing
them into the disk image.

## Code and table boundaries

| Range | Representation |
| --- | --- |
| `$D000`–`$D0FF` | 128 opcode handler addresses for opcodes `$80`–`$FF` |
| `$D100`–`$D151` | 41 standard-procedure selector entries, including preserved unused zero entries |
| `$D152`–`$D1AC` | Runtime entry, variable operand reader, static-link helper, allocation helper |
| `$D1AD`–`$D1B6` | Ten-byte descriptor, fields still unresolved |
| `$D1B7`–`$DCF5` | Native error, dispatch, load/store, arithmetic, indexing, and other handlers |
| `$DCF6`–`$DCFD` | Eight one-bit masks |
| `$DCFE`–`$DDD5` | Native routines |
| `$DDD6`–`$DDF7` | Seventeen low-bit word masks, 0–16 bits set |
| `$DDF8`–`$DE17` | Sixteen high-bit word masks, 0–15 low bits cleared |
| `$DE18`–`$DEA3` | Comparison handlers |
| `$DEA4`–`$DEA7` | Scratch-string pointers `$0088` and `$008A` |
| `$DEA8`–`$E0E4` | Comparison handlers and shared continuation |

The three mask tables are emitted from their formulas in source. The scratch
pointers are loaded by the character/string comparison conversion paths.
The descriptor is kept as data without inventing field meanings. The source
also preserves handlers not selected by this runtime's normal opcode table;
decoded instructions do not imply that every routine has been exercised.

The dispatcher at `$D293` uses `$58/$59` as the p-code instruction pointer.
It writes the low operand byte of the indirect jump at `$D29D`. The source uses
`dispatch_jump+1`, retaining the on-disk `JMP ($D000)` bytes rather than a patched
runtime operand. Earlier [dispatch captures](pcode-toolchain.md) establish this
bank's actual execution.

## Bank boundary

The `STA $88` instruction starts at `$DFFF`; its operand is the byte at common
`$E000`. Disassembling either bank in isolation leaves a false dangling opcode
or a false `DEY` instruction. The assembled component therefore extends through
the final `JMP advance_two` at `$E0E2`, ending immediately before the separately
identified procedure-frame routine at `$E0E5`.

The manifest maps component bytes 0–4095 to disk-1 blocks 243–250 and bytes
4096–4324 to the first 229 bytes of block 227. This CPU-contiguous source order
differs from SYSTEM.APPLE's file order. The recorded bank loads in
[bootstrap.md](bootstrap.md) confirm both source regions.

## Structural and build checks

```sh
python3 tools/build_disks.py
python3 tools/check_pcode_native.py
python3 tools/verify_disks.py
```

`check_pcode_native.py` runs da65 with `src/native/pcode_primitives.info`, requires
complete instruction coverage within every declared code range, and checks 555
direct control-flow and vector-table targets. Every in-component target lands
on an instruction boundary. External targets remain listed for later native
modules. The check also preserves the bank-crossing instruction and initial
dispatch operand. A deliberate vector into operand byte `$D156` is rejected.
The recipe format follows the official [da65 guide](https://cc65.github.io/doc/da65.html).

For a fresh exploratory listing, the built component is already in CPU order:

```sh
da65 -i src/native/pcode_primitives.info --comments 4 \
  -o build/pcode-primitives.s build/disks/components/pcode_primitives.bin
```

The accepted source adds comments and formula-generated masks to that listing.
Its final size assertion stays inside PCODE_NATIVE; the generated trailing
`.code` directive must not move that assertion to an empty segment.

`reference/step06b-native-audit.json` and `step06b-build-validation.json` record
the structural and behavioral evidence. Both disk images compare byte for byte.
The rebuilt MAME play and utility sequences match all ten reference screenshots,
and final disposable media hashes match the corresponding original runs,
including the utility program's expected disk-1 writes. This does not claim
coverage of every interpreter handler or all gameplay paths.
