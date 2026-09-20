# Complete procedures in a retained utility-program variant

Disk 1 blocks 151–155 retain a variant of the utility program. Earlier
[source-copy classification](early-module-copies.md) identified extended exact
matches but left changed bytes unresolved. Fifteen complete procedures between
block-151-relative offsets `$0042` and `$089C` now have independent control-flow
decoding, including their changed operands, procedure numbers and bodies.

`src/pcode/utility_variant_procedures.s` assembles this entire 2,138-byte fragment:
785 instructions occupy 1,413 bytes; the other 725 bytes are explicit strings,
branch tables, alignment and procedure metadata. Of these, 1,356 bytes retain
their previously verified utility-source mappings. The new component supplies
only the remaining **782 disk bytes: 575 code and 207 data**. Complete procedures
are retained in source so even isolated newly mapped operand bytes have their
full instruction context.

## Procedure evidence

Offsets in this table are relative to the beginning of disk-1 block 151; ends
are exclusive. Each stored attribute pair is preceded by local/parameter sizes
and self-relative entry/exit pointers. The next procedure follows immediately
after that pair. Extended matches to the independently decoded utility program
establish provenance; the stored footer and exhaustive graph establish the
variant's own boundaries, including where it differs from that program.

| Procedure | Entry | Attributes | Local bytes | Parameter bytes |
| --- | --- | --- | ---: | ---: |
| 32 | `$0042` | `$013A` | 6 | 0 |
| 33 | `$013C` | `$0186` | 0 | 2 |
| 34 | `$0188` | `$01A8` | 0 | 0 |
| 35 | `$01AA` | `$0216` | 0 | 2 |
| 36 | `$0218` | `$0408` | 30 | 0 |
| 37 | `$040A` | `$04DE` | 12 | 2 |
| 38 | `$04E0` | `$0500` | 0 | 0 |
| 30 | `$0502` | `$0514` | 340 | 2 |
| 39 | `$0516` | `$0618` | 10 | 0 |
| 2 | `$061A` | `$0642` | 0 | 0 |
| 6 | `$0644` | `$0742` | 4 | 0 |
| 40 | `$0744` | `$07B8` | 6 | 0 |
| 41 | `$07BA` | `$07D4` | 0 | 0 |
| 5 | `$07D6` | `$07FA` | 0 | 2 |
| 42 | `$07FC` | `$089A` | 0 | 2 |

Every instruction is reached from a stored entry or exit and follows the
shipped interpreter's checked encodings. All jump and case targets land on
instruction boundaries within their owning procedure. Inline strings are
claimed by their consuming instructions; branch words are claimed by their
branches. Only the existing decoder's strictly bounded zero alignment rule is
used. No gap becomes a generic data declaration, and no extra code root is
needed for these procedures.

The fragment contains calls to procedure numbers 3, 4 and 31 outside this
captured range. These remain explicit absent-fragment references. A dictionary
or segment trailer is not present in this range and is not fabricated. This is
not a claim that the complete retained program or its original loader has been
recovered. The retained bytes of the clipped procedures before `$0042` and
after `$089C` were subsequently classified by the [short-copy and edge
review](short-pcode-copies.md). The variant's historical date and live reachability are not
established.

## Source context and adoption

The fragment decoder accepts only reviewed attribute offsets, reparses their
stored metadata, and requires ordinary code/data ownership of every input byte.
Whole-module decoding retains its dictionary, trailer and call-count checks.
Fragment decoding instead reports calls to absent procedures explicitly.

The adoption recipe separates new disk mappings from verified source context.
Context mappings name their existing source component and exact source offset;
adoption compares every byte and preserves those original mappings. Together,
context and new mappings must account for every assembled byte. Context cannot
be temporary data, an asset, an encoded-source shortcut, or unmapped filler.
Preparation also compares code/data classification for all 1,356 context bytes
against a freshly decoded primary utility module; no previous classification
is silently contradicted.

```sh
python3 tools/test_pcode_source.py
python3 tools/test_adopt_component.py
python3 tools/utility_variant_source.py --verify
python3 tools/pcode_copies.py --verify --recipe src/pcode/evidence/early_module_copies.json --audit docs/reference/early-module-copies.json
```

The report `docs/reference/utility-variant-procedures.json` includes all items,
control-flow edges, calls, procedure metadata and newly classified byte totals.
Preparation assembles the complete source and compares it to the precise disk
range. Artifact verification also checks every new and retained disk mapping.
Tests cover fragment boundaries, absent calls, malformed/duplicate metadata,
unsupported opcodes, preservation of prior mappings and rejection of changed,
overlapping or unaccounted-for source context. Exact full-disk rebuilds retain
the existing behavior baseline; no new emulator execution is claimed here.
