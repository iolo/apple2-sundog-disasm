# Retained native-container and linker metadata

The provisional ranges in the high-memory SYSTEM.APPLE component now have
explicit code/data classifications. Its bytes and normal disk mappings are
unchanged. The initializer's separate 42-byte payload is outside this work.

## Native footer at $F790–$F79F

Concatenating the reconstructed bank-2 `$D000`–`$DFFF` with common memory
`$E000`–`$F79F` produces a complete 10,144-byte native Pascal container. Parsing
its stored dictionary identifies one native procedure with entry offset zero,
corresponding to bank-2 `$D000`. This is stored container metadata; it does not
replace the independently traced boot entry or imply Pascal calls use it now.

| Address | Stored field |
| --- | --- |
| `$F790,$F792,$F794,$F796` | Four zero relocation counts: interpreter, procedure, segment, global |
| `$F798` | Entry displacement `$2798`, resolving to `$D000` |
| `$F79A` | Native marker zero and lexical level zero |
| `$F79C` | Dictionary displacement two, resolving to `$F79A` |
| `$F79E` | Segment number one and procedure count one |

The audit constructs the container from actual assembled components, then uses
the existing procedure-dictionary and native-relocation parsers. No missing
body bytes or metadata are synthesized.

## Clipped instruction at $F7A0

The 96 bytes at `$F7A0`–`$F7FF` exactly copy original initializer bytes
`$F5A0`–`$F5FF`, or `$6B10`–`$6B6F` in the copied execution view. The preceding
original instruction at `$F59F` / `$6B0F` is `LDY #$03` (`A0 03`). Thus `$F7A0`
is its immediate operand, a one-byte code fragment. The source states the full
instruction context while emitting only the retained `$03`; it invents neither
an opcode nor an executable entry. The following 95 bytes were already decoded.

## Linker records and version field

Apple Pascal Technical Note 16 defines eight-character linker names, record
types and variant fields, with linker information beginning on a block boundary
after code. Types 11, 6 and 0 identify separate-procedure, global-definition and
end records. [Apple's object-module format note, PDF pages 94–96](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/non-english/french/apple_forumdesdeveloppeurs/apple_forumdesdeveloppeurs_05_tn_pascal.pdf#page=94)

The local bytes match three complete sixteen-byte records:

| Address | Name | Type | Stored fields after type |
| --- | --- | --- | --- |
| `$F800` | `THISISIT` | SEPPROC (11) | Source procedure 1, parameter words 0, spare word 0 |
| `$F810` | `THISISIT` | GLOBDEF (6) | Home procedure 1, byte offset 0, spare word 0 |
| `$F820` | Eight spaces | EOFMARK (0) | Allocation fields 0, 0, spare word 0 |

The procedure and global definition agree with the single native procedure's
entry at offset zero. Their block begins immediately after the block containing
the native footer and copied instruction tail. The next 464 bytes, through
`$F9FF`, are all zero within the linker-information block. Source declarations
now separate them from the subsequent 1,152 zero bytes before the fixed slot
stubs at `$FE80`.

Apple's system-location table identifies `$FFF6` as a stored SYSTEM.APPLE
version word and distinguishes it from the runtime version byte. The local word
is 3; this audit does not infer a release name from that value. [Apple's system-location table, PDF page 47](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/non-english/french/apple_forumdesdeveloppeurs/apple_forumdesdeveloppeurs_05_tn_pascal.pdf#page=47)

## Verification and scope

```sh
python3 tools/test_native_high_metadata.py
python3 tools/check_native_high.py --output build/native-high-metadata-check.json
python3 tools/verify_disks.py
```

The current audit is `docs/reference/native-high-metadata-audit.json`; the older
step-06f report remains a historical checkpoint. Two mutation tests cover native
footer fields, copy provenance, symbol/type/variant fields, zero linker storage,
version and component extents. The extended high-memory audit also retains its
79 target checks, bank-specific validation, 22 service-entry checks and complete
decoded-copy verification.

The component contains 168 complete instructions / 390 bytes, one precisely
identified instruction-operand byte and 1,769 data bytes. All 59 bytes formerly
listed in its three provisional preservation ranges are now classified. This
does not reduce the separate temporary-disk byte count or resolve other runtime
components' provisional ranges. No new live execution or peripheral coverage is
claimed, and the primary document is not a build or verification dependency.
