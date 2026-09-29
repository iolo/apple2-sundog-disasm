# City walking and airlock validation — R06b

2026-09-29, required `/opt/google/chrome/google-chrome` 154.0.8037.57:

- 44 airlock/city UI checks.
- 83 browser rule/localization/storage groups.
- 45 campaign,37 component-exchange and97 city-preview regression checks.
- 14 exhaustion/death/storage recovery checks.
- 12 exporter tests,125 deterministic artifacts,57 city composition references,
  584 classified strings and original disk/manual hashes verified.

The [JSON receipt](city-walk-validation.json) records the checks and screenshots.
Browser tests use isolated storage, normal UI input and a virtual clock. Tests
cover keyboard departure, camera-relative pointer movement, elapsed survival time,
pause, fresh-page exterior save/load, independent preview state, touch boarding,
repeat departure and rejection of a wall-position import without state replacement.
No writable test hooks or hidden state assignment are used.

The exterior screen fits both languages at640×480,1280×720,390×844 and844×390;
the expanded interior footer also fits desktop and narrow portrait sizes. English
and Korean screenshots were reviewed. Exterior storage exposes carried items only;
engineering and remote locker/stores access are unavailable there.

Core tests check source-derived exterior and interior anchors, glyph10/11 masks,
pattern9 collision across HGR byte boundaries, ship silhouette obstruction,
boarding proximity and camera positions. Reachability includes the actual
one/two-pixel requests and rejects unsupported bounds. City snapshots preserve
changed equipment separately from creation and reject walls, fractional/extra
positions, wrong scenes and inconsistent interior anchors. Version1/2 migration
and transaction conflict behavior remain covered.

Exporter tests independently compare the tile rows, original glyph bytes and
pattern-table entries. These tests are source-based; they do not establish parity
with a newly observed original-game city session. The checkpoint supports only
the initial landed, attached-pod Drahew configuration and bounds walking to the
stored city rectangle. Buildings, encounters, NPCs and surface travel remain open.
