# Retained Pascal stack data

Disk-1 blocks 260 and 263 have different, already reconstructed 20-byte code
components followed by identical 492-byte tails. These tails are retained
**128K Pascal stack data**, reconstructed by `src/data/retained_pascal_stack.s`.
They account for 984 disk bytes. Their classification follows mutually
consistent string-list pointers, saved call frames and activation bounds,
not the mere presence of printable device names.

The original memory mapping inferred from those structures is:

```
memory address = $EDE6 + containing-block byte offset
retained window = $EDFA–$EFE5
```

This is historical provenance, not a SunDog load address or a claim that
SunDog uses a 128K interpreter. The normal game runtime remains unchanged.

## Format evidence

The `BIG` conditional paths in Willi Kusche's
[Pascal interpreter disassembly](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf)
show the 128K string-copy layout: original p-code address, next-list pointer,
then a copied counted string in even-sized storage (pages 62–66). The call and
return paths save/restore the string-list head immediately before the saved
Pascal stack pointer (pages 108 and 113). These conditional paths are distinct
from the 64K configuration whose machine addresses appear in the listing.

The ordinary call-frame fields also match our reconstructed
`src/native/native_shared.s`: `$E1EE–$E1F7` saves MP, JTAB, SEG and IPC at frame
offsets 2–9, and `$E218–$E21B` stores the CPU stack-pointer byte at offset 10.
The static-link routines fill offset 0. The 128K prefix adds the separate
saved string-list word. The remaining byte at frame offset 11 is retained
storage, not a second CPU stack-pointer byte.

## Two string lists establish the address mapping

The first complete nodes begin at block offsets `$18,$1E,$24,$62`. They store
`/`, `.`, a 56-character device-description string, and `/`. The first three
next pointers are `$EE04,$EE0A,$EE48`, respectively; each points exactly to the
following node under the same `$EDE6` origin. The fourth pointer is zero.
The long node ends with one alignment byte, `$EF`, which is preserved as
alignment storage rather than appended to the string.

Bytes `$14–$17` are the clipped end of a preceding node: next pointer `$EDFE`
to the first complete node, followed by length 1 and `/`. Its missing original
address word is outside this tail and is not invented.

A second independent list contains nine six-byte nodes at `$142–$177`.
Eight next pointers increase by six from `$EF2E` through `$EF58`, then terminate
at zero. Their strings are `:`, `/`, empty, `:`, `:`, `!`, `[`, empty, empty.
All lengths, even-sized allocations and links agree with the same memory origin.
The original p-code addresses are retained as address data; the external
instructions they once referenced are not present in this data window.

## Call frames bound the remaining storage

| Mark address | Block offset | Dynamic link | Saved stack top | Saved string head |
| --- | --- | --- | --- | --- |
| `$EE52` | `$06C` | `$EFB6` | `$EFB2` | zero |
| `$EF9E` | `$1B8` | `$EFB6` | `$EFAC` | `$EFAC` |
| `$EFB6` | `$1D0` | `$F032` | `$F02E` | zero |

Each frame has its four-byte saved-state prefix, twelve-byte mark record,
static link `$F5EE`, and saved CPU SP `$F9`. Both child dynamic links resolve
to the retained parent frame. The first child's local/parameter area starts
at `$EE5E` and ends exactly at the parent's prefix, `$EFB2`.

The smaller reused frame's local storage ends at `$EFAC`. Both its saved stack
top and saved string head point to a complete empty-string node at block
offset `$1C6`; that node ends exactly at `$EFB2`. The parent locals begin at
`$EFC2` and extend to `$F02E`. Only their first 36 bytes survive in this block,
ending at `$EFE6`; no bytes beyond that boundary are reconstructed here.

These ranges account for every remaining byte as activation storage, including
parameters, local strings and values retained from earlier calls. Some older
string/frame remnants inside the larger local area have been overwritten;
they are not forced into valid live records. The surviving frames and string
lists need not have been active simultaneously. The source emits the complete
recognizable subrecords separately, preserving intervening local storage as
data with its owning frame and bounds. Detailed names and meanings of those
local fields remain optional; no executable code or new entry point is claimed.

## Verification

`tools/retained_pascal_stack.py` checks both duplicate tails, all complete string
nodes, the clipped leading node, call-frame links, saved stack bounds and full
gap-free data ownership. A fixed hash restricts acceptance to this reviewed
historical window; arbitrary pointer-looking buffers are not accepted. It
assembles typed source exactly and `--verify` checks regenerated artifacts and
manifest ownership. Tests independently reject changed links, lengths, frame
bounds and unreviewed local-data variants while excluding the code prefixes.

```sh
python3 -m unittest discover -s tools -p test_retained_pascal_stack.py
python3 tools/retained_pascal_stack.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The complete audit is `reference/retained-pascal-stack.json`. Normal builds use
the committed data declarations, without original images or downloaded evidence.
No new emulator run or live save/load validation is implied.
