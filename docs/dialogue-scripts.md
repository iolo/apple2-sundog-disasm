# Custom dialogue scripts and message records

The game interprets a compact dialogue format in disk-2 blocks 90–102.
`src/dialogue/scripts.s` expresses the stored control records through named
ca65 macros; `src/dialogue/encoding.inc` defines their exact encoding. This
custom format is separate from both native 6502 instructions and UCSD p-code.
The interpreter itself is already disassembled in `src/pcode/dialogue.s`.

`assets/dialogue-messages/` holds separately extracted counted message data.
Every adopted range has an explicit map back to its bank offset. Unvisited
gaps/tails remain unresolved, including any as-yet unreferenced records. This
checkpoint does not infer classification for the complete 512-byte allocations.
The subsequent [step 07q bank audit](dialogue-bank-layout.md) identifies the
remaining messages and spare storage, completing these thirteen allocations.

## Dispatch and record layout

Game 16 procedure 34 at $113E–$115C selects bank `(state div 16)-1` and loads
it to $4800 using the base block established in procedure 37. After the disk
wrapper's +3 bias, the first bank is absolute block 90. Procedure 23 reads
entry `state mod 16` from the first sixteen bytes ($0D6C–$0D75), then uses
procedure 15 ($0706–$0715) to read consecutive bytes through a shared cursor.

All nonzero entry pointers are decoded as roots, including stored entries
whose runtime reachability has not been demonstrated. Empty pointers remain
table data. In twelve banks, entry zero is eighteen: the same byte also controls
the supplemental dictionary path and was adopted as metadata in step 07p.
Block 98 instead starts at sixteen and has no supplemental dictionary header.
The remaining 196 entry-table bytes are source-built here.

Each record starts with two bytes. The first packs a mode in its high nibble,
reply count in bits 2–3, and delay code in bits 0–1. Procedure 23 extracts them
at $0D7C–$0D8D; the delay is twice the stored code. Procedure 26 consumes the
second byte as packed control flags for interpreter state/actions. `d_begin`
retains these fields explicitly.

The decoder follows procedure 23's exact structure:

1. If mode bit one is set and reply count is zero, decode a state selector.
   If mode is at least eight, consume its action. The call at $0DAC–$0DAE is
   `CSP 4` with arguments `(16,23)`, which exits procedure 23: there is no
   following message or reply list on this path. The standard-procedure vector
   at $D108 targets $E75C, whose code restores the selected procedure's exit
   address and walks frames when necessary.
2. Otherwise decode a message selector. Values at least thirty are direct
   word offsets into the current bank. Smaller values use the selector format
   below. The interpreter saves/restores its cursor around message rendering
   at $0DBD–$0DC6, so message bytes are not inline script operands.
3. Consume two transition values. If mode bit zero is set, each has a predicate
   byte and, when nonzero, a replacement transition (procedure 29).
4. Consume the declared number of reply pairs (caption index, transition).
   If mode bit one is set, each pair also has the same conditional replacement.
5. If mode is at least eight, consume an action through procedure 28.

Transition values are kept as numeric script operands; values below sixteen
have the separate built-in handler in procedure 33. Predicate meanings need
not be named to establish their role and byte extent.

## Selection and action encodings

Procedure 24 ($09A8) handles both state and message selection. The source
macros distinguish those contexts, and message candidates use named bank word
offsets rather than unexplained literal bytes.

| Selector | Following fields | Source form |
| --- | --- | --- |
| 1–10 | That many candidate values | `d_*_random`, `d_value` |
| 11–19, 24–29 | `selector-10` candidates; every candidate except the last has a predicate | `d_*_conditional`, `d_test`, `d_default` |
| 20, 22 | Three values | `d_*_mood20/22`, `d_value` |
| 21 | One condition byte, then three values | `d_*_mood21`, `d_condition`, `d_value` |
| 23 | Four values | `d_*_mood23`, `d_value` |

The four mood selectors differ in how they use the current interpreter mood
and condition state ($09B2–$0A1A). Their original selector is preserved; they
are not collapsed into one supposedly equivalent encoding. Zero or unsupported
state selector values are rejected by the tool rather than guessed.

Procedure 28 reads an action selector and dispatches through its case table at
$0D16. Actions 0 and 4 consume no further bytes; 1, 5, 6 and 7 consume one;
2 consumes two; 3 consumes four. The two extra operands for action 3 follow
the branch at $0CDA–$0CE8. The source spells these as `d_action0` through
`d_action7`; generic names avoid inventing gameplay semantics. Unknown actions
are rejected.

## Message data and validation

Every message candidate passed to procedure 17 is a word offset. At $0944–$094C
the procedure doubles it, seeks the bank cursor, and reads a length byte. It
then consumes exactly that many character/substitution bytes at $0957–$097A.
Bit seven emits the character plus a following space; procedure 18 processes
literal glyphs, dictionary references and substitutions. These are text data
operands, preserved in stored order with all flags, not native executable blobs.

The extracted message records retain their length byte and any zero byte needed
to align the next stored record to a word boundary. All 79 such alignment bytes
are verified zero. The format is supported by the word-addressed references and
repeated record layout; arbitrary gaps outside those records remain unresolved.
Repeated references share one extracted record. The existing supplemental
dictionary ranges are checked for overlap and remain separately owned.

The strict parser detects overlapping entry points, metadata/script/text
overlap, out-of-bank operands, unsupported selectors, and nonzero alignment.
The audited bank entry boundaries independently agree with the next pointer in
each table; only the final record can leave a gap before the next data region.
All 96 script records occupy 979 bytes. Together with 196 table bytes they form
a 1,175-byte source component. The 160 referenced messages occupy 3,434 bytes:
160 lengths, 3,195 text bytes, and 79 alignment bytes.

```sh
python3 tools/test_dialogue_script.py
python3 tools/prepare_dialogue_scripts.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The maintenance preparation command without `--verify` requires new source,
asset and audit paths. It checks the baseline hash and temporary ownership,
assembles every selected script byte exactly before writing tracked artifacts,
and records per-bank entries, operations, text references and boundaries in
`docs/reference/dialogue-scripts.json`. Full-disk comparison validates placement.
No fresh live dialogue trace is claimed; exact output preserves the recorded
behavioral baseline. Final complete classification and both-emulator checks
remain open.
