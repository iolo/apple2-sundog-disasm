# Ship bounty, wreck and tractor ownership — R10o

`ship-salvage.js` supplies source Game12 kill continuation; the tactical host
commits it into actual campaign bank, RNG, contact, cargo and machinery owners.
`content.space:true,tactical:true` now uses opt-in version29 `ship-salvage-1`.
The live UI remains version24; space-only consumers remain version26.

## Source rules

| Source | Implemented behavior |
| --- | --- |
| Game12 proc6 `$0197–$0210`; Library22 native proc31 `$0F6C–$0F9A` | Bounty requires system word8/nibble3 + enemy type strictly greater than12. Right-shift `(type+1)*nibble4` by3, with a minimum of1, then add that many thousands to the current system account while preserving its remainder. Existing exported system `local32`/`local30` are those nibbles. |
| Proc6 `$0211–$0286`; Library22 proc40 | Always draw the inclusive0..5 wreck test. A result at/below enemy type draws cargo1..30 and quality4..7. Packed origin is0, paid-price word is0, inhibition36 is set, and drift is2 with engines powered or1 otherwise. Cryogens31 cannot be generated. |
| Proc12 `$0A8D–$0AC4` | Each actual proc12 call adds speed207 to range217. Range at/below2 becomes1; range above128 removes the wreck and clears inhibition. The ordinary main loop calls only on its source bit0/firing gates. No second wreck drift is added to post-due proc10 movement. |
| Proc18 `$0FCA–$1096` | Check wreck presence, then available room; scan slot2 before slot1. Set drift−4 and increment354/call proc12 on every tractor iteration. Once proc12, including due machinery, returns with range1, copy the two-word record into the selected slot and clear wreck/inhibition. No attachment, fuel fee or new capability gate is added. |
| Game20 proc19/16 `$0ACA–$0C70` | Unknown origin0 matches no ordinary world/system. Sale pricing therefore uses its computed quote as the ceiling, rather than incorrectly clamping it to paid price0. Fuel remains unsellable. |
| Library24 proc16; Game15 proc10 | Wreck fuel is cargo1 even at quality4–6. Machinery adds255 before deficit/clamp; pod docking sets255 below fuel5. Collection occurs after a due power call, so newly collected fuel is available on the following call. |

The gun frame retains the native cached-contact guard, charge spending, reticle
reset and cooldown update. Full kill continuation now draws RNG; empty-space or
held-button polling cannot repeat a cached kill/bounty. Bounty account overflow
uses the existing atomic `bankOverflow` boundary instead of admitting negative
bank balances from Pascal signed overflow.

## Native vector and correction

The existing declared R10n centered fixture is retained as native evidence:
[setup](../reference/remake-tactical-input-shot-setup.json),
[message](../reference/remake-tactical-input-kill-message.json),
[shot](../reference/remake-tactical-input-shot.json).

Its RNG bytes before the shot are `[80,133,96,24]`. The three source draws are
9282,15444,11282: gate0, cargo25, quality6. The resulting bytes are
`[89,60,18,170]`, matching the captured post-shot state. Parent local34 is217
(`25 | 6<<5`), local35 is0 and local27 is1.

The earlier R10n prose/metadata incorrectly described this bounty as1000Cr.
The screenshot reads **3000Cr**, and the proc6 frame independently retains
piracy13, coefficient14 and computed thousands3: `floor(2*14/8)=3`. Those claims
are corrected without changing the raw captures. This proves that prepared
kill's bounty/wreck/RNG vector, not native tractor collection or ordinary
fresh-character combat acceptance.

## Save and cargo contract

Version29 adds `space.bounties:[{systemId,enemyType,count}]` and
`space.wrecks:[{lot,count}]`. Bounty amounts are derived from source system data,
never trusted as a saved amount. The wealth ceiling admits actual bounty income;
stored/destroyed purchase costs still count and loss receipts grant no income.
Zero-bounty kills retain their count; total produced wrecks cannot exceed total
killed contacts. Increasing a wreck receipt to duplicate a single kill rejects.

The tactical record adds `wreck:null | {lot,present,tractorSlot}`. Unknown-origin
lots are exactly `{commodityId,quality,originCity:null,pricePaid:0}`, with type1–30
and quality4–7. Their bounded production receipts must cover every owned wreck,
pod/warehouse/archive lot and loss, preventing copying a single generated lot
into two owners. Sold/consumed/escaped lots need no remaining physical owner.
Warehouse transfers, regional archives, quotes, depot validation and both fuel
consumers preserve this record.

Active tractor state retains its selected slot across partial50ms frames,
pause and reload. Player menu/aim/flight/power/sleep/Comm actions are blocked
during the source loop. If actual machinery changes drift and the wreck escapes,
`present:false` retains the blocking proc18 state and raw lot; it does not grant
cargo or invent cancellation. This edge is rule-tested, not claimed as a native
observed recovery. Normal forced sleep/death remains owned by existing dispatch.

Versions1–28 validate their historical fields and cargo rules first. Migration
adds empty receipts and a null wreck, without retrospective bounty/cargo or
RNG/time changes. Version28 button state remains exact; version27 retains its
existing no-manufactured-press migration.

## Verification boundary

Six new source-rule groups and six campaign groups exercise the native vector,
thresholds, failed/successful RNG gates, inhibit/drift boundaries, slot order,
full-pod rejection, actual bounty accounts, due-before-copy fuel ordering,
unknown-origin sale, ownership/losses, strict28 migration and30/60/144Hz
continuation through partial JSON reload/pause. The exchange integration uses a
declared service-position fixture and actual reducers; it is not ordinary-play
space acceptance. See [browser receipt](r10o-rules-validation.json).

The full browser suite passes500 rule groups. The unchanged live24
[ordinary regional journey](r10o-journey-validation.json) passes64 checks with
no page errors: purchases17,100, foreign sales39,200 and return570 minutes/fuel108.
Static checks pass22 exporter tests,171 deterministic artifacts,584 classified
source-string records, three original-input hashes and48 retained native-artifact
hashes. These regressions preserve R09; they do not activate space acceptance.

Live sensors/contact/aim/fire/Comm/bolt/tractor controls and localized help,
ordinary campaign avoid/fight/lose/equipment acceptance, native full tractor and
death/recovery dispatch, rare reward224, and live cadence/sleep/reload acceptance
remain under the unchanged [full R10 requirement audit](r10-completion.md).
