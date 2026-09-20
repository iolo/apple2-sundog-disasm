# Retained directory and segment-header fragments

`src/data/retained_pascal_metadata.s` reconstructs 1,178 disk bytes as typed
Pascal metadata. Its 760 source bytes supply two identical directory tails and
one distinct header tail. These fragments survive after complete current code
components; they are not additional executable procedures.

| Location | Fragment | Disk bytes |
| --- | --- | ---: |
| Both disks, block 117 bytes 94–511 | Directory records and spare storage | 836 |
| Disk 1, block 259 bytes 170–511 | Segment-header suffix | 342 |

## Directory residue

Nine consecutive 26-byte records start at block-117 offset 96. Their field
boundaries match the Pascal directory layout already established in
[pascal-directories.md](pascal-directories.md): three words, a length byte,
fifteen bytes of fixed name storage, final-block byte count, and date word.
The implementation was also checked against the locally installed a2kit 4.4.2
`src/fs/pascal/directory.rs` definition of `DirectoryEntry`.

| Block offset | Retained filename | Stored name length | Stored block bounds |
| --- | --- | ---: | --- |
| `$060` | MAINB.LIB.TEXT | 14 | 229–233 |
| `$07A` | GRND.LIB.TEXT | 13 | 233–237 |
| `$094` | SHIP.LIB.TEXT | 13 | 237–241 |
| `$0AE` | DUMMY.CODE | 10 | 254–258 |
| `$0C8` | DUMMY.CODE | 0 | 254–320 |
| `$0E2` | SETPRINT.TEXT | 0 | 253–257 |
| `$0FC` | SHIP.RDMAP.TEXT | 0 | 301–320 |
| `$116` | CHAIN.LIBRARY | 0 | 271–274 |
| `$130` | WCHAR.ASM.TEXT | 0 | 274–320 |

The first four records have coherent file types, bounded counted names,
512-byte final-block counts and matching date words `$A868`. All nine retain
the same final-block count. The five cleared-name records preserve old name
storage and numeric fields, including `$A762/$A763` in type storage. Those
values are emitted unchanged; they are not interpreted as valid live file
types. The first cleared DUMMY name field exactly repeats the preceding named
record's entire fifteen-byte storage, including its residual bytes.

Bytes 94–95 are the final date word `$A9F7` of the clipped preceding record,
at the same 26-byte stride. They are emitted as a word; the missing preceding
24 bytes are not reconstructed. The final complete record ends at offset 330,
followed by 182 zero bytes of directory spare storage through the block end.
Every nonzero byte in the selected tail belongs to an explicit record field.

The volume header and earlier records are absent. These stored bounds are
**historical directory residue**, not a current allocation map for the 280-block
SunDog disks. No current file or execution role is inferred from the names.
The identical copies on both disks retain the same classification.

## Clipped segment header

Disk-1 block 259 contains a retained header suffix with its inferred original
origin at byte 12. The current SYSTEM.PASCAL fragment occupies bytes 0–169;
the retained metadata starts at original header offset 158. The alignment is
established by the complete sixteen-word segment-information table, followed
immediately by intrinsic mask `$00000044`. It also places the preceding kind
and text-address tables and following extension at their documented offsets.
The format is the same as the classified
[header tables](pascal-header-tables.md) and
[header extensions](pascal-header-extensions.md), whose original Apple manual
reference supplies the field layout.

| Block offsets | Original header offsets | Data |
| --- | --- | --- |
| 170–203 | 158–191 | Remaining name storage: 34 spaces |
| 204–235 | 192–223 | Sixteen zero segment-kind words |
| 236–267 | 224–255 | Sixteen zero text-address words |
| 268–299 | 256–287 | Version-5, machine-2 information words for 0,1,3,4,5, then eleven zero-number slots |
| 300–303 | 288–291 | Intrinsic set, segments 2 and 6 |
| 304–443 | 292–431 | Zero library-information storage |
| 444 | 432 | Empty comment length |
| 445–511 | 433–499 | Available 67 bytes of zero comment capacity |

The intrinsic set also matches the current block-251 SYSTEM.PASCAL header.
The missing 158-byte prefix and twelve-byte suffix are not invented or adopted.
No procedure dictionary is inferred from this incomplete older header.

## Verification

`tools/retained_pascal_metadata.py` checks exact rebuilt disk hashes, record
strides and signatures, both directory copies, header fields, zero-only storage,
gap-free field ownership, and exact assembly of the declarations. After adoption,
`--verify` also checks every disk mapping against manifest ownership. Tests
reject shifted/changed signatures, invalid lengths and nonzero spare storage,
while proving the current code prefixes are outside the classified fragments.

```sh
python3 -m unittest discover -s tools -p test_retained_pascal_metadata.py
python3 tools/retained_pascal_metadata.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The complete field audit is `reference/retained-pascal-metadata.json`. Normal
builds use committed assembly source and do not depend on original disks or an
external parser. Other tails, including the play disk's final zero-filled
track, require separate evidence and remain outside this checkpoint.
