# R08 implementation and completion audit

Status: **in progress, R08e**. The objective remains the entire R08 row in
`PLAN-REMAKE.md`, not just depot pricing or the R07 local cargo journey.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Equipment replacement | R08d connects atomic faulty installation, burnout, removal and working replacement to actual bay access and version19 saves. Fresh-character replacement/shunt/cannibalization regression passes37 UI checks. | Connect machinery dependency consequences when power controls become active. |
| Equipment failures and repair | R08c traces Game14 delayed failure (not repair) and Library24 selected-hit/dependency rules. R08d's28 UI checks prove installation/failure/replacement and pending reload using a declared carried-part fixture. | Ordinary faulty-component acquisition remains unproven in the current city; interpreter producer coverage is not a full purchase journey. Connect active machinery consequences without inventing landed random damage or a repair-duration action. Regional markets and combat producers retain R09/R10 ownership. |
| Repair/fuel services | R08a source prices; R08b active hull/fuel, actual foot/pod access, confirmed localized service controls, auxiliary cargo transport and version18 saves. `depot-services-validation.json` proves a fresh-character servicing and loaded return journey. | Hull/fuel service gate is met. Component repair remains separate engineering work. |
| Ship readiness | R08b owns active resources separately from immutable creation data. R08d displays hull, fuel and offline units. R08e adds the isolated source power-phase, depletion and auxiliary-consumption core. | Connect live controls, phase/clock/save ownership and equipment dependencies; validate readiness conditions without enabling R09 flight prematurely. Status display and isolated power rules alone are not this gate. |
| Pod boarding/departure and return | R07g supports attached departure, city driving, exchange cargo entrance and loaded docking. | Independent parked pod ownership, disembark/board access and collision, loaded unattended saves and return. R08b already adds depot entry. |
| Surface traversal and terrain | Source city/world maps and native movement procedures exist. | Trace and implement the required city/surface transitions, foot/pod terrain rules, continuous location and return. |
| Ship/pod/cargo ownership | R07 conserves ordinary cargo/cryogens; R08b adds auxiliary transport. R08e connects automatic docking refill, consuming one load only below5 fuel; a fresh-character purchase/return/reload journey proves it. Detached player currently stays with pod. | Extend ownership to parked pod/surface travel and connect the separate machinery-tick auxiliary consumer. |
| Acceptance and regressions | R08e extends the power/docking rule coverage and depot UI journey; current receipts are `ship-power-rules-validation.json` and `auxiliary-docking-validation.json`. R08d failure/replacement evidence is recorded separately. | Extend the combined acceptance journey through component repair/readiness, parked pod and surface travel; prove terrain/transition rejection and repeat affected regressions. |

Implementation order: depot rules and source audit; active resources/depot services
and saves; encoded component damage/repair/readiness; independent pod parking and
boarding; surface traversal and return; full combined acceptance audit. This order
does not remove later items from R08. R09 still owns launch/orbit/warp/landing and
regional flight, and R11 owns colony delivery and campaign completion.

Every checkpoint must update `PROGRESS-REMAKE.md` and be committed. Completion
requires runtime and source evidence for every row above, including a normal
control journey through servicing and ground transport, plus current migration
and regression receipts. Depot servicing alone does not satisfy that completion gate.
