# Counter setup and dialogue predicates — R06i

`remake/js/core/dialogue-state.js` implements fresh counter setup for dialogue
kinds13/14 and the Game16 predicate evaluator. It returns owned interpreter
state and continuing RNG; it does not change live campaign money, attributes,
flags or saves. Script controls/actions, room queue/return behavior and localized
conversation presentation remain pending.

## Setup

Game16 procedures37/38/39 supply the setup path. Procedure38 ($1222–$1244) is a
deterministic flag-fill loop, not a random generator. Counter kinds13/14 select
states80/81 without drawing randomness. The setup includes:

- Cleared continuation slots, offer amounts and formatted strings; cash copied
  into local104, mood from workspace byte9 and gate from byte12.
- Locals4/5 initialized to `26+(surfaceX+surfaceY)%9` and30. Their valuation
  role follows procedures2/7; they are not assumed to be portrait indices.
- Thresholds `11+DIV(16-local32,6)`, `15+DIV(16-local32,2)` and
  `23+2*DIV(local31-1,3)`, using division truncated toward zero.
- Flags88/89 set true and flag117 cleared on every setup. On a city change,
  flag80 becomes `hour<3 or hour>6`, flags90–111 are filled from the thresholds,
  and the remembered city changes. Same-city visits preserve those flags.
- Carried-item scores: exact item12 contributes1 to local7; masked type13
  contributes2 to local7; masked type11 contributes2 to local6. A damaged type12
  is not counted by the exact-byte comparison.

The new `dialogue-systems.json` exports the twelve system defaults. Locals30–32
come from the shipped system nibbles. Utility12 ($0282–$0291) clears local16's
system flag and local29's high nibble during character creation, so those two
initial values are false/zero, irrespective of saved working data. The exported
fields match all twelve systems in the independent clean-character capture.
Future live setup must supply the current system fields and current attributes,
not reset them from these creation defaults.

Numeric local identities avoid speculative meanings for fields whose consumers
are still being ported. Locals17/36 are not assigned by the supported setup path;
the browser represents them as null. Predicate7 requires an initialized step of
−1 or1 when its successful branch needs local36, rather than inventing a value.

## Predicates and effects

The evaluator follows Game16 procedure8 ($025E–$0493), probability helper9
($0216–$0227) and attribute helper10 ($0234–$0251). Code0 returns true with no
draw; negative codes return false. Encoded families are:

| Codes | Meaning |
| --- | --- |
| 1–19 | Direct source case-table tests |
| 20–59 | Attribute checks with encoded offsets and a luck retry on failure |
| 60–69 | Mood-adjusted probability, with a luck retry on failure |
| 70–79 | System and encoded probability checks, both evaluated eagerly |
| 80–89 | Encoded probability alone |
| 90–99 | Dialogue kind equals code−90+12 |
| 100–199 | Probability threshold code−100 |
| 200–255 | Selected item equals code−200 |

For codes20–89, the last digit supplies ten times its value, with digit0 meaning
100. Probability compares `random mod100 < threshold`, always consuming one
draw even for thresholds0 or100. Attribute checks use the pre-check byte; a luck
check then halves luck on either success or failure.

Procedure8's internal retry through case0 is distinct from its public code0
shortcut: the retry tests luck+40 and halves luck. Predicate1 first checks
charisma+40. Only if that succeeds does it clear local17 and test mood*15; failure
of this second check triggers the luck retry. A failed first check returns false
without a retry. Predicate3 skips its charisma check when canonical money values
104/102 agree. Predicate11 caches successful charisma−20 in flag80 and consumes
no further draws while that flag remains true. Predicates12–14 return false.

Predicate7 can move local5 toward the negotiated valuation and refresh pricing.
The port includes procedures2/3's mode0 refresh, using existing source item
names/value bytes. It clamps local5 to at least0 and local4 to at least1, computes
`DIV(local5*local30,local4)`, then clamps that scale to1..42 for items15–22,
1..64 for other items whose flag80+item is false, or1..128 otherwise. Value bytes
are tripled, doubled or unchanged respectively. The item byte is masked to31.
It updates local106 and strings108/124 (`<price> Cr` and the item name), retaining
local100. No additional random draws occur in this refresh.

Predicate8 subtracts local100 from local106 when106 is greater, returning false;
otherwise it returns true without subtraction. This is an internal negotiation
amount, not a campaign debit. Its comparison/subtraction follows library28
procedures6/3. Numeric amounts are restricted to canonical nonnegative
thousands/remainder pairs representable by the native signed high word.

Missing item data, unset valuation direction and unsupported signed-word
overflow paths fail explicitly. Each evaluation clones its input and owns its
RNG, so failures publish no partial state. Future record execution must apply
each returned state before the next predicate; the existing selector and
transition helpers can invoke this evaluator in their source order. Counter
entry predicate100 still draws once even though both stored branches redirect
to the same state82/83.

## Validation and next work

Chrome154.0.8037.57 using `/opt/google/chrome/google-chrome` passes139 rule groups,
including14 new groups. Tests cover setup without RNG, hour/threshold edges,
same-city persistence, exact inventory scoring, strict probabilities, repeated
luck checks, retry order, eager draws, cached flags, internal subtraction, pricing
caps/multipliers, source item masks, explicit failures and caller ownership.
All256 byte predicates run against prepared working state for three seeds
(768 cases), with continuing RNG checked against draw counts. Both counter
roots exercise the real selector/evaluator integration.

Seventeen exporter tests and all139 generated artifacts pass. System dialogue
defaults match the clean-character emulator capture. Original disk/PDF hashes
and `git diff --check` pass. Predicate behavior is source-derived and tested with
controlled cases; no new original-emulator conversation capture is claimed.

Next implement packed controls, script actions and built-in transitions, then
the conversation runner, player queue/return persistence and English/Korean UI.
Fresh non-counter setup paths and campaign transactions remain outside this
checkpoint; campaign saves remain version7.
