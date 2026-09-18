# Statically identified unreachable branches

SYSTEM.PASCAL segments 2 and 6 contain four two-byte gaps after unconditional
branches. They are classified as p-code UJP instructions, not data. Their opcodes,
operand encoding, targets at already established instruction boundaries, and
placement in repeated conditional-join sequences provide the static evidence.
Runtime reachability is not established and is not needed to retain dead code
as code. The inference is that these are unoptimized compiler-emitted joins;
the historical compiler invocation is unknown.

| Segment | Procedure | Gap/instruction | Target | Preceding instruction | Predecessor target |
| --- | --- | --- | --- | --- | --- |
| 2 | 2 | `$0028`: UJP +9 | `$0033` | `$0026`: UJP via `$00D2` | `$00CF` |
| 2 | 5 | `$01D3`: UJP +9 | `$01DE` | `$01D1`: UJP via `$0302` | `$02FF` |
| 6 | 4 | `$0A86`: UJP +10 | `$0A92` | `$0A84`: UJP via `$0C64` | `$0C0F` |
| 6 | 4 | `$0AA0`: UJP +103 | `$0B09` | `$0A9E`: UJP via `$0C64` | `$0C0F` |

Offsets are relative to the respective segment, at disk-1 blocks 261 and 272.
The UJP encoding is independently established by native handler `$D2A8`.
Segment 2 repeats the same conditional structure in two procedures; segment 6
repeats an error-field assignment followed by a transfer out of a branch arm.
No inline-data instruction owns these bytes. Every new target coincides with
code decoded from the original procedure entry/exit paths.

The decoder requires explicitly supplied `--code-root` offsets. It does not
infer roots from arbitrary gaps, and it applies the same bounds and overlap
checks to supplied roots as to control-flow targets. The preparation tool also
requires this evidence document, and the generated listing marks the roots as
statically reviewed code with unproven runtime reachability.

Reproduction arguments for module preparation (already adopted modules refuse
overwrite):

```sh
python3 tools/prepare_pcode_component.py system_2 disk1 251 2 \
  --code-root 0x28 --code-root 0x1D3 \
  --root-evidence docs/pcode-unreachable-branches.md
python3 tools/prepare_pcode_component.py system_6 disk1 251 6 \
  --code-root 0xA86 --code-root 0xAA0 \
  --root-evidence docs/pcode-unreachable-branches.md
```
