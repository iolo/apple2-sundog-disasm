# Encoded overlay body: instruction graph and explicit residual gaps

The two banks described in [the loader audit](encoded-native-overlay.md) have
matching native instruction graphs after relocation to $0C00 (play) or $1000
(alternate). Offsets below are relative to the full 2,048-byte decoded bank.
This is static reconstruction; live invocation of either body is still unproved.

## Reviewed graph

The loader's call at offset $0037 reaches body offset $01F9. Its indirect jump
reads the word at $0233, which points to $04AB. Following embedded vectors,
ordinary branches, direct calls and returns identifies 447 instructions without
any instruction/data overlap. A disconnected three-byte JMP at $005D uses the
word at $0214 to reach the already established $0220 instruction boundary; its
block structure and relocation match the other stubs. It is disassembled as
unused code, bringing the audit to **448 instructions / 1,079 code bytes per
bank**. There are **126 used two-byte jump vectors**. Both variants have the
same instruction offsets and edges; selected output addresses and immediate
constants also differ, so they are assembled separately.

The decoder requires an explicit model for every indirect jump, checks the
actual vector address and both stored target bytes, requires data ownership of
the vector bytes, and follows the target as code. It models NMOS page wrapping,
rejects duplicate/unused models and code/data overlaps, and never assigns data
status to a byte simply because control flow did not reach it.

The fixed-pointer interpretation applies before the failure path starts wiping
memory. Reviewed ordinary writes target zero page, the head-position variable
$047E, output bytes, and the separate state at offsets $05E7/$05F1–$05F5/
$05F8–$05F9. The indexed disk-read store at $0596 receives bounded Y from its
call paths; it does not reach a jump vector. No ordinary store rewrites a vector.
The routine at $05FC switches language-card access, loads its initial pointer
from $05FA/$05FB, and enters a descending zero-store loop. That path has no RTS
and may destroy code and vectors as it runs. The static graph describes the
original instructions, not execution after self-destruction or a proof that its
caller returns. The graph conservatively disassembles the continuation after
that JSR as well.

## Embedded data

The evidence recipes explicitly enumerate 418 data bytes per variant:

- 252 bytes of consumed indirect-jump pointers.
- The two-byte stored body-entry address at $008E, which matches the loader call.
- XOR constants $2C at $020E and $DA at $051F, read by absolute EOR instructions.
- The four-byte track sequence at $0352: $22,$23,$22,$FF. The indexed reader
  increments the index and uses the sign bit to distinguish its terminal value.
- The retry counter at $05E7, eight-byte disk-symbol search table at $05E8,
  five-byte read buffer at $05F1, track index at $05F8, read mode at $05F9,
  and two-byte initial wipe address at $05FA. Recipe entries identify consumers.
- 140 one-byte obfuscation delimiters at explicitly reviewed block boundaries.
  They use repeated opcode-shaped values (notably the recurring sequence
  A9/AD/E6/D0/CD/4C/6C/20/6D/8D/84) around the physically shuffled blocks.
  They are separated from executed entries by transfers, returns, or pointer
  words, and the same delimiter positions/values occur in the relocated bank.
  This repeated layout, together with the complete non-overlapping graph and
  its data references, identifies deliberate obfuscation data. They are not
  blanket gap fill, and are individually enumerated in the recipes.

## Unresolved bytes remain separate

The later [footer and copied-tail audit](encoded-native-overlay-tail.md) resolves
464 of the 488 bytes left by this body checkpoint. Its separate components leave
the original body audit unchanged and bring the current bank remainder to 24
bytes per variant. A subsequent [retained-stub audit](encoded-retained-stubs.md)
classifies another 18 bytes per bank while preserving this graph's data
ownership and strict decoding rules. The current remainder is six bytes per
variant. The historical scope of this report is described below.

At this body checkpoint, the jump-shaped stubs at $0357 and $035D, associated
words at $0572 and $05DB, the word at $05E3, and isolated bytes at
$05F0/$05F6/$05F7 remained unresolved.
Following the disconnected stubs leads into pointer-shaped bytes and an
unsupported opcode; no code/data decision is forced for that path. The bank
suffix beginning at $0627 also remained unresolved. It contains both short
metadata-like bytes and a substantial copy of earlier native material, so it
cannot be classified wholesale as padding or an image.

The full report deliberately includes the previously reconstructed 63-byte
loader as outside this body audit. Thus its 551 unclassified offsets comprise
63 already source-built entry bytes and **488 still-unresolved body/tail bytes**.
Eight fully classified intervals contain **1,497 adopted bytes per bank**.
No source is emitted for omitted intervals: each selected interval is a separate
ca65 component with its actual runtime origin and original storage-encoding
phase. All assembled bytes have disk mappings. Cross-interval branch/call labels
retain their runtime addresses. This keeps the source builder and adoption
checks strict while allowing a partial, explicitly bounded reconstruction.

## Reproduction

`tools/prepare_encoded_overlay.py` reads the current exact rebuilt disk, verifies
the reviewed stored hash, decodes the bank, reruns the graph and data ownership
audit, assembles every selected interval, and checks both plaintext and re-encoded
bytes. `--verify` compares the complete generated artifacts without adopting.
The ordinary disk build uses only committed source and reconstruction inputs.

```
python3 tools/test_native_raw_source.py
python3 tools/test_storage_encoding.py
python3 tools/test_adopt_component.py
python3 tools/prepare_encoded_overlay.py src/native/evidence/encoded_body_play.json --verify
python3 tools/prepare_encoded_overlay.py src/native/evidence/encoded_body_alternate.json --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

This checkpoint does not complete bank classification, establish live execution,
or satisfy final game validation in both emulators.
