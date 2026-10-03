# Depot service rules — R08a

`remake/js/core/depot.js` implements source prices and atomic purchase operations
for refueling, hull repair and auxiliary fuel. This checkpoint is an isolated
service core. The live depot panel is still read-only and campaign saves remain
version17. Active ship resources, depot access, auxiliary cargo persistence and
the service UI must be connected together in the next checkpoint.

## Source evidence

| Source | Rule |
| --- | --- |
| Game19 proc26 `$137E–$139C` | System nibbles3/4/5 become locals14/13/12: byte17 high, byte18 low, byte18 high. Existing dialogue data exposes these as local32/local30/local31. |
| Proc25 `$1247–$1254` | Depot factor is local14 + local13 +16 − local12. |
| Proc20 `$1016–$1027` | One refuel unit costs `floor(100*factor/14)` credits. Initial service quantity is `floor((fuel+1)/16)`; limit16. |
| Proc21 `$10E2–$1106` | Repair restores the hull byte at equipment-bank offset192. Base cost per point is `250*(1+floor((16-hull)/4))`, adjusted for12 vs local12, then local13 vs11. This does not repair installed machinery. |
| Proc22/23 `$1088–$10D5` | Adjustment uses `8+abs(a-b)`: multiply by this over8 if a≥b, otherwise8 over this. Each step truncates. If `floor(32767/multiplier) <= value`, divide before multiplying, including equality. |
| Proc19 `$0E1D–$0E35`; Library28 proc6 | Service stops when unit price exceeds available funds. Exact funds are accepted. Capacity, not money, blocks a full resource. |
| Proc5/6 `$014C–$01EC` | Use the local account and carried cash as a spending pool; restore unspent cash/account balances. With no sale income in a service transaction, this is bank-first spending with cash spill. |
| Proc20 `$1029–$103A`; proc21 `$1108–$1119` | Refuel/repair require the ship in the player's current city. The ship does not have to be at the depot door itself. |
| Proc24 `$1152–$1190` | Auxiliary fuel costs `100*factor` per load. Only empty slots in the two-slot pod count; a foot-mode visit cannot buy a load for a remote pod. |
| Proc24 `$11D2–$1202` | Fill first empty slots with type1, quality7. The origin byte comes from the current **world** field (location word37, five bits at bit4), unlike ordinary exchange cargo's city origin. The routine does not write the price word. |

For Jondd, locals12/13/14 are14/8/12. The factor is22: refueling costs157 per
unit, auxiliary fuel costs2200 per load, and repairing hull13 costs145 per point.
The repair quote stays fixed during one selected multi-point purchase, as it
does inside native proc18. Opening another service recalculates it from the new
hull. No random draw determines these prices or purchases.

## Core boundary and explicit adaptations

The owned session is `{hull,fuel,cash,bankBalance,pod}`. The host supplies verified
city/world IDs, the three source nibbles, and ship/pod presence. It must derive
presence from real locations and entrance mode; these booleans are not a public
campaign access override. Confirmation recomputes the price from current state.
Failed validation, absence, capacity or funds checks leave the caller untouched.

The source refuel write-back combines the old `fuel%16` remainder with the new
service quantity. At some `fuel=15 mod16` boundaries this adds an extra unit; for
example, a one-unit purchase at fuel15 yields47. Paid operations retain that
arithmetic and cap at255. The browser does not perform the native unconditional
write-back on cancellation or zero-unit review, which would grant free fuel at
those boundaries. No resource changes merely because a quote was displayed.

Auxiliary fuel is a distinct lot shape:

```text
{commodityId:'cargo-01', quality:7, originWorld:'world-NN', pricePaid:0}
```

Canonical zero replaces the unwritten native price word rather than inheriting
stale bytes from an emptied slot. Fuel cannot be quoted as ordinary sale cargo.
Existing generic cargo and campaign validators intentionally still reject this
new lot until active resource/transport integration introduces its producer,
movement, consumption and migration rules. Ordinary and cryogen cargo already
in a service session are validated and preserved.

Browser atomic confirmations replace the native repeating purchase buttons.
This core does not invent a time charge from the UI's “hour” label or simulate
native service timing; timing and active machinery belong in live integration.

## Verification

`remake/tests/depot.js` covers independent numeric source vectors, the overflow
guard's equality boundary, every combination of three four-bit system fields
and hull0–16, all256 starting fuel values, exact/insufficient funds, account/cash
spill, fixed multi-point hull prices, first-empty auxiliary loading, world origin,
full/malformed containers, absent vehicles and input/result ownership.

The Chrome rule receipt is `depot-core-rules-validation.json`. No new visible
service, fuel-consuming journey, save-version change or native emulator capture
is claimed by this checkpoint. See [R08 audit](r08-completion.md) for the remaining
milestone requirements.
