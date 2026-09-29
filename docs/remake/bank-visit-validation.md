# Bank visit browser validation — R06c

2026-09-29; `/opt/google/chrome/google-chrome`, Chrome154.0.8037.57, isolated
headless context through Playwright CLI. No original-emulator behavior capture
is claimed. Source traces and deliberate browser adaptations are described in
[city buildings](city-buildings.md).

`tools/remake/bank_visit_smoke.js` creates seed12345, leaves the ship and walks
51 steps through normal pointer input to bank-door anchor `(369,299)`. Read-only
imports compute a route; they do not change the live campaign. Its28 checks cover:

- Door-proximity action, touch entry and keyboard reentry; current-system title
  and generated cash/account values.
- Focus trapping, paused movement/time, localized inquiry and viewport fit.
- Version4 export, explicit slot save and fresh-page reload inside the bank,
  exact state preservation and invalid non-bank-position import rejection.
- Escape/touch return to the same street pixel, paused; preview separation.

Both locales fit640×480,1280×720,390×844 and844×390 without dialog overflow.
Screenshots were inspected visually; paths and SHA-256 hashes are in
`bank-visit-validation.json`. The images are ignored local browser artifacts.

The86 browser rule groups pass. New groups exhaustively check32 raw tile indices,
both vehicle modes and every position in a28×32 tile; bank save consistency;
and version3 migration without allowing bank scenes in legacy envelopes.
Existing v1/v2, immutable balances, compatible equipment and transaction-conflict
checks continue to pass.

Regression scripts pass44 city-walking,45 campaign,37 component-exchange and14
recovery checks. The recovery fixtures use the newly exported version4 campaign.
Twelve Python exporter tests pass;125 generated artifacts,57 independent city
references,584 indexed strings and original input hashes verify unchanged.
`git diff --check` passes. Full room/NPC behavior and bank transactions are not
implemented or covered by this receipt.
