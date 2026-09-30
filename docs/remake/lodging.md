# Live lodging — R06n

Type11 city doors now enter Game18's lodging layout1. The player can walk to the
clerk, ask for a room, pay, enter the assigned bedroom, save there, reopen its
door from inside and return to the original city doorway. English uses expanded
source text; Korean covers all seven messages in bank95. The room number is
shown in the walking status line.

## Source and adaptation

| Source | Live behavior |
| --- | --- |
| Game18 procedure16 `$0BA8–$0BC5` and procedures15/19 | Type11 selects record1, with entry `(12,61)`, four bedrooms and four independently rendered/collidable doors. See [fixture evidence](room-fixtures.md). |
| Game18 procedure23 | Counter actor0 dispatches lodging kind23 using the same waiting/service queue as shops. The clerk retains mood and greeting state on return. |
| Game16 procedure39 `$138F–$13B0`, procedure3 `$0080–$00D6` | Enter dialogue96. Quote `8*system.local30+3` credits in local106/string108; local100 is the lesser of that amount and available cash. Setup itself consumes no RNG. |
| Bank95, states96–101 | Availability uses predicate11; accepting opens quote99. Predicate8 selects paid acceptance100 or insufficient-funds101. State100 deducts the offered amount and returns through builtin3/flag65. |
| Game18 procedure21 `$0F92–$0FB9` | Successful return draws an inclusive room number1–4, opens its door and clears flag65. Cash, source flags, clerk state, assigned room and RNG commit together. |
| Game18 procedure25 `$1438–$148C` | In approach band y28–40, open the rented room if `1+((x-18) div28)` matches its number. Outside that band, close its door and set flag57 according to the bedroom band y8–27. |

The browser applies procedure25's release-area behavior after each movement
step, giving pointer, keyboard and touch the same door behavior. The player is
fully past the two door rows before closure. Closed-bedroom saves validate
reachability with the rented doorway available for access, while actual movement
and visible-overlap checks still use the door's current collision pixels.

All sixteen open-door masks have external SVG variants (the closed mask uses
the base room SVG). Tests compare their rendered alpha pixels against runtime
collision for every pixel. No canvas-only door approximation is used.

The quote's displayed price comes from source string108, including in Korean.
Predicate8 can change local106 to the missing amount while resolving an
insufficient-funds reply; that must not change the already-rendered quote.

Lodging payment is included in R06 because it unlocks the remaining walkable
bedrooms. Shop purchases, inventory transfers, banking transactions and hostile
encounters retain their later milestone ownership. Existing sleep controls remain
available; this checkpoint records the source bedroom flag but does not claim
the later encounter consequences of that flag.

## Save version9

Scope `landed-lodging-1` extends the existing six-part campaign state:

- `dialogue.cash` holds active carried credits, initialized from immutable
  `start.credits`. Lodging can decrease it; other live conversations cannot
  commit a cash or inventory change. The bank panel displays active cash.
- A lodging visit adds `travel.lodging: {rented, openMask}`. `rented` is0–4 and
  `openMask` is a four-bit door mask. Zero rented requires zero open mask.
  This field is required only in a type11 room and forbidden elsewhere.
- A lodging visit requires population/service state. Leaving clears the visit's
  rental and bedroom flag; the next entry starts with closed doors and retains
  the spent cash.

Version1–8 saves retain their original field/scene validation. Version8 has no
cash field and cannot introduce lodging; only after it passes validation does
migration initialize active cash from creation. Its ongoing conversations replay
unchanged. No slot is rewritten merely by loading.

Mid-payment saves still store the pre-conversation campaign cash and the bounded
replay input log. Replay reconstructs the pending debit. The return then publishes
the debit and room assignment once, preventing a reload from charging twice.
Current cash must be a nonnegative integer no greater than creation cash: lodging
is the only enabled cash mutation. R07 will extend that bound with earning rules.

## Evidence

`lodging-ui-validation.json` records27 live Chrome checks, including ordinary
building entry, counter service, the67-credit English/Korean quote, Pay,
mid-payment IndexedDB/page reload, bedroom entry, a closed-bedroom save/reload,
reopening from inside, exact street return and a fresh visit without a refund.
A bank-visit import also verifies the post-rental active cash display.
The Korean bedroom screenshot was visually reviewed at1280×720; dialogue fits
640×480,390×844 and844×390.

Rule coverage includes all system fees, insufficient cash, decline, deterministic
room assignment, all door artwork/collision masks, stepwise door traversal,
room/cash import rejection, version8 conversation migration and atomic return.
These are source-derived browser checks, not a new original-emulator capture.
The existing dialogue, room and bank suites pass19,102 and28 UI checks respectively.
R06 remains active for taverns, special city review and final cross-scene audit.
