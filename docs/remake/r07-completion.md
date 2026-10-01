# R07 completion audit

Status: **in progress**. R06 is complete; R07 remains a separate milestone.

| Requirement | Current state | Remaining work |
| --- | --- | --- |
| Active cash/system accounts and transfers | R07a adds deposits, withdrawals, inter-system transfers, atomic conservation and version12 account saves.207 rule groups,44 banking UI checks and existing scene/dialogue regressions pass. | Complete for this checkpoint; keep account updates atomic when trade is added. |
| Shop purchases/sales | Dialogue quotes and information are live; cash is already active. | Trace and commit supported item/food transactions, including inventory capacity and failure paths. |
| Exchange quotes and market updates | R07b implements source prices, origin resale ceilings, eight entry offers and staged refresh/continuing RNG;215 rule groups pass. Exchange UI is still a service preview. | Active stock and persisted offer state, campaign entry/exit integration and offer replacement during purchases. |
| Commodity buying/selling | Creation data includes commodities and initial warehouses. | Bank-first payment, local-account proceeds, prices, stock updates and atomic failure behavior. |
| Warehouses and cargo | Initial four-slot warehouses and cryogen distribution are verified. | Ownership, loading/unloading, cargo capacity and conservation across saves. |
| Local trade loop | Banking round trips are the first checkpoint. | Full bank/shop/exchange/warehouse/cargo loop, source evidence and fresh-session persistence. |

Next after [R07b](exchange-quotes.md): introduce active market/warehouse and
offer fields, then couple ordinary exchange transactions to payment. Keep purchases gated
until stock, funds, ownership and capacity can commit together. Pod movement and
depot repair/fueling remain R08; travel R09; colony deliveries R11.
