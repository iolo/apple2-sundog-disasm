# Active banking — R07a

The Uniteller now deposits carried cash, withdraws from the local system account,
and transfers to any other system. All twelve accounts retain their original
initial balances and persist independently of campaign creation. Cash remains
owned by `dialogue.cash`, so lodging and bartender tips use withdrawn funds
without a second wallet to reconcile.

## Source rules

| Source in `src/pcode/game_19.s` | Implemented rule |
| --- | --- |
| Proc17 `$0C10–$0C25`, `$0DB9–$0DBF` | Load/write the current system's two-word account at system record words6–7. The original keeps a working copy during the visit; the browser commits each confirmed transaction immediately. |
| Proc17 `$0CDC–$0D63`, `$0D85–$0D9C` | Deposit is available with positive cash; withdrawal/transfer with a positive account. Deposit/withdraw exchange cash and the local account through proc7. |
| Proc7 `$01F8–$0236`, `$02C7–$030A` | ALL,100,1000,10000,50000,CLEAR controls. ALL adds the remaining available funds; CLEAR resets both selected and available amounts. |
| Proc7 `$030C–$032F`, `$033F–$0348` | Reject increments greater than available; subtract accepted increments from the available working amount and add them to the selected amount. At completion add the amount to the destination and write the remaining source. |
| Proc16 `$0B85–$0B92`, proc9 `$0411–$0414`, `$04C8–$04DF` | Transfer destination selector covers systems1..12 and excludes the current system. |
| Proc16 `$0BCB–$0BF4` | Transfer the selected local funds through a zeroed temporary amount, then add it to the chosen destination account. No fee or random draw occurs in this transfer path. |

Library28 procedures2/3 implement credit addition/subtraction, with signed
thousands and remainder; procedure6 `$00FE–$0121` compares the pair. For the
nonnegative amounts reachable here the browser uses exact integers up to
32,767,999. Overflow is rejected before either side changes, rather than emulating
signed-word wrap. Initial accounts and these banking operations never create
deficits; debt-related progress is not accepted by this save scope.

The browser uses explicit **Confirm** and **Cancel**. Choosing an amount moves
no funds. This makes cancellation discard the whole draft; the native amount
loop instead commits its accumulated selection on return. Transaction drafts are
transient: saving retains committed balances and loading discards an unfinished
draft. Locale changes and opening/closing Saves retain a draft within the page.
Service inspection and transactions retain R06's paused time/movement adaptation;
no invented banking fee, time charge or RNG draw is added.

## State and atomicity

`economy:{accounts:[{systemId,balance},...]}` is the first active economy block,
ordered system01..12. `start.systems` and `start.economy` remain immutable creation
evidence. Markets, warehouses, cargo and prices are not made mutable by this step.

`transferBankFunds` returns owned accounts and cash after validating funds,
destination and capacity. It cannot partially debit on error. The campaign wrapper
requires the bank scene and actual bank door. Normal scene/save validation supplies
reachability. Banking leaves dialogue flags, actors, inventory, equipment, time
and RNG intact; repeated explicit confirmations are separate transactions, while
closing or reloading an already confirmed action cannot apply it twice.

Campaign version12, scope `landed-banking-1`, adds the seventh `economy` state
part. Versions1–11 must pass their historical field/scene/cash restrictions before
receiving accounts derived from their own validated creation record. They cannot
inject an economy block or use the new withdrawal rule to bypass old cash limits.
New saves allow carried cash above creation cash but require cash plus all accounts
not to exceed original total money. Lodging and tips may lower that total. Sales,
income and other trading mutations require the next explicit save-boundary update.
This is state consistency validation, not cryptographic transaction provenance.

## Validation

`remake/tests/banking.js` covers decimal carry, exact sub-hundred ALL amounts,
all132 directed system pairs, maximum balances, malformed inputs, empty accounts,
overdraft/overflow atomicity, door enforcement, conservation, owned data and legacy
save restrictions. Existing dialogue and migration tests now exercise version12.
Current rule receipt: `banking-rules-validation.json` (207 groups), including
a withdrawal-funded lodging payment replay with unchanged bank accounts.

`tools/remake/banking_smoke.js` walks from a new campaign to the bank using normal
controls, then tests pending/cancelled/confirmed amounts, deposits, withdrawals,
remote transfers, fresh-page IndexedDB reloads, import rejection/migration and
English/Korean transfer forms. `banking-ui-validation.json` records44 checks:
both locales fit five viewport sizes, committed and pending states behave
independently, version11 imports migrate, and forged wealth is rejected.
The compact form places balances side by side to keep the footer visible on
portrait screens. No native emulator capture is claimed.
English and Korean transfer screenshots were visually reviewed after font/layout
settling; balances, amount buttons and the entire footer remain visible.

Version12 regression receipts record28 bank-visit,27 lodging,36 tavern,19
information-dialogue and90 continuous journey checks (`banking-*-regression.json`).
The journey visits every building class and returns aboard with exact saves;
the focused lodging rule additionally proves payment from withdrawn cash.
All159 generated artifacts still match the deterministic export.
