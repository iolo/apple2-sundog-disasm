# Three short retained p-code tails

Three exact matches account for another **70 disk bytes**: 53 code bytes and
17 metadata/alignment bytes. The build reuses the existing complete source
modules; no new opaque input or guessed instruction stream is introduced.

| Disk | Block + offset | Size | Source component + offset | Classification |
| --- | --- | ---: | --- | --- |
| 1 | 173 + 368 | 28 | `alternate_10` + $039A | 11 code, 17 data |
| 2 | 173 + 486 | 26 | `game_13` + $25E6 | 26 code |
| 2 | 189 + 496 | 16 | `game_14` + $07F0 | 16 code |

The first match is the exact final 28 bytes of the 950-byte alternate segment
10, not a changed footer variant. Six complete instructions store global 9,
push two zeroes, call segment 1 procedure 6, branch through a jump-table entry
and return. Their following alignment byte, jump pointer, procedure footer,
dictionary pointer and `10,1` segment trailer have the complete donor module's
verified boundaries. The entry displacement points to the donor's start; it
does not invent a missing entry before the copy.

The game-13 match contains the final 26 bytes of the donor's preceding 512-byte
block. It starts with the two operands of `IXP 16,1` at donor offset $25E5,
whose opcode is absent from the copied range. It includes the `$0800` buffer
load through library 22 procedure 53 and ends with a complete `IXP 16,1`.
The game-14 match likewise preserves a preceding block's final 16 bytes. Its
first two bytes are operands of `CXP 22,2` at donor offset $07EF; it then
contains a conditional branch, local-value/address loads, `CXP 27,8`, and a
comparison. The conditional branch's table remains in the complete donor
context; no table at the retained location is assumed.

All copied bytes have exact source matches and inherit the complete donor's
code/data classification. Clipped instructions record the full donor item and
which operand bytes survived. Their original procedures, branch targets and
metadata are independently decoded before accepting the slices. This is source
provenance evidence, not a claim that the retained copies currently execute.

## Verification

`tools/retained_pcode_tails.py` freezes these three extents and their hashes.
It freshly assembles all three donors, reruns their complete p-code analyses
against the shipped interpreter, compares their coverage/instruction/edge
summaries, checks the specific footer/clipped-instruction contexts, and verifies
every stored byte.
The ordinary source-copy planner enforces exclusive temporary ownership during
adoption. `--verify` checks the final source ownership and saved per-byte audit.
The general p-code-copy discovery thresholds remain unchanged.

```sh
python3 tools/retained_pcode_tails.py --verify
python3 tools/test_pcode_copies.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Normal builds use the three existing source modules. Both complete images
remain exact; no new emulator execution is claimed.
