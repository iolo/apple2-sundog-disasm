# Copies corresponding to the early startup and utility audits

The extended source-copy review identifies another **15 ranges / 2,538 bytes**
using the complete startup-1 and utility-1 audits from steps 06g and 06h. These
reports predate the `reference/pcode-modules` directory used in the first copy
checkpoint. Their complete source, hashes, decoder evidence and code/data counts
provide the same independent classification basis.
The new item audit accounts for 1,759 instruction bytes and 779 data bytes.

Two 448-byte ranges, at block 142 offset 64 on both disks, match startup-1
source offsets $0040–$01FF. The other thirteen ranges lie in disk-1 blocks
151–155 and match substantial portions of the utility source. The surrounding
bytes contain genuine differences; this review **does not** declare the entire
five-block area an exact copy, classify the differences as data, or infer a
complete older utility version. Only the individually hashed matching extents
below are adopted.

The later [utility-variant procedure reconstruction](utility-variant-procedures.md)
independently decodes fifteen complete procedures in that area. It preserves
these exact-copy mappings while classifying 782 previously unresolved bytes.

The [existing copy workflow](preserved-pcode-copies.md) freshly assembles both
modules, reruns their complete p-code analysis, and compares the resulting
classification to the early audits. Per-item reports retain complete original
assembly, original source boundaries, and clipped code/data edges. Disk mappings
reuse the existing assembled source components; no new executable blob or
build-time extraction is introduced.

| Disk | Block + byte | Bytes | Existing source | Source offset |
| --- | --- | ---: | --- | --- |
| disk1 | 142 + 64 | 448 | `startup_disk1` | `$0040` |
| disk1 | 151 + 0 | 64 | `utility_disk1` | `$1216` |
| disk1 | 151 + 65 | 125 | `utility_disk1` | `$1257` |
| disk1 | 151 + 231 | 83 | `utility_disk1` | `$12FD` |
| disk1 | 151 + 315 | 75 | `utility_disk1` | `$1351` |
| disk1 | 151 + 425 | 71 | `utility_disk1` | `$13BF` |
| disk1 | 152 + 23 | 153 | `utility_disk1` | `$142D` |
| disk1 | 152 + 184 | 152 | `utility_disk1` | `$14CE` |
| disk1 | 152 + 337 | 90 | `utility_disk1` | `$1567` |
| disk1 | 153 + 74 | 72 | `utility_disk1` | `$1660` |
| disk1 | 153 + 281 | 82 | `utility_disk1` | `$172F` |
| disk1 | 154 + 67 | 257 | `utility_disk1` | `$1963` |
| disk1 | 154 + 469 | 197 | `utility_disk1` | `$1B25` |
| disk1 | 155 + 291 | 221 | `utility_disk1` | `$1C73` |
| disk2 | 142 + 64 | 448 | `startup_disk1` | `$0040` |

The frozen recipe is `src/pcode/evidence/early_module_copies.json`; the detailed
item audit and physical sector mappings are `docs/reference/early-module-copies.json`.
The tool now accepts explicit recipe/audit paths, preserving the first checkpoint's
default recipe and verification behavior.

```
python3 tools/test_pcode_copies.py
python3 tools/test_adopt_component.py
python3 tools/pcode_copies.py --verify
python3 tools/pcode_copies.py --recipe src/pcode/evidence/early_module_copies.json --audit docs/reference/early-module-copies.json --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

These checks prove source correspondence, classification, ownership and exact
reconstruction. They do not establish runtime entry into any preserved copy,
classify the remaining modified utility bytes, or complete emulator validation.
