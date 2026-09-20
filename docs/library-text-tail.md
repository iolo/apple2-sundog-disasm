# Retained text after library 22

Both disks contain the same 18-byte suffix at logical block 115, offsets
494–511: ASCII `an;`, carriage return `$0D`, then fourteen NUL bytes. These
**36 disk bytes are classified as retained text data and fill**, using the
recognizable text/line-ending/storage structure and complete preceding segment
boundary. This is a format inference, not a recovered original source file.

Library 22 occupies exactly 6,126 bytes starting at block 104. Its valid
63-procedure dictionary starts at module offset 5,998 and ends with the segment
and procedure-count bytes at 6,124/6,125. The retained text begins immediately
after that complete dictionary; it is not included in the disassembled segment.
Both complete modules and their tails agree byte for byte.

The suffix has a familiar Pascal declaration ending, but the missing prefix is
not recovered: the source deliberately preserves `an;` without expanding it to
`boolean;` or inventing an identifier. Text is data even if it once belonged to
a source-code file. There is no claim that these characters are runtime dialogue
or that the game reads them as text.

## Historical format corroboration

The already consulted UCSD p-System source, commit
`f0a8e66f6aff82e95207300e11e310155d2d1599`, establishes the relevant format:

- [system/globals.text](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/system/globals.text#L101)
  defines end-of-line as ASCII CR (13).
- [system/system.c.text](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/system/system.c.text#L239)
  recognizes CR as a text line ending and NUL as the end of a two-block text
  page; FWRITELN emits that line ending.
- [system/system.b.text](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/system/system.b.text#L173)
  fills the unused part of a final file block with zero before writing it.
- [compiler/procs.b.text](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/compiler/procs.b.text#L309)
  shows a separate reason code allocations can retain suffix bytes: WRITECODE
  copies the current code extent into a disk buffer and, when forced, writes
  its whole block without clearing the unused suffix. FINISHSEG records the
  exact segment length before making that forced write.

These routines corroborate the text/fill format and a possible retention
mechanism. They do **not** identify the actual producer of this SunDog suffix,
prove a particular compiler version, or classify arbitrary code-allocation
tails. Other tails containing instructions remain disassembled as instructions.

## Reconstruction

`src/data/library_text_tail.s` explicitly declares the three characters, CR and
fourteen zeros. Its single 18-byte output maps to both disks. The audit checks
the entire preceding source-built module, its hash and dictionary, all payload
owners, exact text/fill boundaries, fresh assembly and adopted ownership.

```sh
python3 tools/test_library_text_tail.py
python3 tools/library_text_tail.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests reject changes across the segment/tail boundary, every text/fill byte,
and truncated or extended allocations. Normal builds need only the committed
source; external historical sources and original disk images are not inputs.
