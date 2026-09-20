# Encoded native overlays and position-independent loaders

The four-block bank at disk-2 block 41 decodes to **native code**, not an image.
Disk-1 block 197 contains a related encoded native bank. Their first 63 bytes
are now disassembled in `src/native/encoded_loader_play.s` and
`encoded_loader_alternate.s`. The rest of each bank remains unresolved pending
indirect-flow and embedded-data analysis; it is not adopted as an opaque asset.

## Encoding evidence

The [raw buffer transformer](raw-buffer-transform.md) adds an eight-bit value
to each byte and increments that value after every byte. Utility procedure code
sets segment-29 word 58's parameters to `[64,4,189,243]` at $097A–$0995:
destination page $40, four blocks, seed 189, increment 243. Game 15 procedure 8
reads four blocks from `word32+12+3=41` into $4000 at $02FA–$0304, then conditionally
calls that transformer with word 58 at $030C–$0312. Decoding therefore uses:

```
decoded[i] = (stored[i] + seed + i*step) & 255
stored[i]  = (decoded[i] - seed - i*step) & 255
```

The adjacent parameter set at word 56 is `[88,4,251,185]`, established at
$095E–$0979. Applying this second evidenced encoding to disk-1 blocks 197–200
reveals the same loader structure, with its destination and called body moved
by $0400. That correspondence supports the disk-1 decoding and code identity;
a live load/invocation of that bank is not claimed. $5800 is the source assembly
origin suggested by the destination-page parameter; the loader discovers its
actual origin from the stack and does not depend on that assumed load address.

The transformer also writes `SHIP` to $1801–$1804. Those writes are outside both
encoded source buffers, so they do not affect the reversible storage transform.

## Complete loader instruction paths

At offset zero the routine loads zero into A and saves processor flags. It writes
an RTS opcode to zero page $0000, calls it, then rewinds the hardware stack by
two bytes to recover the JSR return address. That address is `entry+9` and
becomes the first swap pointer. This tightly connected instruction sequence,
coherent branch targets, and the matching relocated variant establish native
code even without claiming that the original game currently invokes it.

The second pointer is $0C09 in the play variant and $1009 in the alternate.
X starts at eight; Y starts at $36. The loop swaps bytes through both pointers,
increments Y, advances both pointer high bytes on overflow, and decrements X.
Thus it swaps **1,994 bytes**: 202 on the first pass and 256 on each of seven
more passes. Relative to the input entry, the extent is offsets **$003F–$0808**
inclusive. The final nine bytes lie beyond the four-block source read; their
runtime contents are not inferred from the disk bank. The low-memory ranges
are $0C3F–$1408 or $103F–$1808, respectively.

After restoring flags, the initial zero flag permits the fixed call to $0DF9
or $11F9 in the swapped body. A is then set to $FF and control branches back
to offset two. The second swap restores the previous memory contents; restoring
the saved nonzero flags skips the body call and reaches RTS at offset $3E.
All 63 selected bytes are instructions. The following NOP at offset $3F is
part of the exchanged region and remains outside the adopted entry routine.

The body starts with dense indirect-jump structures and includes disk-controller
accesses. Full instruction/data ownership and runtime invocation remain open.
In the currently traced game-15 path, the transformer itself writes `SHIP`,
and the $4000 buffer is subsequently overwritten by the known ship-image read.
No call to the decoded entry has yet been established in that path.

## Build and validation

Source components may now specify the strict `additive-byte-sequence` storage
encoding with a seed, step, stream offset, and evidence document. The builder
assembles ordinary 6502 instructions, retains a `.decoded.bin` build artifact,
then applies the inverse encoding before hash checking and disk placement.
No original image or encoded binary source is a build dependency.

Raw preparation verifies the stored hash before decoding, accounts for every
selected instruction, and proves exact plain assembly. Adoption independently
re-encodes that assembly and compares it to the current built disk bytes.
The two adoption recipes carry their different encoding parameters. Future
fragments must retain the correct stream offset; the sequence cannot restart
at a fragment boundary without adjusting its phase.

```sh
python3 tools/test_storage_encoding.py
python3 tools/test_adopt_component.py
python3 tools/test_native_raw_source.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests include known stored/decoded instruction bytes, all byte values, stream
wraparound, split-fragment phase, malformed encoding rejection, and adoption
of encoded source rather than plaintext. Both complete disk images remain exact.
This checkpoint identifies 126 code bytes; it does not claim full reconstruction
or live execution of either encoded body or final emulator completion.
