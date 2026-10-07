# Ground threat and chase — R10e

`remake/js/core/ground-chase.js` ports the Game21 producer and chase as an
owned session, and connects a caught session to Game17 initialization. This
checkpoint prepares the campaign transition; it does not enable encounters in
the live UI or change the version23 campaign-save boundary.

## Source rules and ownership

| Source | Browser behavior |
| --- | --- |
| Game21 procedure1 `$1EFD–$1F1A` | On one **already-due** ground machinery tick, draw `RNG MOD64` eagerly. Trigger only for scene3/city, foot mode, roll21 and non-special city. Surface/scene4, occupied pod and Banville still consume the draw. The producer must not be called only when a pointer moves. |
| Procedure30 `$14E4–$14EC`, procedures17/27 | Resolve the actual ground world's system through regional membership, then use its word8/nibble3 threshold, already exported as Game16 `local32`. Banville/city60 sets the special-city gate. No hard-coded starting-system threshold or substitute chance is used. |
| Procedure40 `$1B9C–$1BDA` | Read the actor's city tile using camera origin plus truncation of `(screenX+3)/28` and `(screenY-3)/32`; wrap at40×24 and mask `MOD16`. Tile0/1 retains an explicit error corresponding to native `SYSTEMERROR21,40`. |
| `$1BDA–$1CCC` | Copy origin is `clamp(trunc(x/7)-10,0,20)`, `clamp(y-48,0,96)`. Prepare an80×60 window at `clamp(x-40,10,199)`, `clamp(y-30,10,131)`. Fill the outer rectangle with native pattern11 and clear its inset with pattern8. Player starts at left+37/top+33. One draw chooses the chaser's four entry sides; another chooses fast (`MOD3=0`) versus alternating slow movement. |
| `$1CCE–$1D60` | Move the player one pixel toward the **raw** pointer. Decrement the signed16 counter; only its low Boolean bit, OR fast, enables chase movement. Use Library22 diagonal/X/Y collision with visible glyph22/23 and full collision glyph24. A blocked chaser retries the same delta after hiding the native pointer; a second block catches the player. |
| `$1D60–$1DF0` | Escape at `x<=left+3`, `x>left+71`, `y<=top+9`, or `y>top+57`. Catch wins if catch and escape occur together. Both restore workspace mode9. Catch computes direction from signed truncated coordinate differences divided by3. Draw `MOD16` eagerly; kind16 requires roll **strictly greater** than the system threshold and tile<12. Otherwise another draw chooses kind22 (`MOD3=0`) or kind18. Escape consumes neither outcome draw. |
| Game17 procedure10 + Library22 procedure51 | A caught session prepares the combat window from the **original** ground screen pose. Column/row are `trunc((x+3)/7)`, `trunc((y-3)/8)`. Extended combat bounds start at `7*clamp(column-10,1,19)`, `clamp(row*8-48,7,88)` and span139×95. Use the caught kind/direction/RNG to initialize Game17 actors. |

`produceCampaignGroundChase` derives this context from actual campaign ground,
travel, pod, regional membership and composed city-map records. It returns an
updated campaign RNG plus a separate session. The real travel position, camera,
ship, pod, inventory, condition, money and economic records retain their original
owners. Battle/chase screen coordinates never replace a city's whole-map pose.
During a future live activation, the host must transfer each session's RNG back
to the campaign before other source actions run; two streams must not advance
independently. The producer currently accepts a tick already deemed due: it does
not own or silently change Game21's machinery/time counters.

The session validator checks exact fields, points/window/copy bounds, signed
counter, RNG, mode, terminal kind/direction and the serialized sub-tick remainder.
This is activation-record validation, not a replay proof of an imported campaign
encounter. Campaign-save integration must add the latter without weakening any
historical version1–23 validator.

## Native comparison and deterministic checks

The retained [R10d reference](ground-encounter-reference.md) now compares the
entire prepared path, using its declared city context and seed10804:

1. Gate roll6677 (`MOD64=21`) leaves RNG1382964.
2. Entry/pace rolls6797/8077 leave RNG1183652414. Window is `(100,66)–(180,126)`,
   player `(137,99)`, slow chaser `(137,76)`.
3. With no held primary input,36 iterations reach the source blocked-step catch
   at chaser `(137,93)`, counter32731 and direction3. Roll15501 selects kind16
   at threshold12/tile8, leaving RNG1183653752.
4. Game17 bounds are `(70,40)–(209,135)`. All six five-word actor records, the
   carried laser swap and final RNG1537047451 match the existing native receipt
   in29 initialization draws. No actor injection or forced kind is needed
   between the gate and initialization.

The13 focused rule groups in `remake/tests/ground-chase.js` use an independent
byte/carry RNG oracle. They also cover all four entry sides and both paces,
window/copy corner clamps and fills, raw-pointer movement, signed counter wrap,
threshold equality, tile12 visitor selection, both visitor kinds, all four
strict escape edges, simultaneous catch/escape, held-movement escape, actual
home/foreign system context, eager suppressed production, bank-bit masking,
atomic rejection and JSON resume with pause and30/60/144 Hz partitions.

Validation:13 focused Node groups and all394 Chrome154.0.8037.97 rule groups
pass with no failures/page errors; the full browser receipt is
[r10e-rules-validation.json](r10e-rules-validation.json).22 exporter tests,
171 deterministic artifacts,584 source-string records and original disk/manual
hashes verify.

## Browser adaptations and remaining integration

The chase uses an explicit50 ms logical cadence with an owned0–49 ms remainder,
matching the combat core's browser policy. Up to60 seconds of elapsed time per
call resolves every logical iteration; there is no display-frame truncation.
Pause freezes the remainder. A terminal catch/escape clears it so leftover time
cannot advance combat before its mandatory initial Game16 conversation. This
is resumable browser timing, not native cycle equivalence.

The cursor is presentation only and never a collision obstacle. Therefore the
native hide-pointer retry uses the same geometry in the browser. Overlay fills
use the native patterns and absolute byte-column phase; pixels outside the
owned window are excluded from the comparison. Combat preparation retains the
existing blank-interior arena adaptation; the native comparison proves actor
records and RNG, not pixel equivalence outside the combat interior.

Live work remains: source due-tick clock ownership, ground/chase/session UI,
mandatory enemy dialogue/context and outcome dispatch, campaign mutations and
versioned saves, localized tactical controls, defeat/recovery and ordinary-play
avoid/fight/lose acceptance. Ship encounters, cargo loss and live timing checks
remain in the [full R10 audit](r10-completion.md). This checkpoint does not remove
any of those requirements or defer them to R11.
