# Local pod cargo journey — R07g

The landed campaign connects the two-slot pod to the local exchange's four-slot
warehouse. Reach the pod exit aboard the ship, choose Drive pod, drive to the
cargo entrance, and choose Load cargo. Store selects pod cargo and fills the
first warehouse vacancy; Fetch does the reverse. Swap selects two occupied slots.
Every action requires confirmation; Cancel and saving a selection move nothing.
The two columns show the actual pod and warehouse manifests in English/Korean.

Return horizontally to the ship and Dock pod. The ship inventory displays the
same cargo manifest. A loaded pod can depart again, unload at the exchange and
sell its cargo into the local bank account. Foot visits cannot load a remote pod.
R08e adds the native auxiliary-fuel docking exception: when ship fuel is below5,
the first auxiliary lot is consumed and fuel becomes255. Ordinary goods and
cryogens remain intact; full tanks retain auxiliary loads. See [ship power](ship-power.md).
The current pod journey is confined to Drahew. Leaving the pod on foot, other
cities and surface travel remain the broader R08/R09 transport work. R08b adds
reachable depot entry and purchases.

## Source movement and browser presentation

| Source | Implemented boundary |
| --- | --- |
| Game15 proc7 `$027A–$02D5` | Detach, select city/pod mode, set horizontal glyph16 and exit direction8. |
| Game21 proc25 `$0D06–$0D40` | Direction8 places the pod at ship anchor plus `(9,0)`, initially `(296,211)`. |
| Game21 proc7 `$0225–$0254` | Detached ship uses glyphs36/37 without the attached glyph16 XOR overlay. |
| Game21 proc22/23 `$0BC6–$0C7E` | Directional visible glyphs14/16/18/20 and collision masks15/17/19/21. |
| Game21 proc12 `$0433–$0550` | Try diagonal, X, Y with the mask for each actual direction; repeated directions use two pixels and retry at one pixel when blocked. |
| Game21 `$03C9–$03F3`; Library22 proc31 `$0F6C` and proc34 `$0584` | Pointer-center offsets, arithmetic right shift by3, then sign; preserve negative rounding. |
| Game21 proc15 `$06E9–$0732`, proc21 `$0B74–$0B9E` | Docking requires glyph16, ship tile proximity and a ±6 X / ±4 Y box around the right half of the ship. |
| Game21 proc19/20; Game20 proc28 | Pod exchange entry is service type4, distinct from foot type5. |
| Game14 proc6; Game20 proc11–13 | Ship cargo inspection and exchange loading use the same two pod records. See [cargo rules](cargo-loading.md). |

The exporter creates separate SVGs for all four pod orientations and the detached
ship, and exports the original low-seven-bit masks. Movement retains the existing
50ms browser cadence, cleared held input on transitions and paused arrival. The
city boundary remains the supported stored rectangle rather than adding surface
travel through an unimplemented scene.

Game15 `$05F7–$060A` / `$0651–$065C` returns at `(98,119)`. That point overlaps one
solid pixel under the browser's full seven-pixel interior collision mask. The
browser returns at the adjacent clear, connected `(99,119)` within the same pod
interaction area. This one-pixel placement adjustment is explicit; collision
and save validation remain unchanged for other interior positions.

## Version16 ownership

`landed-local-cargo-1` adds a top-level active block:

```js
pod: {
  attached: true,
  position: null,
  heading: 16,
  cargo: [null, null]
}
```

Detached pod position must equal the city's active player position; only city or
exchange scenes support it. Position must be reachable from departure with the
directional pod masks, and its saved heading must fit. An exchange snapshot must
also match the pod entrance. Attached pods have null exterior position and the
canonical horizontal heading. This checkpoint does not represent an unattended
parked pod, so it cannot combine detached cargo with a foot interior visit.

Transfers preserve every lot's commodity, quality, origin and paid price. The
wealth ceiling includes purchase costs in both warehouse and pod, plus the
existing sale-income allowance. Initial local cryogens form a conserved multiset
across both containers; they can move but cannot be sold, destroyed, duplicated
or have their origin changed. Other cities remain immutable creation data.
Ordinary lots still require local origin and supported paid prices. This remains
progress consistency validation, not authenticated save history.

Versions1–15 pass their historical checks before receiving an attached empty pod.
Their warehouse cryogens remain fixed until migration. Old envelopes cannot
inject pod fields. Selection drafts, pointer targets and acceleration direction
are transient; loading a save clears them and resumes paused. Cargo actions do
not change money, market stock, prices, RNG or time.

## Verification

`city-pod.js` tests source mask selection, arithmetic pointer rounding, departure,
blocked/outside positions, docking, collision-checked outbound/return routes,
paid cargo transport/sale, round-trip saves, legacy migration and protected
cryogens. Existing cargo tests exhaust all64 container occupancy patterns.
Exporter tests compare masks directly against the original font bytes.

`tools/remake/pod_cargo_smoke.js` creates a fresh character and reaches the pod,
exchange and ship using normal controls. Geometry is read only to plan routes;
the test does not inject campaign positions or cargo. It buys three lots, checks
cancellation, fills the pod, blocks a third Fetch, swaps lots, saves/reloads,
docks loaded, departs again, stores and sells. English/Korean viewport checks
inspect the loading controls. Receipts are `pod-cargo-*-validation.json`.
This is source-derived browser verification; no native emulator capture is claimed.

R07h adds [bartender trader matching](trader-matching.md). The final milestone
audit is maintained in [R07 completion](r07-completion.md).
