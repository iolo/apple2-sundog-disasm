# Dialogue dictionary and supplemental text

`assets/dialogue-dictionary/` extracts **1,930 data bytes**: the 808-byte base
dictionary and 1,122 bytes from twelve supplemental banks. `fields.json`
preserves readable stored characters, including case and control characters,
with each high-bit position listed separately. It repacks exactly to
`dictionary.bin`; it is not a transcript of every possible generated dialogue.

The remaining script regions are outside this data extraction. No custom
dialogue instructions are hidden in the extracted text. The separate 128-byte
prefix in disk-1 block 196 has no exact match in the current reconstructed
components and remains unresolved; its appearance alone does not establish
whether it is p-code, other code, or data.

## Base dictionary loader and pointers

Startup 7 sets segment-29 word 26 to 85. Game 16 procedure 37 saves that value
in parent local 8 at `$13EC`–`$13EF`, and stores local 9=local8+2. At
`$1642`–`$1657` it establishes buffers at $4800 and $4A00; local 141 holds
the dictionary address $4A00. `$165A`–`$1666` reads two blocks there using
local 8. Library 22 procedure 53's +3 bias selects disk-2 blocks **88–89**.

The first **65 bytes** hold low bytes of offsets for 64 variable-length
entries. Game 16 procedure 31 at `$0E6E` scans these bytes and records the
indices where the values decrease. Procedure 12 at `$0584` reads the chosen
low byte and adds 256 for every crossed decrease index. Procedure 13 obtains
the start and following end through calls at `$0612` and `$061B`.

The first pointer is 65. The decreases occur at indices **5, 20 and 51**;
the final reconstructed pointer is **808**. Equal adjacent pointers represent
empty entries. Entries 0–31 include dialogue choices and synonym groups; other
entries include pronoun/phrase fragments and a repeated dummy group. The
base asset includes all 65 pointer bytes and all 743 addressed text bytes.

Bytes 808–1023 remain unresolved: they are outside the initial dictionary
extent, and the last byte is nonzero ($A0). They are not claimed as harmless
padding merely because most of the tail is zero.

## Text consumers

Procedure 13 and its nested procedure 14 read the dictionary as text:

- `$05C2`–`$05E6` counts alternative-ending markers in the range 65–96.
- `$0634`–`$0652` skips alternatives, again using that marker range.
- `$065B`–`$066D` reads a byte and strips bit seven when set. The marked
  character is emitted followed by a space (`$0693`–`$069A`).
- Uppercase A–Z ends an alternative and is converted to lowercase at
  `$0682`–`$0691` or `$06B4`–`$06C3`.
- Stored `|` and `\` become `I`; `~` becomes an apostrophe. The backtick
  path at `$06C7`–`$06D7` reuses/removes the preceding output character and
  terminates the text group. Original bytes and flags are preserved, including
  entries containing other control/glyph values whose presentation is not
  given a speculative transcription.

For example, stored `yeSnO` contains the alternatives “yes” and “no”. A high
bit on the final character of a word encodes its following space. Case and
high bits therefore carry structure and are not normalized away in the asset.

## Supplemental dictionary records

Procedure 34 reads one dialogue bank at $4800 using local9+bankIndex at
`$1150`–`$115C`, giving absolute blocks 90 onward, and calls procedure 32.
At `$0EE0`–`$0EE5`, procedure 32 skips supplemental processing when byte zero
equals sixteen. The twelve extracted banks have marker eighteen. It reads
the supplemental count from byte 16 and the start in words from byte 17,
then doubles the start at `$0EF1`–`$0EF4`.

At `$0F00`–`$0F16` it reads a byte length and copies exactly that many text
bytes into the dictionary buffer. `$0F18`–`$0F26` updates the next low-byte
pointer. `$0F27`–`$0F34` advances over the length and text, then aligns to an
even address. `FJP` tests bit zero, as confirmed by the shipped interpreter
at $D2A4; this is an odd-address check, not a nonzero-address test.

| Disk-2 block | Text records | Stored record span, end exclusive |
| --- | ---: | --- |
| 90 | 1 | 168–178 |
| 91 | 7 | 224–302 |
| 92 | 5 | 102–180 |
| 93 | 3 | 170–252 |
| 94 | 5 | 204–294 |
| 95 | 9 | 158–360 |
| 96 | 3 | 80–168 |
| 97 | 3 | 154–196 |
| 99 | 5 | 82–172 |
| 100 | 9 | 114–308 |
| 101 | 5 | 50–122 |
| 102 | 2 | 444–504 |

For each bank, the asset also contains metadata byte 0 and bytes 16–17,
mapped back to their separate disk locations. Its 57 supplemental records
contain 1,002 text bytes, 57 length bytes and 27 explicit zero alignment bytes;
the metadata adds 36 bytes. All alignment bytes are checked, and a nonzero
alignment byte is rejected. Block 98 has marker sixteen and is excluded.
Other script/pointer regions, text not covered by these consumers, and tails
remain unresolved. The supplementary metadata is data even though adjacent
regions may contain custom script code.

## Validation

```sh
python3 tools/test_dialogue_dictionary_asset.py
python3 tools/dialogue_dictionary_asset.py --verify assets/dialogue-dictionary
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Extraction with `--extract` requires a new output directory and verifies the
rebuilt disk hash, exclusive temporary ownership, pointer bounds, record counts,
alignment, and exact reversible text encoding. Tests cover page crossings,
empty entries, all 256 stored character values, word alignment, malformed
lengths/flags, and exclusion of extra tails. The current rebuilt disks remain
exact; no new live dialogue capture or final emulator-validation completion is
claimed at this checkpoint.
