# Retained compiler identifier and parameter records

Disk-1 block 258 offsets 52–511 retain a **460-byte compiler heap window**.
Eleven complete named identifiers, nine complete parameter records, a pointer
type and two clipped records account for every byte. The inferred historical
mapping is memory address `$2540` plus block offset, giving a retained window
of `$2574–$273F`.

`src/data/retained_compiler_heap.s` emits typed record fields and explicitly
identified unused field storage. This is historical data provenance, not a
SunDog runtime heap address or a claim that its compiler is present on the disk.

## Record definitions and constructor evidence

The UCSD compiler's original
[identifier and structure definitions](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/compiler/compglbls.text)
and [standard-procedure initialization](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/compiler/compinit.text)
provide the format. An identifier begins with an eight-character name, tree
links, type pointer, next pointer and class. Its variant contains either variable
fields or procedure declaration kind and intrinsic number. Standard parameter
construction initializes its type, class and next pointer; it leaves the name,
tree links and variable-location fields uninitialized. A pointer type contains
size, form and element-type pointer. This related source establishes field
meaning; its intrinsic list is not claimed to be identical to Apple's version.

Apple's actual constructor supplies independent allocation/write evidence.
The archived [Apple Pascal 1.2 disk](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/programming/pascal/ucsd/UCSD%20Pascal%201.2_2.DSK)
contains SYSTEM.COMPILER's COMPINIT segment 7 at file offset 5632, length 3400.
Procedure 8 occupies segment offsets 1754–2201. Its dictionary and attribute
record establish the procedure; two bounded instruction excerpts are frozen
in `src/data/evidence/retained_compiler_heap.json`:

- Procedure offsets `$CD–$F3` allocate eleven words for a formal-parameter
  identifier and three words for its pointer type. They initialize pointer
  size/form/element as `1,2,nil`, and parameter type/class at word offsets 6/8.
- Offsets `$150–$1A7` allocate eleven words for each standard symbol, copy its
  eight-byte name, write declaration kind and intrinsic number at words 9/10,
  class at word 8, and type/parameter head at words 6/7. They also terminate
  a non-nil parameter chain through its word-7 next field.

These are bounded consumer excerpts, not a claim to have classified the whole
external compiler. The optional external-file verification checks their bytes,
procedure metadata and full allocation/segment hashes. The same 22-byte record
boundaries independently recur throughout the SunDog residue.

## Field layout

| Byte offset | Named standard identifier | Standard parameter record |
| --- | --- | --- |
| 0–7 | NAME | unused NAME storage |
| 8–9 | LLINK | unused LLINK storage |
| 10–11 | RLINK | unused RLINK storage |
| 12–13 | IDTYPE | IDTYPE |
| 14–15 | NEXT, parameter-list head | NEXT, following parameter |
| 16–17 | KLASS: 5 procedure / 6 function | KLASS: 2 formal / 3 actual |
| 18–19 | PFDECKIND: 0 standard | unused VLEV storage |
| 20–21 | CSPNUM | unused VADDR storage |

The named records at block offsets 56, 106, 128, 150, 194, 216, 238, 260,
282, 304 and 370 contain ROUND, MARK, RELEASE, IORESULT, UNITBUSY, PWROFTEN,
UNITWAIT, UNITCLEA, HALT, MEMAVAIL and STRTONUM. Their intrinsic numbers are
24 and 32–41. Unused return-type storage and tree links are preserved, not
repaired to match another compiler release.

## Links establish allocations and the common origin

- MARK and RELEASE both point to `$258E`, the parameter at block offset 78.
  Its type pointer is `$25A4`, exactly the six-byte pointer-type record at
  offset 100. That record ends at the next named allocation, MARK at offset 106.
- UNITBUSY, PWROFTEN, UNITWAIT and UNITCLEA share parameter `$25EC` at offset 172.
- STRTONUM points to `$2686` at offset 326. Its next pointer `$269C` reaches
  the next 22-byte parameter at offset 348, whose link is nil.
- A further five-parameter chain begins at offset 392: next pointers `$26DE`,
  `$26F4`, `$270A` and `$2720` reach offsets 414, 436, 458 and 480, then nil.
  The next allocation begins with NUMTOSTR at offset 502. Its missing head
  pointer is not invented or used to claim that it owns this chain.
- ROUND's head `$2562` locates a preceding parameter at offset 34. Only its
  last four bytes (VLEV/VADDR storage at offsets 52–55) survive after the current
  code prefix. The earlier eighteen bytes are excluded.

The final NUMTOSTR fragment contains its complete name and first tree-link
word. Its remaining twelve bytes lie beyond the window and are excluded.
These allocations partition all 460 bytes with no gaps or overlaps.

## Why native-looking bytes are data here

Several parameter records retain old 6502-looking sequences in their unused
NAME, tree-link and variable-location fields. The format and constructor show
exactly why those bytes can survive: allocating a record does not clear its
unwritten fields. Their data ownership follows the independently linked,
22-byte allocations and identified field offsets, rather than an assumption
that an unexecuted region is data. They are not separate surviving routines
between allocations. The source names these fields explicitly and preserves
their contents. No unrelated native fragment is classified by this argument.

## Verification

```sh
python3 -m unittest discover -s tools -p test_retained_compiler_heap.py
python3 tools/retained_compiler_heap.py --verify
python3 tools/retained_compiler_heap.py --verify --external-compiler /tmp/pascal12-compiler-full.bin
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The maintenance tool checks names, classes, intrinsic numbers, all reviewed
links, pointer-type fields, complete ownership and the fixed snapshot hash.
It assembles every field exactly, regenerates the audit and checks manifest
ownership. Tests reject changed structure and unreviewed unused-field bytes.
Normal builds use only committed source declarations; the downloaded compiler
and source repository are not dependencies. No new emulator run is implied.
