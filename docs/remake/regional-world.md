# Regional world and economy — R09a

`regional-world.js` cross-checks the exported navigation, economy, exchange,
surface and map records: 12 systems, 18 worlds, 57 ordinary cities and Banville.
Reserved city58/59 records remain inspector content. Every ordinary city has one
world/system owner, one surface marker and a composed map. The starting seeded
system graph reaches all 12 systems through supported jumps.

Library24 proc6 `$00A8–$00E9` sums squared differences of all three packed system
coordinates and calls Library22 proc36 (integer square root). Game13 proc32
`$1695–$16A8` requires `3*distance*distance+10` charge, rejecting values above255.
Generated positions, rather than shipped unjittered coordinates, supply distance.

The regional companion keeps the moving ship separate from immutable creation.
Its city archive owns 56 dormant ordinary markets/warehouses; `economy.exchange`
owns the remaining active city. Selecting an exchange atomically swaps ownership,
without refreshing a market, drawing RNG or copying cargo. Entry performs the
existing source refresh/offer operation exactly once. Banville's colony economy
retains R11 ownership and is not made an ordinary exchange.

Game20 proc16 `$06B8–$07BC` already supplies origin-sensitive resale: same-world,
same-system and cross-system ceilings differ. Regional settlement supplies the
actual origin to this rule, credits the visited system account, and records gross
cargo sale proceeds for the later regional save wealth bound. All 17 generated
cryogens must exist exactly once across active/archive warehouses and pod cargo.
Auxiliary lots retain world origins; ordinary lots retain city origins.

Bank, depot, dialogue and pod callers now accept a regional companion and derive
their current location from it. Legacy callers retain their old boundaries.
Depot hull/fuel service still requires the ship in the visited city; auxiliary
purchase still requires the pod at the entrance. A different city map cannot
authorize a bank/exchange/depot operation.

This is a core checkpoint. The live application and codec remain version22 until
regional persistence, geometry and UI integration. No flight or other-city UI
acceptance is claimed here. Six new rule groups plus all319 existing groups pass
in Chrome154.0.8037.97 (`r09-regional-core-validation.json`). Tests include declared
foreign-lot fixtures and atomic rejection; no native emulator capture is claimed.
Flight rules and live integration remain required before R09 completion.

The paragraph above records the R09a core checkpoint. R09f completes live
navigation, regional services and version23 saves. See the
[completion audit](r09-completion.md) for current acceptance evidence and the
ordinary-play two-system trade/return/reload journey.
