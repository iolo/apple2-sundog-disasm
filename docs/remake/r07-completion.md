# R07 completion audit

Status: **in progress**. R06 is complete; R07 remains a separate milestone.

| Requirement | Current state | Remaining work |
| --- | --- | --- |
| Active cash/system accounts and transfers | R07a adds deposits, withdrawals, inter-system transfers, atomic conservation and version12 account saves.207 rule groups,44 banking UI checks and existing scene/dialogue regressions pass. | Complete for this checkpoint; keep account updates atomic when trade is added. |
| Shop purchases/sales | R07d adds cash-paid item/equipment and bartender food/ale purchases, empty-slot capacity checks and version14 replay saves. | R07e traces direct seated-visitor resale and separate bartender matching. Implement visitor transfers and sale-income saves; ordinary shops have no Sell branch. |
| Exchange quotes and market updates | R07c activates local quantities, eight persisted offers, first-visit/weekly refresh, purchase replacement and continuing RNG.222 rule groups pass. | Extend active ownership when other cities become reachable; retain documented stable-review adaptation. |
| Commodity buying/selling | R07c adds bank-first purchases, local-account sales, source prices, random stock reductions and atomic failures. | Intercity profit/save rules when travel becomes available. |
| Warehouses and cargo | Local warehouse trades are live. R07e adds a tested four-warehouse/two-pod loading core with Store/Fetch/Swap and shared lot validation. Campaign cryogens stay protected. | Minimal pod movement/entry, active pod save ownership and cryogen/wealth conservation, then live loading controls. Ship cargo uses the same pod manifest. |
| Local trade loop | Bank and local exchange/warehouse round trips work through normal controls and fresh-page saves. | Complete personal-item resale and cargo portions of the loop. |

Next after [R07e cargo core](cargo-loading.md): implement the direct seated-visitor
trade path and sale accounting described in the [resale audit](personal-item-resale.md).
Then pull minimal pod movement/entry prerequisites forward from R08 to connect
active cargo saves and loading controls. Broader ground transport and depot
repair/fueling remain R08; travel R09; colony deliveries R11.
