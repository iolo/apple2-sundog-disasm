# Retained Apple Pascal linker code

Block 126 offsets 210–511 are identical on both SunDog disks. All 302 bytes
match part of `SYSTEM.LINKER` on the archived
[Apple Pascal 1.2 APPLE2 disk](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/programming/pascal/ucsd/UCSD%20Pascal%201.2_2.DSK).
The complete original procedures establish instruction boundaries, embedded
strings, jump tables and procedure metadata for this clipped copy.

`src/pcode/retained_linker_context.s` reconstructs both complete donor procedures.
`src/pcode/retained_linker.s` emits the matching 302-byte window for each disk;
the other source bytes supply decoding context and are not inserted into SunDog.
This classifies **604 disk bytes: 496 code and 108 data**.

## Provenance and exact match

The archived disk's SHA-256 is
`6576fccbf64f0b512d72561e6094d5754cdd8b0bb3530c00ce8b8ee8cffa9f21`.
Its directory allocates 24 blocks to SYSTEM.LINKER. Extract the complete
allocation with:

```sh
a2kit get -d /tmp/pascal12-2.dsk -f SYSTEM.LINKER -t raw > /tmp/pascal12-linker-full.bin
```

The result is 12,288 bytes, SHA-256
`f9e2a2a907b3aae13c7b43c728fb796b3bcc3e040637de859f8fa823380c0606`.
Do not use `--trunc` for this reference: it returns 11,776 bytes, cutting off
the procedure dictionary required here. The segment header declares segment 1
at file offset 512 with length 11,490; its trailer confirms segment 1 and 49
procedures, all with structurally valid dictionary entries in the full allocation.

| Procedure | Entry | Attribute start | Attributes | Exit | Local bytes | Parameter bytes |
| --- | --- | --- | --- | --- | --- | --- |
| 22 | 3320 | 3898 | 3906 | 3877 | 586 | 4 |
| 26 | 3908 | 4120 | 4128 | 4112 | 6 | 2 |

Offsets in this table are relative to the historical segment. The two procedures
are physically adjacent despite their nonconsecutive numbers. Their dictionary
entries at 11444 and 11436 resolve to the listed attribute records. Their stored
entry and exit displacements independently resolve to instruction boundaries.

The combined 810-byte source window covers segment offsets 3320–4129. It
decodes completely into 443 instructions / 683 code bytes, 82 string bytes,
24 jump-table bytes, 20 procedure-metadata bytes and one alignment byte.
All local branches resolve to decoded instruction boundaries; calls to other
historical procedures remain named references, without inventing their code.

The SunDog copy is segment offsets 3774–4075 (file offsets 4286–4587), or
offsets 454–755 in the combined source. Its first two bytes are the complete
two-byte operand of `LDL 295`, whose opcode is just before the retained window.
The context reconstructs that full instruction; the disk source emits its
surviving operand as `p_big 295, 2`. The last instruction is the complete
`LDCI 20000`; there is no clipped
ending operand. The per-byte audit distinguishes 248 code bytes and 54 data
bytes per copy, including the strings and procedure-22 metadata between bodies.

## Historical set-membership opcode

These procedures use opcode `$8B`, `INN` (set membership). Willi Kusche's
[full Pascal interpreter listing](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf)
maps it to the membership handler (page 15). The handler reads its arguments
from the evaluation stack, pushes a Boolean result and advances the p-code
instruction pointer by one (pages 81–83). There are no inline operands.

SunDog's own dispatch entry for `$8B` points to `$D1EF`, its unsupported-opcode
path. The default decoder therefore continues to reject it. The explicit
`apple-pascal-inn` decoding option accepts the historical one-byte instruction;
it does not claim that the trimmed SunDog interpreter can run these copied
linker procedures. The assembler emits it as `p_inn`, with the distinction
documented beside the macro. Five INN instructions occur in the complete donor
context; only one lies in each retained disk window.

## Verification and build independence

`src/pcode/evidence/retained_linker.json` records the source URL, disk/allocation/
segment hashes, header, complete dictionary, selected procedure metadata and
bounded 810-byte donor context. The context is verification evidence; normal
builds use the disassembled source, not the evidence bytes or downloaded disk.

`tools/retained_linker.py` validates the header/dictionary relationships,
independently decodes both complete procedures, checks all code/data ownership,
assembles all 810 context bytes and the 302-byte disk source exactly, and
compares the selected window against both
rebuilt disks. Its optional external-file check also validates the full original
dictionary and every frozen excerpt against the allocation hash.

```sh
python3 -m unittest discover -s tools -p test_retained_linker.py
python3 -m unittest discover -s tools -p test_pcode_source.py
python3 tools/retained_linker.py --verify
python3 tools/retained_linker.py --verify --external-linker /tmp/pascal12-linker-full.bin
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests check the clipped operand, instruction boundaries, explicit dialect
selection and rejection of altered provenance, mapping and external inputs.
`docs/reference/retained-linker.json` records full decoding and the intersection
with copied bytes. No new emulator execution or live reachability is claimed.
