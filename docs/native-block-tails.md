# Native block footers, zero storage and the retained buffer transfer

This checkpoint completes classification of disk-1 blocks **2 and 156**. The
existing source components retain their reconstructed prefixes; the new
`src/native/native_block_tails.s` supplies the remaining **634 bytes**: one
three-byte native instruction and 631 bytes of structured metadata/storage.

## Buffer transformer: the unused JMP is code

The [buffer transformer](raw-buffer-transform.md) sets zero-page $04 to zero
at relative offset $0028. The parameter-copy loop at $0014–$001C installs the
input page at $05, and $0023–$0025 saves that page on the hardware stack.
After the transform advances through the requested pages, $0041–$0042 restores
the original page into $05. The following push/pop sequence removes the saved
loop count while retaining the caller's return address. These operations leave
$04/$05 as the start address of the transformed buffer.

The retained bytes at offsets $005D–$005F decode as `JMP ($0004)`, located at
$0F9D when this block is loaded at $0F40. They would transfer to the restored
buffer pointer: $4000 or $5800 for the two evidenced parameter sets described
in [the encoded-overlay audit](encoded-native-overlay.md). This is an unused
native tail-transfer instruction, not a three-byte data blob. Its operand and
role are supported by the preceding pointer preparation and the independently
identified native loaders at those buffer starts.

The actual stored routine writes `SHIP` and executes RTS at offset $005C.
Consequently the transfer is bypassed by the known entry path. No live execution
of the retained JMP, no removed protection check, and no modified runtime
behavior are claimed. The new source assembles the existing instruction exactly.

## Complete native-container metadata

The existing Pascal dictionary and native relocation parsers independently
validate one-procedure native containers ending at offset **314** in block 2
and **112** in block 156. Both have lexical level zero, four empty relocation
lists, a backward entry displacement, native attributes, a dictionary pointer,
and the segment/procedure-count trailer `1,1`.

| Block | Remaining instruction/alignment | Relocation counts | Entry word | Attributes | Dictionary/trailer | Zero block storage |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | $0129: one zero alignment byte | $012A–$0131 | $0132: $0132 | $0134–$0135 | $0136–$0139 | $013A–$01FF (198 bytes) |
| 156 | $005D–$005F: JMP ($0004) | $0060–$0067 | $0068: $0068 | $006A–$006B | $006C–$006F | $0070–$01FF (400 bytes) |

Both stored entry words resolve to offset zero. In block 2 that location is the
already identified HGR address table; the actual raw caller enters at offset
192. The metadata is therefore not used to invent an execution path through the
table. It still defines a complete native-container footer that ends before the
block's remaining zero storage.

The zero ranges are classified within the **one-block overlay allocations**
established by the actual loaders, immediately after complete validated native
footers. Every byte in those ranges is checked as zero. This combines container
metadata, loader extent and bounded fill evidence; it is not an arbitrary scan
for unexecuted zero bytes. Any nonzero byte in the selected storage ranges is
rejected and would need its own classification. Other overlays with nonzero
trailers are not included in this checkpoint.

## Reproduction and validation

```
python3 tools/test_native_block_tail.py
python3 tools/native_block_tail.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Preparation checks the exact existing source prefixes, both parsed footers,
alignment, the indirect-JMP instruction, every zero-storage byte, and complete
non-overlapping ownership of both tails. The generated declarations assemble
exactly before adoption. Tests reject changed transfer opcodes/operands, malformed
metadata, nonzero alignment, and nonzero bytes in the block storage.

Both full blocks now have explicit code/data ownership. Final emulator behavior
checks and the remaining whole-disk audit remain separate requirements.
