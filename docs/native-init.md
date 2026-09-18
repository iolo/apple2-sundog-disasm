# Copied runtime initializer

`src/native/native_init.s` assembles the five-page initializer at its execution
address `$6800`–`$6CFF`. The disk build places those 1,280 bytes in SYSTEM.APPLE's
original `$F290`–`$F78F` region, from disk-1 block 236 byte 144 through block 238
byte 399. The copy stub at `$F269` belongs to
[the shared runtime](native-shared.md).

All 1,280 assembled bytes match the recorded `relocated-init` capture in
`reference/runtime-init.json`, before the initializer modifies memory. This
proves the chosen execution address and complete copied input. The typed source
contains 498 instructions (1,032 bytes) and 248 data bytes.

## Original and copied addresses

The initializer intentionally mixes execution from the low-memory copy with
references to the original high-memory image. The source defines
`INIT_STORAGE_DELTA = $F290 - $6800` and expresses known aliases using labels
plus that delta. These accesses must not be redirected to the copied image as
an incidental relocation cleanup.

- `$6824/$682B` call the page-checksum helper at original `$F69A`. Its copied
  counterpart is `$6C0A`. The helper sums the page addressed by `$C5/$C6` while
  counting carries in X; the caller compares two results during slot probing.
- `$6881` copies four bytes from original `$F30D`, corresponding to the
  `JSR $FF36; RTS` stub at copied `$687D`, into `$BF0A`–`$BF0D`.
- `$688C` copies eight bytes from original `$F6B0` (copied `$6C20`) to `$E8`–`$EF`.
- The device-initialization paths read synthetic RTS addresses from original
  `$F35C`–`$F35F`. Those words contain copied return addresses minus one:
  `$68B8` and `$68C3`, returning to `$68B9` and `$68C4`.
- `$6964` copies 42 bytes from original `$F418` (copied `$6988`) to `$BF56`.

The checksum and early table accesses occur before loading the SYSTEM.PASCAL
core at `$F248`, which overwrites the original initializer. The copied code
then continues in low memory, as established by the initialization trace.

## Boundaries and observed behavior

| Copied range | Classification |
| --- | --- |
| `$6800`–`$68CB` | Clear low memory, probe slots, prepare device setup |
| `$68CC`–`$68CF` | Two synthetic return words |
| `$68D0`–`$6987` | Machine/device setup and copies of initial state |
| `$6988`–`$69B1` | Unresolved 42-byte payload copied to `$BF56`–`$BF7F` |
| `$69B2`–`$6C17` | Directory/system loading, runtime setup, and checksum helper |
| `$6C18`–`$6C1F` | Eight slot-signature bytes, consumed by indexed comparisons at `$6840/$6849` |
| `$6C20`–`$6C27` | Four initial pointers `$FE80,$FEB0,$FF00,$FF5C` |
| `$6C28`–`$6C45` | Clear `$6000`–`$6C30`, then dispatch p-code |
| `$6C46`–`$6C78` | Original Apple copyright text, preserved as a string |
| `$6C79`–`$6CFF` | 135 preserved zero bytes |

Captured checkpoints at `$6A02` and `$6B32` establish the directory and system
header reads. The version check at `$6B15/$6B17` applies `AND #$E0; CMP #$A0`.
After loading the core and split segment, `$6C43` jumps to p-code dispatch at
`$D293`. Its preceding erase loop stops before its own still-running loop body,
removing the earlier copied initializer and load scratch area.

The 42-byte payload remains an explicit open question. Its destination and
pointer setup at `$BF23/$BF24` are known; its internal format and later consumer
have not been established. It remains visible as literal bytes in source and
in the audit report, not as a claimed decoded routine or identified asset.
This unknown must be resolved or properly classified before final coverage is
declared complete.

## Validation

```sh
python3 tools/build_disks.py
python3 tools/check_native_init.py
python3 tools/verify_disks.py
da65 -i src/native/native_init.info --comments 4 \
  -o build/native-init-review.s build/disks/components/native_init.bin
```

The structural audit checks all code spans and 90 direct/synthetic-return
targets. Calls into the original image are checked against the corresponding
copied instruction boundaries and required to retain their original operands.
It also checks both return words, the system version test, final dispatch,
zero tail, and complete equality with the recorded emulator capture. Tests
reject a checksum call redirected to the copied address, a return into an
operand byte, and a changed version test.

Evidence is in `reference/step06e-native-audit.json` and
`reference/step06e-build-validation.json`. The latter records exact full-disk
comparisons and MAME play/utility reference results. The remaining high-memory
entry stubs and preserved fragments are not part of this component.
