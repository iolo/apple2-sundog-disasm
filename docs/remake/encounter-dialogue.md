# Encounter dialogue — R10f

`setupEncounterDialogue` ports Game16 procedures37/39 for kinds15,16,18,19
and22. `encounter-dialogue.js` owns replay and publishes an outcome only after
the source interpreter returns. It accepts actual host context; it does not
produce encounters or change a live version23 campaign.

## Setup and money

Game16 procedure39's case pointers `$13BC–$13D2` establish these entries:

| Kind | Entry | Setup |
| --- | --- | --- |
| 15 | 51 | Post-fight quote, one RNG draw, then optional free gift at52. |
| 16 | 65 | Mugger; no setup draw or money quote. |
| 18 | 49 or224 | Payment visitor or rare reward; eagerly evaluates predicate101. |
| 19 | 64 or50 | Space cargo demand when scene-middle is1; otherwise ground fuel service. Working money is the current system bank balance. |
| 22 | 33 | Visitor; referral flag66 becomes local18, flag66 clears, mood becomes4. |

Common flag fills, carried weapon/shield scores, city/hour rules, valuation
locals and referral state use the same preparation as counters. Encounter
city0 is valid for space; historical counter setup still requires city1–63.

Kind15's `$1309–$133E` quote is signed16 multiplication of system local30 by
`60-root`, then by the squared workspace quantity. The RNG value is masked
with3071. Library22 procedure36 `$05C2–$05F3` sums odd numbers and compares
against `r*r-r`: it rounds the square root to the nearest integer. It does
not truncate. Literal seed12345/system local30=8/quantity1 yields112 Cr;
the truncated-root alternative would yield120. Source signed wrap is retained;
negative quotes reject because the browser's canonical money representation
supports positive amounts. Normal Game17 enemy quantities1–5 remain positive.

Kind18 always draws its1% check, including colony progress0/1 and an already
set reward flag125. The ordinary branch draws again for inclusive5–45 Cr.
Entry49's Yes reply reaches113 and **debits personal cash**; it is not a cash
reward. Kind19's ground service quotes479 times system local30 and debits only
the supplied system bank account at53. Personal cash is preserved. The source
return flags remain available to the encounter host.

The post-fight entry51 credits its quote in the owned frame. Its Search reply
can reach52, whose action1 presents an item for zero credits. An explicit
empty-slot transfer preserves the complete charged item byte and returns
through builtin6. Occupied slots reject without losing the gift or reward.

## Replay and source return

An open record stores exactly `{seed,inputs}`. Setup context, including initial
personal state, location, system, hour, colony and bank, belongs to the host
and must remain frozen while the dialogue is open. It must be validated as
part of the future campaign session schema, rather than accepted as imported
interpreter state. The record alone does not prove campaign authenticity.

Restoration repeats setup and every validated input, deriving messages, item
selection, pending balances, attributes, flags and RNG. It rejects extra
fields, bad input shapes, seed/RNG mismatches, excessive history and records
that have already returned. Completed records become null; the source outcome
has personal cash, a bank balance only for kind19, carried items, attributes,
workspace, flags and continuing RNG. No room-return handler clears flags48–51.

Ground surrender48 and negotiated flee49 feed the existing Game17 resume
primitive. The tested flee keeps the existing actors/history and draws no RNG.
Initial mandatory conversation must still be wired between live catch/init
and the first active combat tick. This checkpoint does not expose that host.

Game12 procedure22 `$1272–$1356` prepares Comm only for an active contact not
already communicated with. It resets48–50, sets35/44, and supplies mood0 and
quantity=`enemyType+1`. Startup's scene9 dispatch calls Game16 with **kind19**.
Game12 procedure9 `$0754–$07BE` clears35/44 and prioritizes:

1. Flag49: clear49, set word215=128 and word207=2 for retreat.
2. Flag51: clear51 and start a six-due-tick cargo deadline.
3. Otherwise: enable hostile flag44.

It then clears41 and sets47, preventing a repeated Comm. Procedure10
`$0B8A–$0BAC` tests the deadline before decrementing; after six decrements,
aggression resumes on the following due tick. Agree is not a permanent truce,
bank payment or automatic jettison. These source helpers still need the live
ship power clock and versioned save ownership.

## Unresolved reward target

Kind18's rare branch `$1368–$137B` quotes10000, sets125 and requests224.
Game16 procedure34 maps that state to disk2 block103, beyond the audited
dialogue banks90–102. [The bank audit](r10f-reward-bank-audit.json) reads the
hash-verified rebuilt **utility disk**:102 has a supported dialogue header;
103/104 do not. This does not establish the original game's behavior when
executing the rare branch. No native observation or replacement reward text
is claimed.

The runner currently rejects224 atomically, leaving campaign cash, flags and
RNG untouched. Native observation, interpretation of this source exception
and final playable handling remain explicit R10 work. They are not deferred
to R11 because colony progress participates in the condition.

## Validation

Fifteen new encounter groups and three ship-Comm groups cover exact setup,
rounded quote arithmetic, eager reward draws, signed wrap, bank/personal
ownership, gift transfers, surrender/fight/flee, JSON replay and rejection.
All412 browser rule groups pass in Chrome154.0.8037.97 with no page errors;
see [rule receipt](r10f-rules-validation.json).

[105 UI checks](r10f-dialogue-validation.json) use the real panel and source
runner in an explicitly isolated fixture. English/Korean entries for all five
kinds, including both police contexts, fit640×480,390×844,844×390 and1920×1080.
Buttons exercise source returns, locale changes, JSON replay and the gift
transfer. This is not ordinary-control live campaign acceptance.31 Korean
templates cover all enemy messages in banks93/96; English uses source text.
Korean mugger portrait and gift desktop screenshots were visually inspected.

22 exporter tests,171 deterministic artifacts,584 classified string records
and original disk/manual hashes verify. The campaign save format remains23,
with historical validation unchanged. The remaining live integration and all
other milestone gates remain in [the full R10 audit](r10-completion.md).
