# R08 implementation and completion audit

Status: **in progress, R08a**. The objective remains the entire R08 row in
`PLAN-REMAKE.md`, not just depot pricing or the R07 local cargo journey.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Equipment replacement | R05f active installed/carried exchanges, fit checks and recalculated performance; existing rule/UI coverage. | Integrate encoded damage, delayed repair and dependent machinery flags. |
| Equipment failures and repair | Original Library24 damage/recalculation and Game14 delayed repair source are available. | Trace and implement reachable failure producers, repair state/timing, consequences and saves. |
| Repair/fuel services | R08a source-derived depot prices and atomic hull/refuel/auxiliary operations; `depot-services.md` and rule receipt. | Activate ship resources and depot entrance/presence checks, persist auxiliary cargo, add confirmed localized controls, verify actual serviced journeys. |
| Ship readiness | Initial hull/fuel/charge/power fields exist only in immutable creation data. | Active resource ownership, equipment-dependent power/charge cleanup and readiness feedback; validate source conditions without enabling R09 flight prematurely. |
| Pod boarding/departure and return | R07g supports attached departure, city driving, exchange cargo entrance and loaded docking. | Independent parked pod ownership, disembark/board access and collision, service entry, loaded unattended saves and return. |
| Surface traversal and terrain | Source city/world maps and native movement procedures exist. | Trace and implement the required city/surface transitions, foot/pod terrain rules, continuous location and return. |
| Ship/pod/cargo ownership | R07 conserves local warehouse/pod lots and initial cryogens; detached player currently stays with pod. | Extend ownership to parked pod, surface travel and auxiliary fuel without remote loading, duplication or silent losses. |
| Acceptance and regressions | R07 baseline is252 passing rule groups and368 UI checks. | A damaged ship is serviced at verified costs; loaded pod reaches a supported destination and returns; invalid terrain/transitions fail atomically; current and legacy saves, both locales and viewport controls pass. |

Implementation order: depot rules and source audit; active resources/depot services
and saves; encoded component damage/repair/readiness; independent pod parking and
boarding; surface traversal and return; full combined acceptance audit. This order
does not remove later items from R08. R09 still owns launch/orbit/warp/landing and
regional flight, and R11 owns colony delivery and campaign completion.

Every checkpoint must update `PROGRESS-REMAKE.md` and be committed. Completion
requires runtime and source evidence for every row above, including a normal
control journey through servicing and ground transport, plus current migration
and regression receipts. R08a alone does not satisfy that completion gate.
