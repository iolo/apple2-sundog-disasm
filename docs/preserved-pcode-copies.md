# Preserved copies of disassembled Pascal module ranges

Twenty-six previously unresolved extents, totaling **8,030 bytes**, are exact
copies of ranges in **17 already disassembled p-code modules**. They include
partial module tails, three consecutive blocks of game segment 8 on disk 1,
an additional repeated game-8 block, and three identical saved-bank suffixes.
This identifies their instruction/data content without asserting that a loader
currently enters any of these copies or that all copies belonged to one file.
The per-item audit identifies **6,805 code bytes and 1,225 data bytes**. Twenty-three
copied instruction items have a clipped boundary; their complete instructions
remain in the existing source and are named in the copy audit.

## Classification evidence

Every reviewed extent matches at least 64 consecutive bytes of a known assembled
module; the first 64 bytes contain at least ten distinct values. This excludes
simple zero/constant fill matches. The recipe freezes each complete copy's hash,
source component, original module audit, source byte offset and destination.
Those criteria locate substantial candidate copies; classification additionally
requires the existing module's complete independently parsed instruction/data
ownership, not byte similarity alone.

The verifier freshly assembles all 17 source modules and checks their full hashes
against the reconstruction manifest and original audit. It checks the p-code
interpreter dispatch baseline, reruns each complete p-code analysis, and requires
its code/data coverage to match the original audit. It then records **every
copied item**, its original assembly, original item boundaries, copied size and
code/data classification. If a copy begins or ends inside an instruction or a
data item, the clipped boundary is explicit. The complete original instruction
is already present in the delivered source; none of these bytes becomes an
unidentified fragment or an opaque executable asset.

All 8,030 selected bytes are mapped directly to ranges of the **existing assembled
source components**. The original complete modules keep their original mappings,
so source outside a particular copy's clipped boundary remains represented and
validated. No duplicated binary input or extraction step is added to the normal
build. This source reuse changes disk ownership only; output bytes remain exact.

The recipe is `src/pcode/evidence/preserved_copies.json`. The detailed item audit
and physical sector mappings are in `docs/reference/preserved-pcode-copies.json`.
The following offsets are logical disk-block offsets and segment-relative source
offsets, respectively.

| Disk | Block + byte | Bytes | Existing source | Source offset |
| --- | --- | ---: | --- | --- |
| disk1 | 36 + 416 | 96 | `game_12` | `$0C70` |
| disk1 | 46 + 416 | 96 | `game_12` | `$0C70` |
| disk1 | 56 + 416 | 96 | `game_12` | `$0C70` |
| disk1 | 128 + 446 | 66 | `library_25` | `$01BE` |
| disk1 | 138 + 80 | 432 | `library_27` | `$0450` |
| disk1 | 146 + 332 | 180 | `startup_7` | `$054C` |
| disk1 | 147 + 0 | 1536 | `game_8` | `$0000` |
| disk1 | 150 + 0 | 512 | `game_8` | `$0400` |
| disk1 | 159 + 252 | 260 | `alternate_7` | `$00FC` |
| disk1 | 166 + 276 | 236 | `alternate_8` | `$0B14` |
| disk1 | 169 + 188 | 324 | `alternate_9` | `$02BC` |
| disk1 | 171 + 438 | 74 | `alternate_10` | `$01B6` |
| disk1 | 173 + 396 | 74 | `alternate_10` | `$01B6` |
| disk1 | 262 + 296 | 216 | `system_2` | `$0128` |
| disk1 | 271 + 134 | 378 | `system_5` | `$0486` |
| disk1 | 279 + 68 | 444 | `system_6` | `$0C44` |
| disk2 | 128 + 446 | 66 | `library_25` | `$01BE` |
| disk2 | 138 + 80 | 432 | `library_27` | `$0450` |
| disk2 | 146 + 332 | 180 | `startup_7` | `$054C` |
| disk2 | 153 + 58 | 454 | `game_8` | `$0A3A` |
| disk2 | 184 + 426 | 86 | `game_12` | `$13AA` |
| disk2 | 195 + 94 | 418 | `game_15` | `$085E` |
| disk2 | 210 + 278 | 234 | `game_16` | `$1B16` |
| disk2 | 230 + 136 | 376 | `game_18` | `$1688` |
| disk2 | 241 + 80 | 432 | `game_19` | `$1250` |
| disk2 | 255 + 180 | 332 | `game_20` | `$18B4` |

## Validation and limits

```
python3 tools/test_adopt_component.py
python3 tools/test_pcode_copies.py
python3 tools/pcode_copies.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The copy planner rejects changed source/disk bytes, stale baselines, overlapping
outputs, out-of-bounds slices, sources without existing disk ownership, and
replacement of already classified bytes. Post-adoption verification checks every
mapping's actual source ownership as well as its bytes and classification audit.
The tests also verify clipped instruction/data boundaries and reject uncovered
source bytes. The frozen recipe performs no automatic search or blanket
classification during adoption or verification.

Other residual bytes, including shorter possible matches, remain unresolved.
Matching an already reconstructed sequence proves its content and source
provenance; it does not establish runtime use, a complete preserved historical
module, or final validation in either emulator.
