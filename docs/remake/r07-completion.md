# R07 completion audit

Status: **in progress**. R06 is complete; R07 remains a separate milestone.

| Requirement | Current state | Remaining work |
| --- | --- | --- |
| Active cash/system accounts and transfers | R07a adds deposits, withdrawals, inter-system transfers, atomic conservation and version12 account saves.207 rule groups,44 banking UI checks and existing scene/dialogue regressions pass. | Complete for this checkpoint; keep account updates atomic when trade is added. |
| Shop purchases/sales | R07d adds shop/food purchases. R07f enables visitor purchases/sales, explicit slot handover, exact charged-byte removal and version15 gross-income/replay saves.242 rule groups and34 new UI checks pass. | Direct visitor trading is live; bartender matching still needs its actor lifecycle. Ordinary shops have no Sell branch. |
| Exchange quotes and market updates | R07c activates local quantities, eight persisted offers, first-visit/weekly refresh, purchase replacement and continuing RNG.222 rule groups pass. | Extend active ownership when other cities become reachable; retain documented stable-review adaptation. |
| Commodity buying/selling | R07c adds bank-first purchases, local-account sales, source prices, random stock reductions and atomic failures. | Intercity profit/save rules when travel becomes available. |
| Warehouses and cargo | R07g connects Store/Fetch/Swap to local pod driving, cargo entrance access, docking and version16 saves. Both containers conserve paid cargo and initial cryogens. Ship cargo uses the same pod manifest. | Local transport/loading complete; broader ground transport and unattended parking remain R08. |
| Local trade loop | Bank, visitor trades and warehouse trades preserve saves. R07g verifies a fresh-game pod journey, loading/swapping, loaded docking, return, unloading and sale into the local account. | Final combined regression/completion audit after trader matching. |

After [R07g pod cargo](pod-cargo.md), complete bartender trader matching and
its actor lifecycle, then audit R07's full local trade requirements. Broader
ground transport and depot repair/fueling remain R08; travel R09; colony deliveries R11.
