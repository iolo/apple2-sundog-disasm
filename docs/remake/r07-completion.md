# R07 completion audit

Status: **in progress**. R06 is complete; R07 remains a separate milestone.

| Requirement | Current state | Remaining work |
| --- | --- | --- |
| Active cash/system accounts and transfers | R07a adds deposits, withdrawals, inter-system transfers, atomic conservation and version12 account saves.207 rule groups,44 banking UI checks and existing scene/dialogue regressions pass. | Complete for this checkpoint; keep account updates atomic when trade is added. |
| Shop purchases/sales | Dialogue quotes and information are live; cash is already active. | Trace and commit supported item/food transactions, including inventory capacity and failure paths. |
| Exchange quotes and market updates | R07c activates local quantities, eight persisted offers, first-visit/weekly refresh, purchase replacement and continuing RNG.222 rule groups pass. | Extend active ownership when other cities become reachable; retain documented stable-review adaptation. |
| Commodity buying/selling | R07c adds bank-first purchases, local-account sales, source prices, random stock reductions and atomic failures. | Intercity profit/save rules when travel becomes available. |
| Warehouses and cargo | Four local warehouse slots support owned purchases/sales and version13 persistence; initial cryogens are protected. | Pod/ship loading, unloading, capacity and conservation. |
| Local trade loop | Bank and local exchange/warehouse round trips work through normal controls and fresh-page saves. | Complete the shop and cargo portions of the loop. |

Next after [R07c](exchange-trading.md): source and implement shop item/food
transactions, then cargo ownership/loading. Pod movement and
depot repair/fueling remain R08; travel R09; colony deliveries R11.
