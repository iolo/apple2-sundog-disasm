# R08 implementation and completion audit

Status: **in progress, R08b**. The objective remains the entire R08 row in
`PLAN-REMAKE.md`, not just depot pricing or the R07 local cargo journey.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Equipment replacement | R05f active installed/carried exchanges, fit checks and recalculated performance; existing rule/UI coverage. | Integrate encoded damage, delayed repair and dependent machinery flags. |
| Equipment failures and repair | Original Library24 damage/recalculation and Game14 delayed repair source are available. | Trace and implement reachable failure producers, repair state/timing, consequences and saves. |
| Repair/fuel services | R08a source prices; R08b active hull/fuel, actual foot/pod access, confirmed localized service controls, auxiliary cargo transport and version18 saves. `depot-services-validation.json` proves a fresh-character servicing and loaded return journey. | Hull/fuel service gate is met. Component repair remains separate engineering work. |
| Ship readiness | R08b owns active resources separately from immutable creation data and persists depot progress. | Equipment-dependent power/charge cleanup and readiness feedback; validate source conditions without enabling R09 flight prematurely. |
| Pod boarding/departure and return | R07g supports attached departure, city driving, exchange cargo entrance and loaded docking. | Independent parked pod ownership, disembark/board access and collision, loaded unattended saves and return. R08b already adds depot entry. |
| Surface traversal and terrain | Source city/world maps and native movement procedures exist. | Trace and implement the required city/surface transitions, foot/pod terrain rules, continuous location and return. |
| Ship/pod/cargo ownership | R07 conserves local warehouse/pod lots and initial cryogens; R08b adds auxiliary pod/warehouse transport without remote loading. Detached player currently stays with pod. | Extend ownership to parked pod/surface travel and connect source automatic auxiliary consumption. |
| Acceptance and regressions | R08b:265 passing rule groups and238 UI checks, including a fresh-character damaged-hull service, fuel/auxiliary purchases, warehouse transport and loaded return. Both locales and version18/legacy saves verified. | Extend the combined acceptance journey through component repair/readiness, parked pod and surface travel; prove terrain/transition rejection and repeat affected regressions. |

Implementation order: depot rules and source audit; active resources/depot services
and saves; encoded component damage/repair/readiness; independent pod parking and
boarding; surface traversal and return; full combined acceptance audit. This order
does not remove later items from R08. R09 still owns launch/orbit/warp/landing and
regional flight, and R11 owns colony delivery and campaign completion.

Every checkpoint must update `PROGRESS-REMAKE.md` and be committed. Completion
requires runtime and source evidence for every row above, including a normal
control journey through servicing and ground transport, plus current migration
and regression receipts. Depot servicing alone does not satisfy that completion gate.
