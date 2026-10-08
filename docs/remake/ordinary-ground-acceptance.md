# Ordinary ground fight and loss acceptance — R10w

Two Chrome journeys create a new default character, `Ground pilot`, with seed
12345 through the normal character UI. Neither imports a campaign nor writes
game state through JavaScript. Read-only source geometry finds routes, and
read-only exported saves reconstruct actors for aiming. All movement, equipment
transfers, dialogue, firing, saves and loads use ordinary controls. Browser
clock control supplies elapsed time without replacing game reducers or RNG.

## Victory and personal shield

The [fight runner](../../tools/remake/ordinary_ground_fight_smoke.js) walks to
stores, transfers the original laser12 and charged shield235 into carried
slots0/1, then leaves the airlock and walks toward the city exchange. A naturally
produced chase catches the character at city position455,319. Source threat65
opens before combat; cancelling its dialogue returns to the same activation.

Held Space and pointer aiming defeat three enemies and open post-fight entry51.
The source return awards exactly2016Cr, taking personal cash153→2169. The laser
remains in carried slot0 and stores slot11 remains empty. Five enemy shots
consume five of seven shield charges: packed item235→75. Personal health stays255.
The immutable creation data and regional bank owners remain independent of the
personal reward. Fresh-page saves reconstruct the caught, won and rewarded
states exactly; reloading the final reward grants no duplicate income.

## Knockout, robbery and explicit recovery

The [loss runner](../../tools/remake/ordinary_ground_loss_smoke.js) leaves the
fresh character unarmed, saves the initial campaign in slot0 and walks to a
natural city chase. The original threat conversation returns to combat. No
player shots or fabricated damage are used. Enemy fire knocks the character
out: health255→87, vigor255→174, and personal cash153→0. The source robbery
returns a living character with no active ground encounter or death marker.
Untouched stores, locker and regional bank accounts remain unchanged.

A fresh page loads slot1 and reproduces the entire injured/robbed campaign.
Paused elapsed time leaves all owners frozen. Explicitly loading slot0 restores
the exact earlier fresh campaign; walking to stores proves resumed play. This
is recovery by the player's earlier save, not automatic restoration.

## Validation and limits

All31 ordinary Chrome checks pass (17 victory,14 knockout/recovery), with no
page errors. The receipts retain literal owner/RNG/replay values and SHA-256 hashes
of complete exported campaign and immutable creation JSON. The runners compare
full campaign objects at each reload; hashes keep the receipt small without
copying the entire world dataset into every checkpoint.

- [Ordinary fight receipt](r10w-ordinary-ground-fight-validation.json).
- [Ordinary loss receipt](r10w-ordinary-ground-loss-validation.json).
- [Checkpoint inventory](r10w-validation-summary.json).

This closes the ordinary ground victory/knockout, personal laser/shield and
explicit earlier-slot recovery contexts. It does not prove peaceful ground
negotiation, terminal ground death, any ordinary space encounter, cargo-demand
negotiation/jettison, fatal Warp return or the rare reward224. The original
[R10 requirement audit](r10-completion.md) remains in progress. Earlier
controlled terminal fixtures remain separately scoped evidence.
