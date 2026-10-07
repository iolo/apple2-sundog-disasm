# Ship combat rules — R10a

`remake/js/core/ship-combat.js` implements an isolated, source-facing combat
session. R10i connects it to an opt-in campaign machinery/save host; live
space controls remain pending. R09 remains complete.
R10b subsequently captured an original-game space contact and enemy dialogue;
see [encounter reference](encounter-reference.md). Native damage arithmetic and
native combat outcomes still require evidence. The prepared R10d ground
observation is documented separately.

## Source evidence

Offsets below are segment-relative in `src/pcode/library_24.s` and
`src/pcode/game_12.s`. Library22 proc30/31 implement signed16 left/arithmetic
right shifts; proc3 supplies the seven-shift RNG and proc40 inclusive ranges.
Pascal boolean expressions evaluate both operands, and branch tests use bit0.

| Procedure | Implemented rules |
| --- | --- |
| Library24 proc12 `$04BA–$0621` | Encounter production during engine-powered movement, including non-arrival ticks ($042D→$04BA). Active encounters, cloaking or flag36 suppress the producer without a draw. Otherwise the low-nibble draw occurs even at a city. Cargo types2–30 qualify; the strict comparison excludes cryogens31. System nibble3 must be <= the drawn low nibble; nibble7 gates/decrements cooldown. Creation initializes type, coordinates, health150–255, range127, incoming/aggression flags and cooldown40. |
| Library24 proc11 `$0274–$02A8` | Enemy coordinate drift and type-dependent velocity limits. |
| Library24 proc13 `$0690–$0A8D` | Range/health contact expiry; coordinate wrapping; movement cooldown; retreat; pending enemy fire; shield absorption; group/row/socket selection; encoded component failure; hull damage and ship destruction. Jump pointers at `$0A9C/$0A9E/$0AA0` all target `$084C`, so attacks are processed even during movement cooldown, paused aiming or a retreat. |
| Game12 proc9 `$04F2` and proc7 `$0296–$0461` | Dexterity-derived accuracy, laser/cannon tolerance and damage, special gun flag18, near misses, complete charge expenditure, hit counter354 and enemy death flags. The source retains flag40 until the next machinery combat update. The host receives the system cooldown increment associated with a kill. |
| Game12 proc21 `$1114–$11AE` | Single/both-slot cargo jettison, with slot2 preceding slot1 for Both. Every selected slot draws RNG, even empty or auxiliary-fuel slots. Qualifying cargo and the other lot determine retreat; the host receives a request to clear current-system cooldown. |

The damage code retains two unusual source details rather than introducing
replacement rules. Signed16 overflow in the enemy strength shift becomes32767
when nonpositive. Penetration repeats group selection in512-point steps after
surviving hull hits; component selection overwrites that residual value with
the selected component byte and ends the loop. Selecting an inoperative group
changes the logical target to hull but retains the old record pointer. That
zero-output record causes defeat while the actual hull byte remains unchanged.
This pointer behavior is source-derived and still needs native-emulator
confirmation; it is not an observed original-game result yet.

## State and host responsibilities

The session owns128 source flags; words205–209 and214–217 for the enemy;
resource/control words222/224–226; defeat word347; hit-cycle word354; six
equipment failure records; hull; scene high nibble; ship-world presence;
range-memory byte193; two pod lots; and the campaign RNG state. Operations
validate and clone inputs before changing them. Invalid calls do not mutate
caller-owned arrays, cargo, equipment or resources.

`produceShipEncounter` also receives the actual city-presence predicate and
current system's piracy/cooldown nibbles. `stepShipCombat` runs one source
machinery tick after movement and power, independently of rendering. A host
must call it only in the original combat context. `fireShipGun` receives actual
dexterity and laser/cannon selection. `jettisonShipCargo` returns removed lots
and the source cooldown-reset signal; the host must retain their loss history.

Remaining R10 work includes campaign integration and versioned persistence;
ground threat generation and combat; enemy dialogue predicates/actions and
negotiation; tactical aiming/input controls; bounty, wreck and recovery rules;
cryogen/cargo loss accounting; localized UI; original-game ground and space
observations; and ordinary-control avoid/fight/lose fixtures. This checkpoint
does not claim any of those gates complete. Colony progression remains R11.

## Validation

Fifteen rule groups in `remake/tests/ship-combat.js` cover encounter gates and
creation, movement/aim jump paths, eager draw ordering, strict comparisons,
retreat, signed damage overflow and repeated penetration, component/shunt hits,
the retained-pointer defeat, laser/cannon shots, misses, charge guards,
jettison ordering and atomic rejection. RNG continuations are compared with
an independent little-endian byte/carry oracle and literal vectors, without
importing the production RNG.

Examples: producer seed2536397490 produces type0, x841, y156 and health179 in
seven draws, ending at1314226212. Pending fire at seed29 during movement
cooldown reduces hull16 to14 in five draws, ending at3550957389. The same shot
with type2/3 overflow makes four hull hits, leaving hull10 after eleven draws.
Seed4 selects engine unit1/socket1, marks component28 as156, sets pending
offset6 and reduces output16 to12 in six draws.

The full browser receipt `r10a-rules-validation.json` reports360 passing rule
groups in Chrome154.0.8037.97, with no failures or page errors. No native-emulator
combat observation or live-combat acceptance is claimed in this checkpoint.

## R10i source audit and campaign host

The initial R10a producer description/tests incorrectly treated production as
arrival-only, reversed the system comparison, and included cargo31. R10i traces
Library24's actual jump table: `$042D` uses `$067E→$04BA` when motion has not
arrived; `$0553` is LEQI and `$051F` is LESI. The corrected primitive preserves
the equality seed2536397490 vector, rejects system threshold13 for roll12, and
excludes lone cryogen cargo. Cryogens still qualify for jettison-induced retreat.
The original R10a receipt precedes these corrections.

[campaign-space.js](../../remake/js/core/campaign-space.js) now owns contact
fields, per-system cooldowns, normal-clock remainder, raw combat-failure cache
markers, cargo-loss receipts and ship destruction in opt-in version25. Actual
movement runs before production, power and contact combat; engines-off ticks do
not invoke production. Actual arrival sets an existing contact's cooldown0,
and a successful warp clears40/47 rather than producing a new arrival contact.
See [space host](space-host.md) for validation and remaining live integration.
