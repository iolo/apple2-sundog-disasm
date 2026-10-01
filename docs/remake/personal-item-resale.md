# Personal-item resale source audit — R07e

Ordinary item/equipment shops do not offer a Sell branch in the traced scripts.
Personal-item resale is a trader conversation transaction. It remains R07 work;
adding a generic shop Sell button would invent a new transaction route.

Game16 proc37 clears selling local18 at `$144C–$144D`. Proc39 enters states80/81
for counter kinds13/14. Those redirect to82/83, whose controls reset the item and
whose action3 sets buying mode. State84 quotes, Buy leads to85/action1, and its
continuation9 returns to the same root. Neither the shop bank nor its information
branches switches to selling mode.

The exported action2 records that select a carried item are:

| Route | Source script path | Required continuation |
| --- | --- | --- |
| Bartender matching | State26 Sell →27/action2; supported item →29; cancel/timeout →builtin3 | Sets flag65, copies selling mode to flag66 and the selected item into workspace. This requests a trader; it is not a completed sale. Matching/pursuit and the subsequent encounter must be implemented together. |
| Seated visitor trade | Social continuation →129 →130; Sell →131/action2; supported item →132 →35 | State35 offers acceptance/bartering. Accept →37/action1 with continuation38. This direct visitor route is distinct from bartender matching and need not wait for the complete street-encounter milestone. |

Game16 proc41 `$1938–$1958` permits dropping a carried item into the seller's
acceptance area only when local18 is true and its low-five-bit type matches
local41. Proc43 `$17CA–$17E3` recognizes the cross-boundary transfer; proc42
`$1748–$1756` then adds price106 to cash104. The complete byte must leave exactly
one carried slot. This is a separate transfer after accepting a quote, mirroring
the purchase confirmation boundary already implemented in R07d.

The current room controller deliberately blocks visitor Sell/Accept and bartender
matching, while the campaign return rejects cash increases. Those guards must be
replaced only when a verified sale commits the correct source slot, proceeds,
continuation, speaker return and replay state atomically. Price overflow and
charged-item matching need coverage. Old versions must not gain new input paths.

The version14 wealth bound allows cash decreases from purchases but no income
from personal-item sales. Initial stores, carried items and installed components
already exist, and inventory/component transfers are active. A new save design
must account for legitimate sale proceeds without simply removing the wealth
check or mixing the immutable creation record with active balances. A record of
sale proceeds must have a defined validation/migration contract, including sales
inside an unfinished conversation and prevention of double payment on replay.

Next personal-trade step: use the existing seated visitor route for a bounded
purchase/resale transaction and its save accounting. Keep bartender matching
separate until its actor lifecycle is ready. Current shop/food purchases remain
fully enabled; this audit does not disable or change them.
