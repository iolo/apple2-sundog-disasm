# Inferred identifier names

This pass improves identifiers in the UCSD p-code and recovered Pascal. Names
describe evidenced behavior; they are not claimed original symbols. Source
recovery remains complete. This naming pass covers every active procedure;
unknown shared fields and historical variants retain neutral identifiers.

The [catalog](identifier-names.json) records original Pascal symbols, component
and procedure identities, inferred names, and supporting operations. Its local,
shared-word, frame, and branch sections record the corresponding storage and
control-flow names. Unlisted identifiers retain their current names pending
review; uncertain fields are not assigned speculative game meanings.

## Current coverage

The reviewed groups are all active libraries22–28 (both disk variants of26),
game8/12–21, startup7, startup_disk1, utility_disk1, and all system groups:

- 608 procedure identities: all570 p-code bodies and all38 native entry/
  contract identities. Native implementation instructions are unchanged.
- Local/parameter names follow their callers and lexical parents. There are
  29 DATASEG29 word aliases plus one additional phase-specific alias,246 named
  words across fourteen game/utility frames,69 improved existing record-field
  names,27 storage-variable names, and nine named native overlay call shapes.
- Matching semantic p-code entry labels and symbolic procedure-number operands.
  Sixteen branch aliases cover amount operations, a surface checksum failure
  loop, and distinct runtime cleanup/return paths. The amount library also has
  26 named frame slots. Named lexical accesses retain explicit owner procedures.

Examples:

| Original | Current | Evidence |
| --- | --- | --- |
| `proc22_48` | `write_wrapped_text` | Copies a string, buffers words, and handles space/bar/backslash controls. |
| `proc28_2` | `add_amount` | Two-part base1000 addition, carry, and sign adjustment. |
| `proc12_7` | `fire_tactical_weapon` | Weapon charge checks, beam drawing, damage, and charge clearing. |
| `g12.words[31]` | `g12.target_present` | Initialized from encounter flag40 and tested before target drawing/firing. |
| `data29.words[19]` | `data29.text_x` | Text positioning, advancement, and wrap comparisons. |
| `data29.words[227]` | `data29.fuel_amount` | Dashboard FUEL label, resource consumption, and cargo-pod refill. |
| `proc16_34` | `dispatch_dialog_action` | Loads the required script bank and follows action redirects. |
| `g16.words[38]` | `g16.stream_cursor` | Ordered script byte reads and cursor increments. |
| `proc26_16` | `move_title_letters` | Six letter paths, frame changes, sound, and saved-column restoration. |
| `proc13_36` | `start_sublight_trip` | Sets polar deltas, progress, and ETA after resource checks. |
| `proc8_17` | `sleep_and_risk_theft` | Resting/recovery and the original cash/item theft scan. |
| `proc17_14` | `fire_personal_weapon` | Shot drawing, shield charge, life damage, and enemy removal. |
| `proc20_28` | `run_exchange_window` | Loads market state, dispatches buying/selling/warehouse views and persists it. |
| `util1_27` | `attribute_point_cost` | Original integer doubling cost above attribute30. |
| `sys0_33` | `rt_extend_file` | Extends an existing directory extent to the next boundary. |
| utility29 word6 | `stat_adjustment.candidate_points` | Holds proposed points after an attribute change, rejected at <=0. |
| word217 in ground code | `data29.ground_encounter_mode` | Discrete mode15/16/18/22 in game17 and its game21 caller. |
| library28 `L_0115` | `amount_compare_low_parts` | Reached when the left high part is not greater; compares equality and low parts. |

## Naming and storage rules

Pascal names must differ within their first eight significant characters;
the reference UCSD compiler ignores underscores. Long descriptive spellings
remain useful, but different endings alone do not distinguish names. Avoid
collisions with existing locals and record fields as well as other routines.
Variant-record fields can collide without a duplicate-name diagnostic, so
check significant prefixes and compiled field accesses together. Function-result
assignments, `exit` targets, forwards, native declarations, and compile-fixture
stubs must follow each routine rename.

Source directories now describe module roles, and Pascal procedure filenames
match the inferred routine names. The catalog’s `source_paths` section maps
every original path to its current path. Component identities and
procedure-number/offset comments remain stable.
`src/pcode/identifier_names.inc` declares procedure dictionary
numbers and known storage offsets; these constants emit no bytes. Semantic
entry and branch labels sit alongside the original `L_XXXX` aliases, retaining
relocation expressions and existing evidence references. Numeric segment IDs
remain visible, and call comments retain segment/procedure IDs. Deferred variant
and retained-fragment call contexts need their own review before substitution.

Library26's semantic labels live in its shared `title_and_boot_body.inc`, with the
same procedure numbers in both disk variants. Library23 retains its existing
`pN_entry` labels alongside the semantic aliases. These source/label exceptions
are recorded in the catalog rather than assuming every module has `L_XXXX`
entry labels in its top-level `.s` file. System-core procedure1 lives separately
in `runtime_entry.s`; `assembly_procedure_sources` records this per-procedure
source ownership rather than adding its alias to core procedure2's file.

Call names require component context. Startup, utility, and system modules
reuse segment1: local calls resolve within their owning component, while the
system core's external1:1 calls retain the system1 identity. A matching segment
and procedure number alone does not justify a startup-program name. The same
rule applies when naming other reused segments and retained copies.
CIP has one procedure-number operand in this interpreter. The callee dictionary
supplies its lexical level; no explicit lexical-depth operand is invented.

The native-call trampoline22:25 keeps distinct, named Pascal declarations for
each evidenced target signature. Native dictionary18 in library26 remains an
internal register-call helper with a named assembly entry; no Pascal signature
is invented. Startup_disk1:1 remains an anonymous Pascal program block, with a
semantic p-code entry label. Their catalog entries identify original procedure
numbers without implying new Pascal bodies or runtime bindings.

Named Pascal fields are overlapping views of existing storage. They do not
change the760-byte DATASEG29 allocation or the game frames:94-byte tactical,
204-byte component,52-byte ship-interior,278-byte dialogue,42-byte status, and
196-byte ground-combat local storage. Civic, exchange, surface and utility
aliases likewise preserve their original frames. The utility root remains1044
bytes after its implicit four-byte program ABI area; initialization, city-seed,
attribute-editor and adjustment views keep their original lexical parents.
The ground-combat save/restore operations
still use their original212-byte extent, beyond the declared parent locals.
Raw views,
packed operations, and unknown slots remain available. In particular,
`wordpair.first/second` retain neutral names because the same type represents
both coordinates and amounts. Separate field declarations preserve the
reference compiler's record layout.

Shared storage can have different meanings in different phases. Word217 is
`target_range` in space combat and `ground_encounter_mode` in game17 and the
game21 encounter setter. Both views and assembler constants retain offset217.
`context_words` records these bindings; a global numeric-word replacement must
not overwrite the phase-specific name. Travel-span units likewise remain
context dependent, rather than claiming one universal duration or distance unit.

Frame names also require lexical ownership. The status aliases in game13 belong
to procedure3 and children4–11, not the enclosing space-console frame. The
catalog records that owner and procedure set before the p-code lexical operands
are named. Raw arrays remain where words have multiple roles or an alias would
hide existing layout dependencies.

Maintain the catalog, static assembler constants, declarations, and callers
together when extending naming. Preserve curated semantic additions when using
the mechanical listing generator; exploratory regenerated listings belong in
`build/`. Native source, p-code encodings, numeric Pascal labels, and behavior
are outside this naming change. UCSD Pascal's numeric labels remain valid
language-level labels; meaningful p-code branch aliases need not change them.

## Validation

The naming pass compares Pascal executable tokens against the pre-edit
sources, allowing only recorded identifier replacements and exact storage
aliases. The original storage declarations remain beneath the added views.

Ten existing compile fixtures cover game18, game21, game12/game13, both
library26 disk variants, startup7, startup_disk1, utility_disk1, the complete
system host and the separate system3 program entry. Each
compiles with the existing reference compiler and options. Their complete
executable segments and procedure frame dictionaries match the pre-rename
compiled artifacts. External-link symbol names change, so whole compiler-output
files can differ. This is static compiler evidence, not a runtime test.
The complete system host accounts for80 bodies; its separate system3 fixture
accounts for the remaining entry. The game18 fixture's compile-only surface
parent parameters follow its included children's inherited parameter names;
their widths, ordering and generated code remain unchanged.

The reference compiler mistakes an exactly1024-byte Unix source file for an
empty UCSD text file (`lib/input/ucsd_text.cc`, `candidate`). Naming initially
put game14/procedure7 at that size; clarifying its existing comment avoids the
misdetection without changing Pascal tokens.

The existing game18/game21 receipts pin the renamed sources and compiler output;
their procedure metadata and semantic checks remain unchanged. The
[naming receipt](checks/identifier_names_receipt.json) records executable-segment
comparisons for all ten fixtures. The source-path section records thirty renamed
Pascal directories and712 moved source/configuration/recipe files, including559
procedure include files. All ten complete compiler outputs are byte-identical
before and after this path migration. The [p-code source guide](../../src/pcode/README.md)
and [Pascal source guide](../../src/pascal/README.md) provide navigation by role.

```sh
python3 tools/build_disks.py --no-temporary
python3 docs/decompilation/checks/verify_identifier_names.py
python3 docs/decompilation/checks/verify_game_18.py
python3 docs/decompilation/checks/verify_game_21.py
```

The strict disk build assembles all sources, checks every component against the
manifest, and reproduces both original disk hashes. The fixture verifiers need
their documented compiled/component artifacts; see the
[game18 reproduction commands](game_18.md#validation-and-reproduction).

The identifier verifier reads the original608 Pascal/fixture files from the
receipt's pinned Git revision, normalizes only cataloged renames and exact
storage views, and compares executable tokens. It also checks procedure entry
aliases, constants, component-local call ownership and significant name prefixes.

## Semantic limits

All570 targeted p-code bodies have cataloged routine identities. Return-only
runtime procedures9/14/15 retain explicit numbered no-op names because their
more specific original roles are unknown. Raw/reused storage and numeric Pascal
labels remain where stronger names would imply unsupported meaning.

The historical alternate modules, retained utility variant and clipped linker
fragments remain outside the active Pascal recovery scope. Their metadata and
provenance were reviewed separately; `deferred_review` records the evidence and
why active names must not be applied by reused segment/procedure numbers.
In particular, the retained utility's name-entry procedure numbers differ from
the active utility and some callees lie outside its fragment. This pass leaves
those identities numeric rather than asserting an unreviewed semantic binding.
All38 active native entry/contract names describe interfaces only; native
implementation instructions and calling conventions remain unchanged.
