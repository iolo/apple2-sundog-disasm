# R08 implementation and completion audit

Status: **in progress, R08l**. The objective remains the entire R08 row in
`PLAN-REMAKE.md`, not just depot pricing or the R07 local cargo journey.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Equipment replacement | R08d connects atomic faulty installation, burnout, removal and working replacement to actual bay access. Fresh-character replacement/shunt/cannibalization regression passes37 UI checks. R08f connects source machinery dependencies; its rules and UI prove shutdown when working parts are removed. | Include component replacement and restored readiness in the combined acceptance journey. |
| Equipment failures and repair | R08c traces Game14 delayed failure (not repair) and Library24 selected-hit/dependency rules. The28 failure UI checks pass again with R08f's version20 and live dependencies, using a declared carried-part fixture. | Ordinary faulty-component acquisition remains unproven in the current city; interpreter producer coverage is not a full purchase journey. Regional markets and combat producers retain R09/R10 ownership. Do not invent landed random damage or a repair-duration action. |
| Repair/fuel services | R08a source prices; R08b active hull/fuel, actual foot/pod access, confirmed localized service controls, auxiliary cargo transport and version18 saves. `depot-services-validation.json` proves a fresh-character servicing and loaded return journey. | Hull/fuel service gate is met. Component repair remains separate engineering work. |
| Ship readiness | R08f runs landed gun/shield/cloaker controls, actual performance, equipment dependencies, fuel depletion and automatic auxiliary consumption under one aboard clock. Version20 preserves phases/resources.31 machinery UI checks and61 fresh-character depot checks pass. | Final combined readiness audit, including replacement and servicing together. Launch/orbit/warp remain R09. |
| Pod boarding/departure and return | R08h connects independent occupancy/positions, source parking collision/exit/boarding, detached ship artwork/collision and version21 saves. `parking-ui-validation.json` proves42 checks through fresh-character purchases, loaded parking, foot exchange/ship visits, reloads, return boarding and docking. | R08l proves surface parking/retrieval and remote-city parking with52 live checks. Include it in the final combined acceptance journey. Native cabin exit/drive choices use explicit buttons; see `parked-pod.md`. |
| Surface traversal and terrain | R08l connects live composition, collision, camera and independent locations, and activates version22.52 UI checks prove normally purchased cargo, another city, surface parking, foot retrieval and loaded return.318 rule groups include source-arrival recovery, all21 legacy schemas and malformed imports. See `surface-travel.md`. | Live surface gate met; include this journey with engineering and servicing in the final acceptance audit. |
| Ship/pod/cargo ownership | R08h live city parking plus R08j independent ground domains. R08k validates and round-trips remote pod/cargo, rejects malformed occupancy, remote services and cryogen duplication, and preserves original ship/resources. | R08l live52-check journey proves cross-domain reload and loaded docking;318 rule groups also cover local foot repair with a surface pod and remote-service rejection. Repeat in combined acceptance. |
| Acceptance and regressions | R08l's `ground-live-rules-validation.json`, `surface-ui-validation.json`, `ground-parking-regression-validation.json` and `ground-depot-regression-validation.json` cover318 rule groups; the surface, parking, depot, room and focused outer-street service receipts total265 UI checks. Combined acceptance remains open. Earlier machinery/failure evidence remains recorded separately. Source/UI adaptations are in `ship-power.md` and `parked-pod.md`. | Extend the combined acceptance journey through component repair/readiness, parked pod and surface travel; prove terrain/transition rejection and repeat affected regressions. |

Implementation order: depot rules and source audit; active resources/depot services
and saves; encoded component damage/repair/readiness; independent pod parking and
boarding; surface traversal and return; full combined acceptance audit. This order
does not remove later items from R08. R09 still owns launch/orbit/warp/landing and
regional flight, and R11 owns colony delivery and campaign completion.

Every checkpoint must update `PROGRESS-REMAKE.md` and be committed. Completion
requires runtime and source evidence for every row above, including a normal
control journey through servicing and ground transport, plus current migration
and regression receipts. Depot servicing alone does not satisfy that completion gate.
