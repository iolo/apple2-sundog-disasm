# Complete dialogue-bank layouts

The format traced in [dialogue scripts](dialogue-scripts.md) and
[dictionary text](dialogue-dictionary.md) now accounts for every byte of
disk-2 blocks **90–102**. This checkpoint extracts the final **925 data bytes**:
865 bytes of bounded spare script storage and five additional counted messages
occupying 60 bytes. It does not classify remaining regions on other blocks.

## Structural evidence

Each bank has sixteen entry pointers, optional two-byte supplemental dictionary
metadata, a contiguous sequence of decoded control records, spare script space,
and word-aligned text records through the end of its 512-byte allocation.

The last control-record boundary follows the interpreter's exact field reads.
For supplemented banks, byte 17 explicitly locates the dictionary text area;
after the declared number of supplemental records comes the message area.
Block 98 has no supplement; its first referenced message begins at byte 126.
The bank scanner walks every counted message from that start, including messages
without a reference from the stored control records. Every referenced message
must occur at exactly one of these independently reconstructed boundaries.
All thirteen text walks finish **exactly at byte 512**, with no guessed trailing
blob or instruction conversion.

| Block | Bounded spare script range, end exclusive | Additional message ranges |
| --- | --- | --- |
| 90 | 164–168 | 178–184, 370–380 |
| 91 | 182–224 | — |
| 92 | 82–102 | 280–300 |
| 93 | 164–170 | — |
| 94 | 130–204 | 294–300 |
| 95 | 66–158 | 360–378 |
| 96 | 42–80 | — |
| 97 | 120–154 | — |
| 98 | 57–126 | — |
| 99 | 64–82 | — |
| 100 | 75–114 | — |
| 101 | 42–50 | — |
| 102 | 23–444 | — |

The spare ranges are classified as unused storage **inside this structured
script-bank allocation**. The evidence combines decoded record ends, explicit
text-area boundaries, complete message walks, and the same zero fill in all
thirteen gaps. Zero fill or lack of observed execution alone is not used as a
general classification rule. Nonzero bytes in any such gap cause the tool to
reject the bank rather than conceal potential code or another format.

The five extra messages have the same length prefix, word alignment and
character/substitution encoding as the 160 referenced messages. They fill
otherwise missing records in the sequential text area. Examples include stored
forms of “Would … like to buy a …?” and “Welcome … a room?”; these are not
claimed as exact rendered sentences, because the low-valued bytes and high
bits invoke dictionary substitutions and spacing. Their complete stored text
and flags are preserved in `assets/dialogue-bank-storage/fields.json`.

## Validation and scope

```sh
python3 tools/test_dialogue_bank_remainder.py
python3 tools/dialogue_bank_remainder.py --verify assets/dialogue-bank-storage
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Extraction verifies the rebuilt image hash, temporary ownership, all byte
extents, and reversible fields. The scanner rejects nonzero spare storage,
incomplete or zero-length unexpected messages, malformed alignment, and text
references into record interiors. Tests exercise those failures and an unused
but structurally complete message. The manifest records every message boundary
and every spare range; the full reconstruction manifest now has no temporary
bytes in these thirteen blocks.

The base dictionary's tail in block 89 remains unresolved, including its final
nonzero byte. Other disk regions and the final both-emulator validation remain
open. No additional live dialogue observation is claimed for this checkpoint.
