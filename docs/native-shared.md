# Shared native interpreter and device runtime

`src/native/native_shared.s` reconstructs `$E0E5`–`$F28F` of SYSTEM.APPLE's
common memory. It follows the [primitive module's shared tail](pcode-native.md)
and ends immediately before the initialization image at `$F290`. Its 4,523
bytes map to disk 1, logical block 227 starting at byte 229 through the first
144 bytes of block 236. The adoption recipe records each sector slice.

The source contains 2,192 instructions occupying 4,212 bytes, plus 311 bytes
of constants, pointers, initial state, and text. It includes procedure-frame
handling, segment loading, numeric routines, device wrappers, and the stub that
copies the initializer. The copied initializer itself and high-memory entry
stubs remain separate reconstruction work.

## Established entry points

| Address | Evidence and role |
| --- | --- |
| `$E0E5` | Procedure-call preparation; consumes the JSR return and follows procedure metadata |
| `$E17E` | Native-procedure return path, conditionally releasing a segment before resuming p-code dispatch |
| `$E46D` | Read a segment using the table at `$BE3E`; the [overlay captures](runtime-architecture.md) record twelve whole loads |
| `$E4DE` | Segment-read result boundary used in the captured loader traces |
| `$E4E9`, `$E646` | Acquire/release paths using loaded-segment state at `$BD1E/$BD5E/$BD9E` |
| `$E67F` | Standard-procedure dispatch; doubles the p-code operand and patches the indirect jump at `$E687` |
| `$E68A` | Fill a memory range with a byte value, using whole-page and remainder loops |
| `$EDBD` | Fetch four-byte power-of-ten constants, checking the supplied index against 39 |
| `$EEA5` | Check a device number, including an alternate encoded-slot form |
| `$F1D1`, `$F1E2` | Indirect character write/read calls, with a common synthetic return |
| `$F269` | Copy five pages from `$F290` to `$6800`, then jump to `$6800` |

Address-based labels remain for less-understood routines. In particular, this
checkpoint does not claim full semantics or test coverage for every numeric
routine. The original [runtime traces](pcode-toolchain.md) and overlay captures
establish executed paths; disassembly alone does not establish reachability.

## Embedded data and indirect calls

| Range | Representation |
| --- | --- |
| `$E189`–`$E18A` | Return address `$E17D`, assembled as `native_procedure_return - 1` |
| `$E18B` | Initial zero for the native-call segment state |
| `$EDE6`–`$EE81` | 39 four-byte power-of-ten entries |
| `$EE82`–`$EE83` | Pointer `$D1E3` used by I/O error handling |
| `$EE84` | Mutable I/O mode byte |
| `$EE85`–`$EE94`, `$EE95`–`$EEA4` | Output/input device vectors, including zero entries |
| `$F1CB`–`$F1CC` | Return address `$F1CC`, assembled as `device_call_return - 1` |
| `$F1F3`–`$F1FA` | Initialization/runtime pointers `$BD1C,$BE3E,$BDDE,$D6E4` |
| `$F1FB`–`$F1FE` | Four initial zero bytes, including message column/index state |
| `$F1FF`–`$F23D` | Boot-disk prompt, with explicit CR/LF bytes and `#` terminator |
| `$F23E`–`$F25F` | Original system-version error text, ending in `#` |
| `$F260`–`$F263` | Pointers to the device vector tables |
| `$F267`–`$F268` | Initializer source pointer `$F290` |

The words at `$E189` and `$F1CB` are return-address data, not instructions.
Their callers push high and low bytes onto the hardware stack before an
indirect jump. RTS then adds one, reaching `$E17E` or `$F1CD`. The latter begins
`STX $BDDE; RTS`; decoding from `$F1CB` as continuous code obscures this entry.

`$E684` writes the low operand byte of `$E687`'s `JMP ($D100)`. Source references
use `standard_procedure_jump+1`, while the on-disk operand remains `$D100`.
The dispatch target table is owned by the bank-1 primitive component.

Device vector lookups at `$F10C` and `$F116` use bases two bytes before the
first unit entries, because the selected unit number is doubled. The stored
table pointers at `$F260/$F262` point to the first actual entries, `$EE85/$EE95`.

## Preserved numeric-table anomaly

The power table stores the high 16-bit word first, with each word little-endian.
Interpreting those bits as binary32, entries 0–37 exactly match correctly rounded
`10^n`. Entry 38 stores bits `$7E96769C`; correctly rounded `10^38` would be
`$7E967699`, three units in the last place lower.

The source preserves `$7E96,$769C`. It deliberately does not regenerate that
entry from a rounded floating-point literal. The audit computes nearest-even
rounding of integer `10^n` using integer arithmetic, checks all 39 entries, and
requires the observed three-unit difference in the last entry. This establishes
the table's bit pattern; it does not establish how that difference arose or
that the runtime implements every IEEE floating-point rule.

## Reproduce and verify

```sh
python3 tools/build_disks.py
python3 tools/check_native_shared.py
python3 tools/verify_disks.py
da65 -i src/native/native_shared.info --comments 4 \
  -o build/native-shared-review.s build/disks/components/native_shared.bin
```

The typed recipe classifies code and data. Accepted source additionally uses
return-label expressions, readable messages, annotated constants, and a size
assertion. `check_native_shared.py` checks all code spans, 464 direct/vector/
synthetic-return targets, and 27 incoming primitive-table vectors. It verifies
the dispatch operand, constants, messages, and initializer source/destination.
Corrupt return targets, dispatch operands, and a normalized final power constant
are rejected.

`reference/step06d-native-audit.json` contains the structural results and every
numeric-table comparison. `reference/step06d-build-validation.json` records the
byte-identical disks and MAME reference comparisons. Comprehensive numeric,
peripheral, save/load, and final two-emulator checks are not claimed here.
