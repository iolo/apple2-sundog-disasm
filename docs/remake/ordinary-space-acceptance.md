# Ordinary space negotiation and defeat acceptance — R10z

The [journey runner](../../tools/remake/ordinary_space_negotiation_loss_smoke.js)
creates a default `R10 pilot` with seed12345 through the character UI. It pays
for depot fuel, buys two exchange lots, loads the pod, docks, launches and flies
toward system point0. Read-only geometry plans movement and read-only prices
choose affordable cargo; all mutations use normal controls. There are no
campaign imports, injected contacts, RNG changes or fabricated damage. The
browser clock supplies elapsed time to the existing live host.

The cargo is commodity24/quality4 at8900Cr and commodity25/quality6 at8200Cr.
Powered flight naturally produces a type1 contact with health224 and range123
at minute160. Navigation opens Tactical, and slot1 saves the legitimate
campaign at minute161, hull15 and fuel226. The two branches explicitly load
that earlier saved point.

## Ordinary loss and terminal recovery

The unshielded branch continues flight without player shots. Contacts can
retreat and be replaced through the existing producer while valuable cargo
remains aboard; the fatal endpoint is type2, not the first type1 contact.
The receipt includes ordinary HUD samples during this continuation. Actual
enemy attacks eventually reduce hull to0 at minute325 and open **Ship
destroyed**, with the durable source defeat marker347 and campaign defeat
record. Personal health remains255, and purchased cargo, personal cash and
regional bank accounts retain their separate owners.

A fresh page restores the complete terminal campaign from slot2 exactly.
Five seconds of elapsed time after reload leaves every owner frozen. Loading
slot1 explicitly restores the complete earlier living encounter. Opening Comm
and continuing into the second branch proves the restored campaign is playable;
there is no automatic restoration or new character substitution.

## Cargo demand, jettison and escape

Normal Comm opens the actual kind19 conversation. A fresh page reproduces its
pending state, and elapsed time does not advance flight, machinery or combat
while it waits. Agree and the normal response return arm the source six-tick
cargo deadline. They leave cargo aboard and do not transfer personal or bank
money. The deadline and conversation replay survive exact fresh-page reloads.

The player requests full shields, arms the bolts and chooses **Both slots**.
Jettison removes commodity25 before24 and records each actual lot once, including
quality, purchase cost and origin. It retains the pending deadline at6 and
sets the source retreat direction/cooldown. After ordinary elapsed time, range
is131 and contact40 is false, with no destruction or hull damage. Both cargo
slots remain empty and the loss ledger contains exactly two entries after
reload. Shields charge0→128 toward target255; fuel226→221 accounts for live
movement and power costs. Escape still retains one deadline tick; no permanent
truce or invented deadline cancellation is claimed.

## Validation and remaining scope

All44 Chrome checks pass with no page errors. Reload checks compare complete
campaign JSON; the [receipt](r10z-ordinary-space-negotiation-loss-validation.json)
retains SHA-256 hashes plus literal resources, equipment, RNG, contact,
communication, location, cargo, loss and defeat owners. Every checkpoint preserves
the immutable creation state. Destruction and escape screenshots were inspected.
Original disk/manual hashes verify. No gameplay core or save schema changed;
the R10y510-rule baseline remains the latest rule run.

This closes ordinary space loss, terminal freeze/recovery, cargo-demand agreement,
manual jettison and cargo-induced avoidance, and proves ordinary shield charging.
It does not prove space victory, weapon aiming/fire acceptance, shield absorption
under ordinary enemy fire, Tractor collection through ordinary campaign play,
fatal native Warp return, or terminal ground death. Earlier controlled evidence
retains its declared scope. The [full R10 audit](r10-completion.md) remains open.

## R10ab ordinary laser victory, shield overflow and Tractor

The [maintained fight/salvage runner](../../tools/remake/ordinary_space_fight_salvage_smoke.js)
starts another fresh seed12345 character and repeats the legitimate paid fuel,
8900Cr commodity24 and8200Cr commodity25 purchases and ordinary launch. It
finishes actual sublight travel at minute216 before requesting full shields.
An open-space type2 pirate has health218 and range97. No campaign imports,
contact/RNG writes or fabricated damage are used.

An actual pending enemy hit consumes shields255→0 at minute223 before overflow
damages a force-shield component31→159. Hull remains15, performance16→12 and
the pending failure owner records the source result. A fresh page restores every
owner exactly. This proves buffer consumption and overflow damage, not complete
absorption of that high-strength attack.

Normal Laser selection, legal pointer aim and fresh press/release firing defeat
the pirate after38 observed aim samples. At minute233 the enemy has health0,
hull remains15 and fuel is75. The source produces a commodity23/quality6 wreck,
with unknown origin and zero purchase cost. Only the current-system bank gains
3000Cr (9862→12862); personal cash153 and both purchased lots are unchanged.
The bounty and wreck each have one receipt, preserved through fresh reload.

Normal bolt arming and slot2 jettison remove the actual commodity25 purchase
once. Tractor then selects that deliberately empty slot and pulls the real wreck
from range61 to1. Partial-pull reload and completed reload preserve the complete
campaign. At minute237, fuel55 and shields255, slot2 contains the salvaged
commodity23/quality6 while slot1 retains the original paid commodity24 lot.
The loss ledger retains the discarded purchase, and neither bank credit nor
collection repeats during reload or paused elapsed time. Creation data is
unchanged at every checkpoint.

All36 [Chrome checks](r10ab-ordinary-space-fight-salvage-validation.json) pass
with no page errors; victory and collected screenshots were inspected. The
[R10ab inventory](r10ab-validation-summary.json) retains literal owners and
receipt hashes. No gameplay core or save schema changed in this checkpoint,
so the R10y510-rule baseline remains historical current-core evidence.

This completes the remaining ordinary space fight, aim/fire, shield-damage and
Tractor acceptance. Browser matching for the captured fatal Warp return and
the final complete requirement/regression audit remain open. Terminal ground
death is unclaimed; earlier prepared references retain their declared scope.
