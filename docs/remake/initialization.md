# Generated new-game fields — R04d

This step implements three initialization primitives and the source random-number
routine. They are tested JavaScript modules for future campaign assembly; the
current character editor, walkthrough and checkpoint format do not yet use them.
The generators take explicit inputs, allocate independent objects and never read
an existing character save. They do not constitute a complete New Game action.

## Random stream

`remake/js/core/random.js` ports library22 procedure 3, `$0C00–$0C27`. Treat its
four state bytes as a little-endian unsigned 32-bit value. Each result performs
seven shifts; the inserted bit is the XOR of the old bits 6 and 30. The returned
15-bit integer has state byte 2 as its low byte and half of state byte 0 as its
high byte. This unusual byte order is covered by native comparison tests.

`tools/remake/random_reference.py` extracts the actual reconstructed shift loop,
relocates its state references to a four-byte buffer and wraps its result in the
cc65 A/X calling convention. `cl65 -t sim6502` and `sim65` execute it for seven
explicit seeds and 16 draws each. All 112 returned values and resulting states
match JavaScript. This is a 6502 algorithm check, not an Apple II play session or
proof of the original game's startup seed. State 0 (and an initial high bit alone)
remains degenerate; the port preserves that fact instead of silently changing it.

Pascal FJP (`src/native/pcode_primitives.s`, `$D2A0–$D2A6`) tests bit 0, not whether
the whole integer is nonzero. LAND/LOR are eager bit operations in the equipment
initializer. JavaScript explicitly consumes the corresponding draws and tests
parity, including otherwise redundant draws for socket 0 and the spare row.

## Equipment

Utility 19 `$078A–$084B`, called six times from utility 21 `$0A03–$0A31`, creates
six 28-byte records at segment 29 word 90. Game 14 procedure 3 `$01AD–$0234` supplies
the group names. Each record holds four units, a spare-component row, total
performance and a special-component requirement. The named projection is:

| Group | Standard four-component row | Special component / socket |
| --- | --- | --- |
| Warp drives | 31,28,26,30 | 0 / 0 |
| Sub-c engines | 31,28,30,24 | 0 / 0 |
| Ship's guns | 31,24,26,29 | 19 / 2 |
| Tactical display | 31,27,25,26 | 20 / 2 |
| Force shields | 31,24,28,28 | 21 / 1 |
| Pilotage | 31,25,27,25 | 22 / 2 |

Each of the first four rows has a `random % 3 === 0` damage branch. It chooses one
of four sockets. Socket 0 always takes the missing/broken branch; other sockets
use a random low-bit decision. Missing/broken values are 0 or 7, making the unit's
performance 0. The alternative installs shunt 23 and sets performance 3. An intact
unit has performance 4. The fifth row stays intact as spares, while still consuming
its damage draw. Record byte 24 is the sum of the four unit performances, 0–16.
Byte 25 is cleared by initialization but is not yet given a gameplay meaning here.
Library 24 procedure 8 consumes the component requirements and recalculates unit
performance; implementing later repair behavior requires that whole consumer.

`initialization_reference.py` independently projects the six records at globals
save offset 108 from the existing clean-character capture. It constructs a compatible
random draw tape and verifies all components, unit/total performances, spares and
requirements. That tape demonstrates the captured outcome is reachable; it is
**not** a recovered original seed or recorded random stream. Runtime initialization
does not import this fixture or any captured save.

## Systems and planets

Utility startup loads world defaults from disk 1 blocks 23–25. The exported
`data/initial-navigation.json` projects 12 system names, three-dimensional baseline
coordinates, membership of 18 planets, their names and orbital radii. Names,
membership and radii match the independent clean-character capture. Balances,
flags, existing orbital angles and all working gameplay records are excluded.

| Rule | Source | Implementation |
| --- | --- | --- |
| System x/y/z | Utility 12 `$0252–$026C`, `$02CB–$031D`; helper 10 `$01AA–$01BB` | Pin system 10 Woremed to (6,5,6). Other systems jitter each coordinate by −1,0,+1, clamped to x 1–12, y 1–9, z 0–10. |
| Spacing | Utility 11 `$01E2–$022F` | Reject if both x and y differ by less than 2 from an earlier system or Woremed. Rejected coordinates become the next jitter baseline. z is not in this spacing check. |
| Three-dimensional distance | Library 24 procedure 6 `$00AE–$00E1`; game 13 procedure 14 `$06E7–$0717` | All three coordinate fields affect travel distance; the third also affects map presentation. |
| Starting balances | Utility 12 `$0292–$02C5`; library28 procedure 2 `$0005–$002B` | Starting system gets 29–31 thousands plus 0–999; others 3–5 thousands plus 0–999. Browser amounts are exact integer credits. The original two-word money format is base 1000. |
| System membership | Game 13 procedure 15 `$0864–$0887` | System record word 5 bits 2–6 select first planet; bits 0–1 give planet count. |
| Planet position | Utility 13 `$0356–$0381`; game 13 procedure 15 `$08A6–$08B6`, library24 procedure 4 | Generate an 8-bit angle until its absolute difference from the prior angle is greater than 15. Radius remains the default's byte 13. Difference is linear, not wrapped. |

The first orbital comparison reads outer procedure 9 local 9. No write initializes
that local on the traced call path before procedure 13. `createInitialOrbits`
therefore requires an explicit previous angle. Tests use 0; this is an explicit
fixture boundary, not an observed original startup value.

The browser primitives use a supplied random stream and fixed exported baselines.
Original utility 17 writes modified world defaults back to disk, affecting later
creations. A campaign must choose and document its seed/baseline lifecycle. These
helpers neither mutate the supplied baseline nor persist a global sequence.
Rejection loops fail after 10000 attempts instead of hanging; they never silently
relax spacing or substitute an arbitrary result. No complete utility 9 call-order
or RNG synchronization is claimed by combining these independently tested pieces.

## Remaining assembly gate

Still required: interpret commodity-template fields and generated city records
(utility 14/16), map the remaining global/location flags and caches, choose the
browser seed lifecycle, and assemble a fully named state with character attributes,
worlds, ship and colony progress. Navigation/repair interactions and campaign
schema validation follow that state definition. Four existing ship checkpoints
continue to use version 1; no migration or new campaign UI is introduced here.

Reproduce the references and tests:

```sh
python3 tools/remake/random_reference.py
python3 tools/remake/initialization_reference.py
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
```

Open the served remake's `/tests/` in the required Chrome for the full browser
suite. Use `--write` on either reference helper only when intentionally updating
its checked-in test fixture. See [validation receipt](initialization-validation.md).
