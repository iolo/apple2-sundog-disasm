# R08 implementation and completion audit

Status: **in progress, R08f**. The objective remains the entire R08 row in
`PLAN-REMAKE.md`, not just depot pricing or the R07 local cargo journey.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Equipment replacement | R08d connects atomic faulty installation, burnout, removal and working replacement to actual bay access. Fresh-character replacement/shunt/cannibalization regression passes37 UI checks. R08f connects source machinery dependencies; its rules and UI prove shutdown when working parts are removed. | Include component replacement and restored readiness in the combined acceptance journey. |
| Equipment failures and repair | R08c traces Game14 delayed failure (not repair) and Library24 selected-hit/dependency rules. The28 failure UI checks pass again with R08f's version20 and live dependencies, using a declared carried-part fixture. | Ordinary faulty-component acquisition remains unproven in the current city; interpreter producer coverage is not a full purchase journey. Regional markets and combat producers retain R09/R10 ownership. Do not invent landed random damage or a repair-duration action. |
| Repair/fuel services | R08a source prices; R08b active hull/fuel, actual foot/pod access, confirmed localized service controls, auxiliary cargo transport and version18 saves. `depot-services-validation.json` proves a fresh-character servicing and loaded return journey. | Hull/fuel service gate is met. Component repair remains separate engineering work. |
| Ship readiness | R08f runs landed gun/shield/cloaker controls, actual performance, equipment dependencies, fuel depletion and automatic auxiliary consumption under one aboard clock. Version20 preserves phases/resources.31 machinery UI checks and61 fresh-character depot checks pass. | Final combined readiness audit, including replacement and servicing together. Launch/orbit/warp remain R09. |
| Pod boarding/departure and return | R07g supports attached departure, city driving, exchange cargo entrance and loaded docking. | Independent parked pod ownership, disembark/board access and collision, loaded unattended saves and return. R08b already adds depot entry. |
| Surface traversal and terrain | Source city/world maps and native movement procedures exist. | Trace and implement the required city/surface transitions, foot/pod terrain rules, continuous location and return. |
| Ship/pod/cargo ownership | R07 conserves ordinary cargo/cryogens; R08b adds auxiliary transport. R08e connects automatic docking refill below5 fuel. R08f connects the distinct machinery-tick consumer, preserving deficits and attachment/first-slot rules. Detached player currently stays with pod. | Extend ownership to parked pod/surface travel. |
| Acceptance and regressions | R08f's `machinery-*-validation.json` receipts cover293 rule groups and139 UI checks: machinery31, depot61, failures28 and dialogue19. Source/UI adaptations are recorded in `ship-power.md`. | Extend the combined acceptance journey through component repair/readiness, parked pod and surface travel; prove terrain/transition rejection and repeat affected regressions. |

Implementation order: depot rules and source audit; active resources/depot services
and saves; encoded component damage/repair/readiness; independent pod parking and
boarding; surface traversal and return; full combined acceptance audit. This order
does not remove later items from R08. R09 still owns launch/orbit/warp/landing and
regional flight, and R11 owns colony delivery and campaign completion.

Every checkpoint must update `PROGRESS-REMAKE.md` and be committed. Completion
requires runtime and source evidence for every row above, including a normal
control journey through servicing and ground transport, plus current migration
and regression receipts. Depot servicing alone does not satisfy that completion gate.
