# Cargo loading foundation — R07e

The core now implements warehouse **Store**, **Fetch**, and **Swap** using the
source's four warehouse slots and two pod slots. It preserves each lot's complete
commodity, quality, origin and paid price, including cryogens. This is a core
checkpoint: live loading controls and transported campaign saves are not enabled.
Current campaigns remain version14 `landed-purchases-1`.

## Source and behavior

| Source | Verified behavior |
| --- | --- |
| Game20 proc11, `$0676–$06CD` | Scan slots in order for commodity type0. Pod mode scans two records at segment29 word234; warehouse mode scans four records at outer local52. Return −1 when full. |
| Game20 proc12, `$07B8–$080E` | Selection retries on an empty record. Swap therefore requires two occupied selections; an empty destination is not a selected swap lot. |
| Game20 proc13, `$090D–$0923` | Presents Store, Fetch, Swap. |
| Game20 proc13, `$094E–$099D` | Store selects a pod lot, finds the first empty warehouse slot, copies both words, then clears the pod lot. Swap instead selects a warehouse lot and exchanges both complete records. |
| Game20 proc13, `$09CF–$0A02` | Fetch selects a warehouse lot, finds the first empty pod slot, copies both words, then clears the warehouse lot. |
| Game20 proc13, `$09A1–$09CB` / `$0A06–$0A26` | Full destinations show a capacity message without moving the lot. |
| Game20 proc13, `$0A38–$0A57` | Refreshes the pod slot's display name from the resulting commodity. Segment29 word238 stores strings, not another cargo hold or inventory of items. |
| Game14 proc6, `$0438–$04C9` | The ship inventory's Cargo display reads these same two records at word234 and their name strings at word238. No separate ship cargo container is introduced. |
| Game20 proc28, `$18FE–$1902`, and proc1 type dispatch | Exchange entry records whether the visit is by pod; foot trade does not imply access to the remotely parked pod. |

Each cargo record is four bytes: type in low five bits, quality in the next three,
origin city in the high byte, followed by price paid in hundreds of credits. These
fields already exist as named values in exchange lots; transfers do not reprice,
reroll quality, change origin, charge fees or consume randomness. The core does
not emulate the native UI's waits and drawing. Browser indices are zero-based.

## Core contract and current campaign boundary

`remake/js/core/cargo.js` owns a loading-session snapshot:

```js
{
  warehouse: {cityId: 'city-01', slots: [null, null, null, null]},
  pod: [null, null]
}
```

`reduceWarehouseCargo(previous, visit, action)` accepts a matching
`{cityId, transport:'pod'}` visit and one of:

- `{type:'store', slot}`: chosen pod lot to first empty warehouse slot.
- `{type:'fetch', slot}`: chosen warehouse lot to first empty pod slot.
- `{type:'swap', podSlot, warehouseSlot}`: exchange two occupied lots.

The future transport controller must derive the visit from actual pod entry.
This argument is an explicit core precondition, not a replacement for validating
pod location, vehicle state and the door in the live campaign reducer. Foot,
wrong-city and malformed visits reject. Invalid slots, empty source selections,
full destinations, malformed records and unsupported actions leave input state
untouched. Successful results own all nested records and arrays.

Supported lots are ordinary commodities2–30, quality1–7, origins1–57, and prices
in100-credit units through3276700; cryogens31 require quality7 and price0.
Auxiliary fuel1, unknown salvage and colony60 records need their own producer
rules before this boundary accepts them. Cryogens can move in this isolated core;
that does not enable sale, delivery or movement of protected campaign cryogens.

Live exchange validation now uses the same lot validator while retaining its
stricter local-origin, paid-price and protected-cryogen rules and error contract.
The campaign codec still rejects pod cargo/transport extensions. Nothing writes
the isolated loading session into a campaign. In particular, do not save only
the emptied warehouse after fetching: active pod ownership and the money bound
must be introduced together. The future wealth bound must include paid prices in
both warehouse and pod, and initial cryogen conservation must span both locations.
Current item/food, bank, warehouse and dialogue saves retain version14 semantics.

## Validation and next integration

`cargo-rules-validation.json` records235 passing browser rule groups. Cargo tests
cover all64 occupancy patterns,284 successful transfers plus invalid/full/empty
operations, first-empty selection, full-capacity swaps, origin/quality/price and
cryogen conservation, independent snapshots, malformed input, foot/remote access
rejection, and a paid exchange-lot round trip followed by unchanged sale pricing.
Campaign tests reject premature pod/save extensions. `cargo-exchange-regression.json`
records64 passing live exchange and migration UI checks.

No live cargo journey or new native emulator capture is claimed. Next integration
needs pod departure/arrival and exchange entry, active pod ownership with a save
migration, cryogen/wealth conservation, then Store/Fetch/Swap review controls.
These transport prerequisites overlap R08 and must be pulled forward for R07's
complete cargo loop; they are not a reason to allow remote warehouse loading.
