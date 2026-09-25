# Disk-wide code/data classification ledger

The ledger accounts for all **286,720 disk bytes**: **136,686 code**,
**149,546 evidenced data**, and **488 user-assumed data bytes**. All 166 declared
components are integrated. There are no temporary inputs or missing audit
adapters. Completion uses the user's [explicit 488-byte exception](user-assumed-data.md),
not a claim that those bytes have acquired classification evidence.

| Disk | Code | Evidenced data | User-assumed data | Total |
| --- | ---: | ---: | ---: | ---: |
| Disk 1, title/utilities | 59,077 | 84,276 | 7 | 143,360 |
| Disk 2, play | 77,609 | 65,270 | 481 | 143,360 |

These are disk occurrence counts, including every mapped copy. Build ownership
is 184,828 ca65-source bytes, 101,404 identified-data bytes and 488 user-assumed
bytes; source-built components contain both code and data. Accepted data totals
150,034 bytes, of which 488 remain explicitly assumed rather than evidenced.

## Reproduce and inspect

```sh
python3 tools/test_classification_ledger.py
python3 tools/classification_ledger.py
python3 tools/classification_ledger.py --require-complete
```

Each ledger invocation builds the disks afresh from current source and inputs,
then checks the generated result against
[classification-ledger.json](reference/classification-ledger.json). Both ordinary and `--require-complete` checks succeed under the revised scope.
The strict check still exits 1 for temporary bytes or an unintegrated audit.
Its `complete` flag concerns accounting under the recorded acceptance rules;
it cannot establish behavior or source representation by itself.

Use `--write` to regenerate the receipt after a reviewed change. The receipt
contains the manifest hash, component byte hashes and source paths, evidence
paths and hashes, compact component classification intervals, per-disk counts
for every component, and the exact assumed-data and any unfinished image offsets. An interval
`[offset, size, classification]` is relative to its component. To resolve any
disk byte, use the manifest's owning region and calculate
`input_offset + disk_offset - region.offset`, then find that component interval.
The disk image's sector order is already represented by the manifest mappings.

The declared-component totals sum component identities, including full source
contexts that are only partly mapped; they do not deduplicate equal binaries.
They must not be substituted for the disk occurrence totals above.

## Evidence integration

- Complete Pascal segments, the split system segment, native Pascal procedures,
  retained utility procedures and historical linker fragments are decoded with
  their existing metadata and evidence. Instruction operands copied without
  their opcode retain the complete donor's code classification.
- Raw native modules, the five resident runtime components and both encoded
  banks replay their existing audits. The ledger includes the three overlapping
  BIT prefixes and the initializer/high-memory instruction fragments. Encoded
  components inherit the correct offset in their decoded bank; their stored
  bytes are still checked against the manifest.
- Custom dialogue records replay their interpreter-supported decoder. Their
  entry-pointer tables count as data, separately from script instructions and
  operands. Extracted message bytes remain in their existing data asset.
- Identified assets and an explicit registry of individually reviewed data-only
  sources inherit their existing classification documents. Their current bytes,
  source assembly and evidence hashes are checked. The ledger does **not** rerun
  every data-consumer audit; the linked module reports and tests remain part of
  the evidence and final review. No blanket rule for `.byte`, `.res`, unused
  space, or files under `src/data/` is introduced.
- The bootstrap and title adapter checks the documented native intervals,
  instruction boundaries/direct targets, consumed tables and native footers.
  Bootstrap `$08FD/$08FE` are retained NOPs falling through to the established
  `$08FF` reader, now emitted as instructions. The preceding 46 zero bytes are
  bounded storage after the terminal `$08CD` self-loop. This classification
  does not claim execution through the NOP prefix or a historical padding writer.

If a future component has no adapter, it receives `audit-not-integrated`,
which also prevents the strict ledger check. This means its existing evidence
has not been connected to this ledger; it is distinct from accepting an
unidentified region as data. Both disk mappings and declared component extents
must be accounted for before the ledger's completion flag can become true.

## Accepted user-assumed data regions

| Logical location | Bytes | Current evidence limit |
| --- | ---: | --- |
| Disk 1 block 22, offsets 505–511 | 7 | Record-template suffix lacks a complete code/data context |
| Disk 2 blocks 2 and 45, offsets 505–511 | 14 | Two copies of the same unresolved template suffix |
| Disk 2 block 0, offsets 193–255 | 63 | Sparse native boot-sector tail without established field/producer evidence |
| Disk 2 block 54, offsets 135–511 | 377 | Mixed checksum-allocation tail; no supported decoder or data structure |
| Disk 2 block 89, offsets 485–511 | 27 | Dictionary allocation suffix beyond all current supplement copies |

The checksum suffix occupies two physical image intervals because of sector
ordering. The generated ledger retains both intervals and their source offsets.
The initial consolidation did not classify these bytes. Step 08ac accepts them
solely by user instruction and retains their evidence limits above. Their exact
bytes and physical mappings are checked against the acceptance receipt and
reported separately in `assumed_data_regions`. Both disk hashes remain unchanged,
so existing MAME and Apple2TS baselines apply; no new session is claimed.
