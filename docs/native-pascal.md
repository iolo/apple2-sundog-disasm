# Native procedures embedded in Pascal segments

The interpreter accepts a zero procedure-number byte as a native entry. At
`$E155`–`$E17B`, it follows the backward word at attributes minus two, pushes a
synthetic return to `$E17E`, and jumps to the resolved entry. Thus these regions
are native 6502 instructions even though their enclosing file is Pascal code.

## Relocation list layout

The loader at `$E5C7` resolves the same entry and starts a relocation cursor at
attributes minus four. It invokes `$E3FD` four times, changing the addend each
time. Each list consists of a word count at the cursor and that many backward
pointer words immediately preceding it. A pointer word at `P` names the word
at `(P - stored_word) & $FFFF`; the loader adds the current relocation base to
that target word. It then continues backward to the preceding list.

| Traversal order | Name used in source | Addend selected by loader |
| --- | --- | --- |
| 1 | global | Selected data-segment base or current/global frame (`$E5EB`–`$E60D`) |
| 2 | segment | Loaded segment base in `$98/$99` (`$E610`–`$E618`) |
| 3 | procedure | Resolved native entry in `$94/$95` (`$E61B`–`$E623`) |
| 4 | interpreter | Preserved base word at `$D1AD/$D1AE` (`$E626`–`$E630`) |

`tools/native_relocations.py` derives these data boundaries, checks list counts,
and rejects targets outside the procedure body or duplicate target words. This
is a format parser, not a classification of every preceding byte as code.

## Shared library segment 23

`src/pcode/tile_rendering.s` reconstructs all 606 bytes at logical block 116 on both
disks. Procedure 1 is a p-code return with its metadata. Procedures 2–4 contain
267 native instructions occupying 482 bytes. All remaining 122 bytes are data:
60 lookup/mask bytes, two alignment bytes, native relocation/attribute records,
p-code metadata, and the final procedure dictionary/trailer.

- Procedure 2 occupies `$000C`–`$006A`, ending at RTS. The four following bytes
  `$03,$0C,$30,$C0` form a two-bit mask table; its consumer is not established.
  Their regular bit-mask representation, placement after the terminating RTS,
  and adjacency to the referenced lookup table support data classification.
  The 56-byte table at `$006F` is directly referenced by LDA absolute,X at
  `$004F`; relocation adds the procedure entry `$000C` to the stored operand
  `$0063`. Its index is four times a state (initially 12, then a table value
  in 0–13) plus a two-bit value, bounding access to those 56 bytes.
- Procedure 3 occupies `$00B6`–`$019C`. Its JMP at `$0193` contains `$0032`;
  adding entry `$00B6` yields the established loop at `$00E8`. The source
  expresses that operand as a label difference and forces absolute encoding.
- Procedure 4 occupies `$01AC`–`$0247` and has four empty relocation lists.
  Absolute reads from `$0DC0`/`$0E80` occur in procedures 3 and 4; those fixed
  external data addresses do not acquire procedure-relative relocation.

The code/data classification does not depend on naming the game-level purposes
of these routines. No procedure bytes are imported as binary blobs.

`tools/check_library23.py` verifies every byte's classification, native instruction
boundaries, direct branches, the relocated jump/table operands, dictionary and
relocation boundaries, state-table index bounds, and alignment. Three parser
tests exercise count/target bounds. Negative checks reject a changed relocation
operand, a branch into an instruction operand, and an oversized list count.
Both full rebuilt disks still match exactly. Existing loader captures include
this segment before relocation; final both-emulator/save-load checks remain open.
