# SunDog web remake

Current milestone: a playable landed campaign with character creation, ship and
city walking, inventory/condition/survival, component exchange, bank deposits,
withdrawals and inter-system transfers, local exchange purchases/warehouse sales,
shop purchases and information, paid lodging with working bedroom doors, and tavern
seating, conversations, visitor item buying/selling, food/ale purchases and bartender tips. TransStation and depot
doors open read-only service visits with saved return positions.
English/Korean controls and four campaign save slots cover the current scenes,
including open dialogue, seated visitors and rented rooms. The independent walkthrough and map
inspector remain available. Cargo transport, flight, combat and colony progression
are still pending. Evidence is in
`../docs/remake/behavior-matrix.md`.

From the repository root:

```sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory remake
```

Open `http://127.0.0.1:8000/` using `/opt/google/chrome/google-chrome`.
The folder is self-contained and can be copied to any static host, including
a subdirectory. No package install, build, external font request or backend is
needed. ESM requires HTTP; double-clicking `index.html` is not supported.
Local serving works without internet. A hosted copy does not yet cache for an
offline restart.

Use the preview tabs and previous/next buttons to browse. Select a map tile or
ship point to inspect coordinates. Focus the display and press Enter, then
arrow keys to move the selection. Elsewhere, left/right changes layouts.
Escape returns to the title. Language choice persists when browser storage is
available. The city inspector can switch between stored layouts and composed
ordinary-city maps and Banville. Banville's completed-phase selector previews
all ten growth stages without changing a campaign. Records58/59 remain stored
layouts only. See `../docs/remake/colony-maps.md`.

Choose **Walk aboard** in the ship preview. Hold the pointer or touch to walk;
release to stop. Arrow keys work while the ship display has focus. Pause, reset
and help are available in both languages; leaving the window pauses movement.
The walkthrough uses the original collision mask and movement attempts, with a
browser-specific 50 ms cadence. Visible play advances one game minute per real
second, including idle time; hunger and fatigue update hourly. Position and time
last until reload unless explicitly saved.
See `../docs/remake/ship-movement.md`.

Open **Inventory** (or press I/Enter with the ship focused) for four carried slots.
Walk above the starting position to reach stores, or right to reach the locker;
the inventory button then opens that container too. Select an item followed by a
destination slot; occupied slots swap. Escape cancels a selection before closing.
Resume continues walking. Carry food or rapidheal, select it, then choose its use
action. Food restores up to 80 nourishment; rapidheal restores up to 80 health.
Both consume one item even when already full. Choose **Sleep** to recover rest
while game time passes faster; food still depletes. Pause/Resume stops sleep,
and Wake up or Escape returns to inventory. Exhaustion forces sleep until rest
exceeds128. At zero vigor the walkthrough ends, with an explicit restart action.
Inventory, help and lost focus pause normal time. Save explicitly before reload;
**Return to start** moves the player without resetting items. See
`../docs/remake/inventory.md`, `../docs/remake/condition.md` and
`../docs/remake/survival.md` for rules, source evidence and timing adaptations.

Choose **Saves** while awake to save, load or delete one of four ship checkpoints.
Checkpoints preserve position, carried items, locker/stores, condition and game
time. Load resumes paused; close Saves and choose Resume. The end-of-walkthrough
dialog also offers Saves to recover a living checkpoint. Sleep cannot be saved.
JSON export backs up the current state; import restores it without automatically
writing a slot. Browser slots are tied to the current origin/profile. Invalid
files and stale-tab changes are rejected. These are ship walkthrough saves;
character drafts and campaign saves remain separate. See
`../docs/remake/checkpoints.md`.

Choose **Create a character** to enter a name and spend the original 440-point
attribute budget. Each + button shows its next cost; − refunds the previous
point. **Drafts** opens four browser-local slots and JSON import/export. Names
accept 1–15 Unicode grapheme clusters, including Korean. Draft saving is explicit;
export a JSON copy for use on another browser/origin. Closing the editor retains
unsaved edits only until reload. Choose **Board ship** after allocating
the character, enter a seed, then start aboard the ship. See
`../docs/remake/character-creation.md` for allocation rules.

In a campaign, leave through the ship's airlock and walk to a building entrance.
The Enter building button (or Enter with the walking surface focused) opens a
supported shop, lodging or tavern interior. Approach its counter and choose **Talk**.
At shops, select goods, accept the quote, then choose an empty carried slot to
pay cash. Bartender food/ale selection opens the slot choice directly. Save or
leave after a transfer to retain it; cancelling an untransferred offer costs nothing.
Lodging staff quote a fee; Pay deducts active cash when the dialogue returns and
assigns a numbered room. Its door opens when approached and closes behind you.
Saves retain payment, dialogue and room access; leaving the building ends that
visit's rental. Bank cash displays reflect lodging payments and bartender tips.
In a tavern, release movement at a table to sit, or choose Talk while beside a
seat. Visitors may approach or chat from the opposite seat. Continue advances
small talk and jokes; Back ends the conversation. Walking releases your seat.
If a visitor offers trade, accept a quote, then choose an empty slot to buy or a
matching carried slot to sell. Payment occurs at handover; leaving retains the
transfer. Charge variants are separate choices. Bartender trader matching remains
unavailable. See `../docs/remake/personal-trading.md`.

Open `/tests/` (relative to the served folder) for the dependency-free browser
checks.

The dialogue foundation exports all96 classified records and all165 messages,
and implements source selection rules, English text expansion, counter setup,
stateful predicates, controls/actions and a conversation runner. Live counters
support Talk/Enter, information, item quotes and room return in English/Korean.
Version15 saves retain local stock, offers, warehouse cargo, personal-sale totals and all twelve system accounts and restore open conversations
by replaying the saved RNG and inputs,
and retain active cash, lodging doors and tavern seat/visitor state. Earlier campaign versions migrate
after validation. Shop and bartender purchases use cash: accept a quote, then choose an empty
carried slot to pay. Saves replay purchases until the conversation returns;
leaving retains completed transfers. Visitor sales use the same replay boundary;
cargo transport remains pending. See
`../docs/remake/dialogue-selection.md`, `../docs/remake/dialogue-text.md`,
`../docs/remake/dialogue-state.md`, `../docs/remake/dialogue-runner.md` and
`../docs/remake/room-counter.md` and `../docs/remake/dialogue-ui.md` for scope and
source evidence; lodging is described in `../docs/remake/lodging.md` and taverns
in `../docs/remake/tavern-dialogue.md`.
R06 city/building exploration is complete; its evidence and scope are recorded in
`../docs/remake/r06-completion.md`. R07 is in progress: banking, shop/food purchases, visitor buying/selling and local warehouse trading
are live; cargo transport and loading remain next.

At a bank, choose **Deposit**, **Withdraw** or **Transfer**. Select an amount with
the original increments, All or Clear; Confirm commits it. Cancel leaves balances
unchanged. Transfers select another system and charge no fee. Saves retain only
committed balances; a fresh load discards a pending amount. See
`../docs/remake/banking.md`.

At the exchange, choose a lot under **Offers** and Confirm to buy it into the
local warehouse. Payment uses the bank first, then cash. Under **Warehouse**,
review and confirm a sale to deposit its proceeds in the local account. There
are four slots; initial cryogens cannot be sold. Cancel/Escape discards a review.
The asking price must be less than combined available funds. Saves preserve
committed trades and current offers. See `../docs/remake/exchange-trading.md`.

Development export checks:

```sh
python3 tools/remake/source_index.py --check
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
```

Development initialization primitives now cover generated equipment, system
coordinates/balances and orbital angles. They are tested independently and are
not yet connected to character creation or ship checkpoints. See
`../docs/remake/initialization.md` for source evidence, seed boundaries and the
remaining campaign fields. With cc65/sim65 installed, verify native RNG and the
clean equipment reference using:

```sh
python3 tools/remake/random_reference.py
python3 tools/remake/initialization_reference.py
```

SVGs are generated from delivered Apple II assets; see `data/provenance.json`.
Mulmaru is distributed under OFL 1.1; see `assets/fonts/LICENSE.txt` and its
provenance record. This browser preview introduces no claim of new rights in
the original SunDog artwork or game content.

R07e adds the tested cargo-loading core (four warehouse slots, two pod slots,
Store/Fetch/Swap). It is not yet connected to live pod travel or campaign saves.
See `../docs/remake/cargo-loading.md` and `../docs/remake/personal-item-resale.md`
for the remaining integration and the source-backed visitor sale route.
