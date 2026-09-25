# Reconstructed source

The source tree contains native 6502 instructions, Pascal p-code instruction
macros, custom dialogue instructions, and explicitly classified data. The
[manifest](../reconstruction/manifest.json) maps assembled components into both
disks; the [classification ledger](../docs/classification-ledger.md) records
code/data intervals independently of source-file placement.

| Directory / family | Representation and evidence |
| --- | --- |
| `native/bootstrap.s`, `native/title_draw.s`, `native/play_boot.s` | Boot/title routines and embedded data; [bootstrap](../docs/bootstrap.md), [title](../docs/title-draw.md), [play boot](../docs/play-disk-boot.md) |
| `native/pcode_primitives.s`, `native/native_{io,shared,init,high}.s` | Complete SYSTEM.APPLE runtime; [runtime classification](../docs/runtime-classification.md) includes overlapping instructions and clipped operands |
| `pcode/*.s`, `pcode/encoding.inc` | Pascal instructions, attributes, dictionaries and embedded constants; [toolchain](../docs/pcode-toolchain.md) and [inventory](../docs/pascal-segments.md); mixed native procedures use 6502 instructions |
| Other `native/*.s` | Raw screen, I/O, animation, checksum and retained native modules; individual reports live in `docs/reference/raw-modules/` |
| `native/encoded_*.s` | Decoded native source with reversible storage encoding applied by the builder; [both banks are classified](../docs/encoded-bank-completion.md) |
| Retained p-code/native families | Reassembled donor contexts and documented partial copies, including [linker code](../docs/retained-linker-code.md), [short tails](../docs/retained-short-tails.md) and [native tails](../docs/native-block-tails.md) |
| `dialogue/scripts.s`, `dialogue/encoding.inc` | 96 custom dialogue records interpreted by game 16; [script format](../docs/dialogue-scripts.md), separate from their extracted text |
| `data/*.s` | Typed data/storage declarations supported by individual evidence reports; membership in this directory does not establish classification |

Linker `.cfg` files preserve component placement. `.adopt.json` recipes record
how a reviewed component replaced temporary input. Evidence under `evidence/`
and `docs/reference/` records decoding roots, relocation/metadata boundaries,
consumer windows and exact source contexts. A copied instruction fragment is
explicitly tied to its complete donor; it is not silently relabeled data.

```sh
python3 tools/build_disks.py
python3 tools/classification_ledger.py
```

Generated component binaries, listings and maps appear under
`build/disks/components/`; encoded components also retain `.decoded.bin` files.
The manifest decides which bytes of a full source context actually reach a disk.
Exploratory disassembly belongs under ignored `build/` until reviewed.

Current reconstruction still uses **488 unidentified temporary bytes** outside
the accepted code/data components. Their four tail types and evidence limits
are listed in [unresolved-tails.md](../docs/unresolved-tails.md). The initializer
protection payload, runtime provisional fields, encoded bodies and viewscreen
output storage described as unfinished in earlier versions of this index are
now covered by their respective audits. See the
[delivery checklist](../docs/delivery-checklist.md) for the remaining requirements.
