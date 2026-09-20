# Native runtime copy after the world-default table

Disk 1 block 25 bytes 416–511 exactly match `native_shared` source offsets
`$0DBC`–`$0E1B`, originally executing at `$EEA1`–`$EF00`. This accounts for the
complete 96-byte tail after the 1,440-byte world-default table in blocks 23–25.
It is retained runtime code/data, distinct from the neighboring world state.

| Original runtime range | Classification |
| --- | --- |
| `$EEA1`–`$EEA4` | Two input-device vector words, `$FF18` and `$0000` |
| `$EEA5`–`$EF00` | 92 instruction bytes: device validation and I/O status/wrapper code |

The vector classification comes from the indexed device consumers and table
pointers in the [shared native runtime](native-shared.md). The instruction
boundaries are checked against that component's complete native audit. The copy
begins at a word boundary and ends after the complete `LDA #$04` at `$EEFF`.
No partial instruction or unexplained byte is introduced.

The exact 96-byte match supplies provenance. Runtime addresses in the audit
refer to the original component, not an inferred execution address of the
retained copy. Its branches, absolute calls and jumps keep their original
encodings. No live call into this disk tail is claimed.

The disk mapping reuses the existing assembled `native_shared` component. No
new binary blob, copied assembly file or original-image build input is added.
`docs/reference/preserved-native-shared-copy.json` records every item and its
code/data classification, both source and copy hashes, and the original audit.

```sh
python3 tools/native_shared_copy.py --verify
python3 tools/test_pcode_copies.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Verification freshly assembles the original component, checks its hash and full
native audit, independently checks every copied instruction boundary, compares
all 96 disk bytes and verifies the manifest source offset. The existing source
reuse tests cover stale images, wrong bytes, overlapping mappings, pre-owned
regions and preservation of code/data boundaries. Full-disk output remains
exact; no new emulator run is claimed.
