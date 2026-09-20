# Disconnected jumps and retained pointers in the encoded banks

Two indirect jump instructions remain in each encoded native bank outside the
reviewed entry graph. Their block structure and address relocation establish
them as **unused native instructions**, even though following their chain does
not produce a valid executable path. This audit supplies 12 instruction bytes
and 24 pointer-data bytes across the two banks; six bytes per bank remained open
at this checkpoint. They are now covered by the
[complete-bank audit](encoded-bank-completion.md).

Offsets below refer to the decoded 2,048-byte bank. Add `$0C00` for the play
variant or `$1000` for the alternate variant to obtain original runtime addresses.

| Instruction offset | Instruction | Pointer offset | Stored target offset |
| --- | --- | --- | --- |
| `$0357` | `JMP (base+$0572)` | `$0572` | `$035D` |
| `$035D` | `JMP (base+$05DB)` | `$05DB` | `$05DD` |

Both instructions occupy the same three-byte slots between a previously
classified `$AD` obfuscation delimiter and a consumed two-byte jump vector.
All operands and pointer words relocate by exactly `$0400` between the two
banks. This is the same independently documented shuffled instruction/vector
layout as the surrounding [encoded body](encoded-native-overlay-body.md).
No edge in its reviewed graph enters either new stub. These observations
support instruction identity, not live execution.

The second jump targets `$05DD`, the first of three **already consumed data
vectors** at `$05DD`, `$05DF`, and `$05E1`. These words retain their established
data classification. Attempting to follow the disconnected chain as executable
code conflicts with that evidence. The new audit therefore records the two
instructions and their pointer relationships without adding roots or changing
the strict graph decoder. It does not assert that the second jump safely
returns, that the data at its target is new code, or that a historical protection
path has been recovered. A retained instruction can be disassembled without
claiming its current destination is executable.

The two-byte field at `$05E3` is classified as a **retained address of the track
sequence**. It fills the word-aligned slot between those three consumed vectors
and the consumed vector at `$05E5`, relocates by the same `$0400`, and resolves
exactly to the already classified four-byte track sequence at `$0352`:
`22 23 22 FF`. Thus its pointer-data identity is supported by field layout,
relocation and a known target. No current consumer of this field is claimed;
it is not added to the indirect-jump models.

The previously established [copied suffix](encoded-native-overlay-tail.md)
retains exact copies of all three newly classified words at `$0772`, `$07DB`
and `$07E3`. They contain the original target addresses, not addresses adjusted
to the copied storage location. No copies of the two new instructions lie in
that suffix. Each bank gains six instruction bytes and twelve data bytes.

Remaining bank offsets at this checkpoint were `$05F0`, `$05F6`, `$05F7` and their copies `$07F0`,
`$07F6`, `$07F7`. The stored values are `FF`, `D5`, `D7`; their proximity to
symbol/buffer data does not by itself complete their classification.

## Verification

`tools/encoded_retained_stubs.py` replays the original strict body audit on both
exact banks, checks the instruction decoder, delimiters, neighboring vectors,
target words, track-sequence data, copied fields and nonoverlapping ownership.
It compares the normalized layouts across relocations. Every separate slice
assembles with ca65 and retains its original additive encoding phase. Normal
builds read only these committed sources/configurations.

```sh
python3 tools/test_encoded_retained_stubs.py
python3 tools/encoded_retained_stubs.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The tests mutate each newly classified byte in both banks, change surrounding
ownership and introduce an incoming edge. They also force the stubs into the
original graph and require rejection, guarding against accidentally treating
their data destination as live code. The generated audit is
`docs/reference/encoded-retained-stubs.json`. Full disk bytes remain unchanged,
so the existing dual-emulator behavior baseline continues to apply.
