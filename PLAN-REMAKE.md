# SunDog Apple II web remake plan

Planning checkpoint: 2026-09-27. Requirements: [PRD-REMAKE.md](PRD-REMAKE.md).
Implementation history: [PROGRESS-REMAKE.md](PROGRESS-REMAKE.md).

## Direction and scope

Build a standalone, single-player JavaScript remake in `remake/`, using the
supplied Apple II version as the gameplay reference. Preserve its exploration,
trading, ship maintenance, survival, encounters, and colony contract; redraw
its graphics as separate SVG assets and make all player-facing text available
in English and Korean. Keep the requested HTML/CSS/ESM/Canvas 2D stack. No
framework, runtime library, bundler, backend, or emulator is needed in the app.

Implementation was authorized on 2026-09-27 after the planning checkpoint.
See PROGRESS-REMAKE.md for completed substeps and outstanding evidence gates.

The first playable milestone is a ship scene with movement, interaction,
personal status, inventory, and persistent saves. That milestone is a foundation,
not the completed remake. Completion requires a new game that can reach the
colony-contract ending through ordinary play, with the supporting systems below.

Proposed scope decisions:

- Reimplement behavior in readable JavaScript modules. Use the reconstructed
  p-code and native routines to establish rules; do not translate every machine
  instruction or implement a general Pascal VM as a prerequisite.
- Use the supplied version's four save slots. The manual describes eight;
  this discrepancy is already documented. New browser saves have a versioned
  format; original disk-save import/export is an optional later feature.
- Replace media swapping and hardware calibration with ordinary browser flows.
  Preserve the meaning of select/move and back/status actions. Offer pointer,
  keyboard, and touch equivalents; physical gamepad support is optional.
- Preserve game content and consequential rules. Record deliberate changes to
  controls, timing, presentation, and persistence. Do not claim cycle, pixel,
  or audio identity.
- Keep the old reconstruction deliverables intact. Do not reopen the accepted
  488-byte unidentified-data investigation.

### Static delivery and offline interpretation

Interpret “no server” as **no application backend**. The deliverable is a folder
of static files. Native ESM cannot reliably run by double-clicking `index.html`
under `file://` in normal Chrome; use static HTTP for development and static
hosting for delivery. This follows the [browser module loading constraints](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules).
If literal `file://` launch is required, settle that change before step R03;
it conflicts with the current ESM delivery choice. Do not disable browser security.

Vendor the font and every runtime resource locally, with no CDN or API requests.
A downloaded copy served on localhost works without internet. Offline reopening
of a previously hosted copy is a separate optional service-worker enhancement;
it needs an initial successful cache installation and a secure context, including
localhost. See [service-worker requirements](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers).

## Available references and their limits

The inventory below was inspected for this plan. Historical investigation notes
can contain obsolete incomplete-status statements; use the current
[delivery checklist](docs/delivery-checklist.md) and [handoff](HANDOFF.md) for
reconstruction status.

| Resource | What can be reused | What remains to establish |
| --- | --- | --- |
| [Source index](src/README.md), `src/pcode/`, `src/native/`, `src/dialogue/` | Exact reconstructed code; 34 distinct inventoried Pascal segments; named dialogue encoding; native render/I/O routines | Most procedures and state fields still have numeric names. Byte-complete reconstruction is not a gameplay specification. |
| [Assets index](assets/README.md) and individual manifests | Lossless graphics/data, hashes, provenance, and decoded previews; 31 manifests covering 32 identified-data components | Convert selected live assets to browser formats; retained/demo variants are not automatically gameplay content. |
| [Ship images](docs/packed-ship-images.md), [title](docs/title-bitmap.md), [tiles](docs/tile-banks.md), [world tiles](docs/world-tiles.md), [play glyphs](docs/play-glyphs.md) | Ship geometry, silhouettes, tile/glyph banks, title art, interaction imagery | SVG redraws, runtime palette decisions, collision and interaction geometry; previews alone do not establish these rules. |
| [World maps](docs/world-maps.md), [city maps](docs/city-maps.md), [prefixes](docs/map-record-prefixes.md) | 18 world payloads decoded to 40×24 grids; 60 play city payloads plus four distinct demo payloads decoded to 20×12 grids | Terrain meanings, city/world associations, variants, travel rules and placements. City payloads occupy a central region of a larger runtime map. |
| [Saved state](docs/save-state-banks.md), [working state](docs/working-state.md) | Four 5,024-byte state payloads, slot descriptors, typed record boundaries and serialization evidence | Named fields, clean new-game initialization, economy/world-table semantics. Existing saves belong to prior play sessions. |
| [Item names](docs/item-names.md), [dialogue dictionary](docs/dialogue-dictionary.md), [scripts](docs/dialogue-scripts.md), [bank layout](docs/dialogue-bank-layout.md) | Item text, dictionary/messages, 96 script records and a reconstructed interpreter in `game_16.s` | Predicate/action meanings, substitutions, encounter reachability, and Korean translation. UI strings also occur inline in p-code. |
| [Reference sessions](docs/reference/README.md), [MAME save/reload](docs/save-reload-validation.md), [Apple2TS validation](docs/apple2ts-behavior-validation.md) | Checked-in screenshots, scripted input sequences, startup/interaction/save/reload baselines | New-game creation, travel, combat, campaign completion, audio and long-running behavior are not comprehensively validated. |
| [Original manual](sundog.pdf), [existing manual notes](docs/manual-notes.md) | Player-facing intent, controls, ship layout, navigation, encounters and trading | Scanned pages have no extractable text. Manual/version discrepancies need a recorded decision, not silent merging. |
| `ref/apple-pascal-interpreter.{pdf,txt}`, `ref/apple-pascal-tech-notes.{pdf,txt}` | Local Pascal technical references when interpreting procedures | The reconstructed interpreter remains the authority for this game's actual dialect. |
| `tools/*_asset.py`, `tools/pcode_source.py`, `tools/reference_mame.py` | Existing decoders, extraction/verification patterns, and reference automation | Add small remake exporters and targeted scenarios; avoid depending on ignored build outputs. |

The repository reports exact reproduction of both disks and 180 passing tests
at its final reconstruction checkpoint. Those historical checks were not rerun
for this documentation-only plan. `remake/` is currently empty.

### Manual coverage used for planning

Page numbers are **1-based PDF page indices**. Page 7 and pages 11–20 were
visually read for this plan; existing notes cover pages 8–10.

| PDF pages | Implications for the remake |
| --- | --- |
| 7 | Find Banville on Jondd, deliver construction goods, and recover/deliver cryogenic colonists. The described region has 12 systems and 18 inhabited planets; verify their mapping to extracted records. |
| 8–10 | New/resumed games, utilities, saving, and the two-button interaction model. Supplied-image disk roles and slot count differ from the manual. |
| 11–12 | Ship movement, airlock, pilotage, engineering bays, cargo pod, lockers, carried objects, nourishment, rest, health and vigor. |
| 13–14 | Pilotage/status/tactical displays, fuel and warp charge, star/system/planet maps, destination selection and cancellation. |
| 15–18 | Walking and entering locations, building interiors, conversations, and ground combat. |
| 19–20 | Separate system bank balances; transfers; exchange purchases drawing from the local bank before cash; sales depositing locally; warehouse storage. Exact formulas still need code/runtime evidence. |

Pages 21–22 include supplementary French editorial material/artwork; they are
not a substitute for the game's rules or a missing technical specification.

### External resources

Checked on 2026-09-27:

- [Mulmaru](https://github.com/mushsooni/mulmaru) supplies Korean/ASCII glyphs
  and proportional/Mono variants under OFL 1.1. Its documentation recommends
  12px or multiples. The checked [v1.0 release](https://github.com/mushsooni/mulmaru/releases/tag/v1.0)
  offers `Mulmaru.zip` and `MulmaruMono.zip`. Step R02 will download a pinned
  archive, inspect its webfont files, and retain license, source URL and hashes.
  No font files have been vendored at this planning checkpoint.
- [laanwj/sundog](https://github.com/laanwj/sundog) is an Atari ST port with a C
  p-system interpreter and reimplemented native routines. Its documentation
  can help interpret concepts, but it is a different version and not a browser
  engine or authoritative source of Apple II rules.
- [SunDog Resurrection Project](https://sundogresurrectionproject.com/) is a
  secondary comparison resource, not an implementation dependency.
- Other links in [PRD.md](PRD.md), such as Wizardry/Pascal work and sibling
  disassemblies, are optional research leads. Fetch them only for a specific
  unresolved question; the remake need not await a survey of every project.

Local Poppler tools and the required `/opt/google/chrome/google-chrome` path
are present. Tesseract is not currently on PATH. The documented MAME/Apple2TS
setup can supply additional observations, but live emulator connectivity and
ROM availability must be rechecked when a scenario actually needs them.

## Evidence policy and bounded research

Create `docs/remake/behavior-matrix.md` with one row per meaningful rule/flow:
feature, source file + procedure/offset, manual page, input/state fixture,
observed outcome, confidence, browser test, and any intentional deviation.
Use explicit statuses: observed, source-derived, manual-only, proposed, blocked.
Recorded observation and source must refer to the supplied Apple II version;
when they disagree, reproduce the case before choosing a rule.

For each gameplay step, first resolve only the rules it needs. Start with source
and existing evidence, then one targeted emulator scenario; allow at most two
focused follow-up attempts before writing down the unresolved question and
its impact. Continue independent work. An unresolved core rule prevents that
feature's fidelity sign-off, but does not restart disk-wide archaeology.

Never assign collision, prices, quest meaning, or a clean starting state just
because bytes look plausible. Temporary development fixtures are explicitly
labeled and cannot become the release's new-game defaults. Do not describe
an approximate rule as recovered behavior.

## Architecture

Proposed layout, created incrementally rather than as empty scaffolding:

```text
remake/
  index.html
  styles/{base,game}.css
  js/
    main.js
    core/          # state, actions, clock, random source, scene transitions
    systems/       # movement, inventory, economy, travel, combat, colony
    scenes/        # title, ship, city, surface, pilotage, encounters
    render/        # Canvas renderer, SVG loading/cache, coordinate transforms
    ui/            # DOM windows, focus, controls, localized text
    platform/      # input, storage, audio
  data/            # normalized maps, items, world records, dialogue, defaults
  locales/{en,ko}.json
  assets/{svg,fonts}/
  tests/           # dependency-free browser runner and fixtures
  README.md
docs/remake/        # behavior, source mappings, decisions, validation receipts
tools/remake/       # optional authoring/export/validation tools
```

### State, content and simulation

- Keep serializable game state separate from DOM, Canvas, images and audio.
  It includes player condition/inventory, location, ship/pod state, cargo and
  warehouses, world/economy state, dialogue/quest flags, game time and RNG state.
- Route input through semantic actions. Rules validate and update state;
  rendering reads it. Scene changes do not reset the simulation.
- Use a controlled simulation clock independent of rendering frequency and
  an injectable seeded random source. Calibrate consequential timing and
  random distributions from evidence. Deterministic remake replays are not a
  claim that its RNG sequence matches the original.
- Pause appropriately on lost visibility/focus; document how time advances
  in menus, sleep, travel and combat. Avoid a background-tab time jump.
- Export normalized, stable-ID content with provenance back to source assets,
  records and procedures. Commit the outputs so the static app requires no
  Python, assembler, disk image, or regeneration step to run.
- Translate dialogue control records into explicit browser data/actions once
  their meanings are established. No generic p-code execution is required.

### Graphics and interaction

- Use a 640×480 logical composition inside a centered 4:3 viewport, uniformly
  fitted with letterboxing. Preserve a separate mapping for original screen
  coordinates; raw Apple II pixel dimensions alone are not the display ratio.
- Draw game scenes on Canvas 2D using externally loaded SVGs. Store SVG artwork
  in separate files, with no embedded raster images, SVG markup in HTML/CSS,
  or data-URL substitutes. Basic lines, cursors and effects can be Canvas paths.
- Start with faithful silhouettes and layout from the original live banks.
  Vectorize simple tiles/icons reproducibly; hand-refine ship/title artwork.
  Review palettes against color emulator references, not monochrome previews
  or the arbitrary numeric palette of map overviews.
- Keep collision and hit regions in explicit data, separate from decorative
  SVG paths. Use one shared transform for rendering and pointer coordinates;
  account for device pixel ratio without changing simulation coordinates.
- Put localized buttons, dialogue and editable text in DOM overlays within the
  same viewport. This supports focus and Korean input without baking text into
  art. Keep the original compact window composition and recognizable icons.
- Map primary press/hold/release to the relevant move/select behavior; provide
  explicit Back/Status actions and context-specific combat actions. Do not
  depend on right click or a two-finger gesture for essential touch operations.
- Avoid page scrollbars in ordinary gameplay. Paginate long dialogue/options
  inside the stage; permit bounded scrolling where necessary for readable
  help or accessibility instead of clipping text. Test portrait letterboxing.

### Localization, saves and sound

- Use stable text keys, named interpolation parameters and full sentences.
  Extract inline p-code strings as well as dictionary/messages/item names.
  Maintain an English/Korean glossary for locations, parts and game terms.
- Save IDs and values, never translated labels. Language changes preserve
  state; missing keys fall back to English and fail localization validation.
  Check Korean line breaks and input composition with the local font loaded.
- Use IndexedDB for four versioned save slots with transactional writes;
  localStorage is sufficient for preferences. Add JSON export/import so saves
  can move between origins and survive browser-storage loss. Validate before
  replacing state and retain the previous valid save after a failed write/import.
- Persist the clock, RNG and consequential transient state needed for a faithful
  resume, or restrict saving at explicitly documented safe boundaries. Test a
  fresh browser session, not only an in-memory load.
- Use native Web Audio for speaker-like effects after user activation. Source
  speaker routines and new reference captures inform effects; no sampled audio
  asset or existing audio-equivalence baseline has been established.

## Implementation sequence

Each step is a reviewable checkpoint. Split large steps into lettered substeps,
each with working behavior, appropriate checks, a progress entry and a commit.
Do not mark a step complete with core rules replaced by silent placeholders.
English/Korean text and relevant save fields are added with each feature.

| Step | Work and deliverables | Exit evidence / dependency |
| --- | --- | --- |
| R00 — Plan | This inventory, architecture, scope and initial history. | Complete at the planning commit. No app implementation claimed. |
| R01 — Behavior foundation | Build the behavior matrix, manual page index, semantic source map and discrepancy register. Trace new-game initialization and the colony-completion path early; identify their required state fields. Define the state/save schema and first ship scenario. | A supported fresh-game specification, or an explicit blocker; documented campaign requirements; source/observation-backed ship movement/status rules. Depends on R00. |
| R02 — Content and vector pipeline | Add minimal exporters for the ship, initial city, items, interaction geometry and text. Establish stable IDs/provenance; produce separate SVG ship, cursor, status icons and sample tiles. Vendor pinned Mulmaru and its license. | Exported counts/IDs check against source, representative SVGs visually checked against references, no raster-in-SVG or network fonts. Depends on R01; extend exporters with later features. |
| R03 — Browser foundation | Build the ESM entry point, asset loader, Canvas/DOM composition, viewport transforms, locale switching, input actions, scene/window handling and dependency-free test runner. Add localized title/settings and an asset inspection scene. | Required Chrome loads with no errors; 4:3 fit and matching hit positions at representative sizes; English/Korean render from local font. Depends on R02. |
| R04 — New game and persistence | Implement verified character creation/defaults, slot selection, new/resume/delete flows, storage validation, schema versioning, export/import and a fixed-seed development fixture. | Two new games do not inherit prior-player state; four slots remain independent; save/reload across a fresh session preserves state; corrupt/unsupported imports leave saves intact. Depends on R01/R03. |
| R05 — Playable ship | Implement movement/collision, airlock and reachable interaction points, status, inventory transfers, lockers, eating/rest and their time/condition changes. Add localized contextual help. | First playable milestone: create → explore ship → manipulate inventory/status → save → fresh reload and continue. Verify interaction reachability and state changes against targeted evidence. Depends on R04. |
| R06 — City and building exploration | Integrate live city tiles, runtime map composition/variants, ship-to-city transitions, doors/interiors, basic NPC interaction and the dialogue interpreter/actions needed here. | Leave and reenter ship/buildings without losing state; known tile/door locations behave correctly; a recorded dialogue branch works in both languages. Depends on R05. |
| R07 — Trading and banking | Implement shops, cash/system accounts, transfers, exchange quotes, buy/sell, warehouse ownership, cargo loading and capacity. Resolve price/stock update rules and relevant dialogue conditions. | Local trade loop reconciles cash, banks, stock, warehouse and cargo; insufficient funds/capacity cannot partially commit. Test manual-described bank-first purchases and local deposits against source/runtime. Depends on R06. |
| R08 — Engineering and ground transport | Implement equipment failures/replacement, repair/fuel services, ship readiness, pod boarding/departure, surface traversal and return. Resolve walkable/drivable terrain and ship/pod/cargo ownership. | A damaged ship can be serviced with proper costs; pod can reach a supported destination and return with inventory intact; invalid terrain and transitions are rejected. Depends on R07. |
| R09 — Flight and regional world | Integrate verified system/planet/city associations and full live map dataset. Implement navigation scales, destination confirmation/cancellation, launch, orbit, in-system travel, warp, landing, fuel/charge/time and failure paths. | Travel between two systems, land, trade, return and reload with consistent location/resources. Validate all content references and reachability of required campaign destinations. Depends on R08. |
| R10 — Encounters and combat | Complete dialogue predicates/actions, ground threats, pirate encounters, negotiation/evasion, tactical controls, weapons/shields/damage, cargo jettison and defeat/recovery. | Deterministic fixtures cover avoid/fight/lose outcomes; at least one ground and one space encounter has original-game evidence; timing is independent of display refresh. Depends on R09. |
| R11 — Colony campaign | Implement the complete verified contract progression: finding Banville, goods requirements/deliveries, cryogen discovery/transport, staged updates and completion. Complete any remaining campaign-critical content. | Fresh-game-to-ending playthrough using ordinary controls and legitimate resource transactions; duplicate deliveries cannot advance twice; save/resume during progression preserves requirements. Depends on R07–R10 and R01's early campaign research. |
| R12 — Presentation and audio | Complete SVG coverage for reachable content, source-informed sound effects, transition polish, controls/help, English/Korean editorial pass and small-viewport handling. Add hosted offline caching only if chosen. | No untranslated reachable strings/missing glyphs, missing art, external runtime requests or inaccessible essential controls; audio mute/activation works. Depends on R11; incremental polish is allowed earlier. |
| R13 — Release validation | Reproduce the core playthroughs, validate all static references and save migrations, document intentional differences and run instructions, and capture Chrome screenshots/behavior receipts. | All acceptance criteria below met and no unacknowledged core-rule blockers. Update history and commit the final checkpoint. Depends on R12. |

Critical path: behavior/new-game specification → content/browser foundation →
ship → city/economy → engineering/pod → travel → encounters → full campaign.
Research for a later feature can proceed when earlier evidence points to it,
but the first playable milestone should not wait for exhaustive semantic naming
of all reconstructed procedures. Schedule estimates should follow R01/R05,
when the largest semantic risks have been measured.

Checkpoint R04d (2026-09-28) adds tested initialization primitives for six ship
equipment groups, 12 system positions/balances and 18 orbital angles, driven by a
source-derived serializable RNG. Native sim65 comparisons and the independent
clean-character capture validate bounded parts of this state. These helpers are
not yet a complete campaign constructor and are not wired into the walkthrough.
R04c's four ship checkpoints and R04a's character drafts remain independent.
R04/R05 still need commodity/city record semantics, remaining global/location
fields, an explicit seed lifecycle, campaign assembly, ship systems and exits.
See `docs/remake/initialization.md` for source offsets and remaining boundaries.

Checkpoint R04e (2026-09-28) adds 57 ordinary markets, the colony's initial market,
four-slot warehouses and 17 distinct cryogen placements, plus ordinary market
first-visit/weekly refresh. Named templates, city memberships and nine colony
recipes match the independent clean-character capture. These are tested campaign
foundations; colony transactions and gameplay integration remain pending. Next:
remaining global/location fields, seed lifecycle and campaign assembly, then
engineering and ship exits. See `docs/remake/economy-initialization.md`.

Checkpoint R04f (2026-09-28) combines the verified primitives into a deterministic
starting-state constructor with an explicit browser recipe. It distinguishes
saved gameplay RNG from utility generation state, adds starting cash and named
player/ship locations, and validates independent replay. This is not yet a complete
campaign save or live New Game action. Next: remaining ship resources/modes and
location-copy semantics, campaign save validation and character-to-ship integration.
See `docs/remake/campaign-start.md` for source offsets and adaptation choices.

Checkpoint R04g (2026-09-28) adds ship resources, destination/pod locations and
attachment, corrects the omitted hull RNG draw (creation recipe2), and implements
four transactional campaign save slots for `landed-ship-1`. This scope preserves
the creation record plus active ship walking/inventory/condition/time; later
economy/travel/machinery progress requires a schema update. Next: character-to-ship
integration, explicit seed selection and campaign save UI. See
`docs/remake/ship-resources.md` and `campaign-saves.md` for evidence and limits.

Checkpoint R04h (2026-09-28) connects character creation, optional explicit seeds,
the landed ship runtime and four campaign slots. New games and loaded games enter
paused; drafts and preview checkpoints remain separate. English/Korean UI and
storage/recovery flows are verified. R04/R05 remain partial: next trace and expose
source-backed equipment inspection and engineering interactions, extending active
state/save scope before allowing resource mutation, then implement ship exits.
Travel, trade and colony progression remain later milestones. See
`docs/remake/campaign-ui.md` and `campaign-ui-validation.md`.

## Validation and completion

Use `/opt/google/chrome/google-chrome` in development mode with an isolated
profile. A suggested local serving command is:

```sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory remake
```

The server only serves static files. It is development tooling, not an app
backend. Browser automation must select the required Chrome executable;
checks against a bundled alternative do not replace that run.

Maintain meaningful tests for state transitions and failure cases: movement
boundaries, item conservation, atomic purchases, fuel consumption, combat
outcomes, dialogue branches, quest idempotency and save/reload. Keep pure-rule
tests separate from DOM input/render smoke checks. Seeded fixtures and action
logs make failures reproducible; new gameplay reference captures use disposable
original/rebuilt disks and record their initial state.

Compare rules, coordinates, transactions and transitions with original-game
evidence. Use screenshots for layout/art review; vector graphics and Korean
text will intentionally differ from Apple II pixels. Existing reconstruction
tests only need rerunning if shared reconstruction code/assets change.

Release acceptance:

- A fresh character can complete the full colony contract through supported
  gameplay. Ship, city, surface, travel, trade, survival, encounters and combat
  are functional; critical outcomes have evidence or explicit approved deviations.
- All supported live world/city records and reachable dialogue/content are
  integrated with valid IDs. Stored demo/retained variants are mapped separately.
- Four save slots, fresh-session resume, import/export and version handling work
  across the major scene types and campaign stages; failures preserve valid data.
- English and Korean cover every reachable player-facing flow, including errors,
  saves, help and generated messages; switching locale preserves progress.
- Separate SVG files supply game artwork; local Mulmaru files supply text.
  A clean copy of `remake/` runs independently of the repository's other folders,
  build tools, disk images and external network services.
- At 640×480, 1280×720, 1920×1080 and a representative portrait viewport,
  the stage keeps 4:3 and essential controls remain visible/usable without page
  scrolling. Test high-DPI rendering and coordinate mapping. Very small windows
  may use paginated/bounded panels; do not shrink text until it is unreadable.
- Chrome completes startup, localization, a trade/travel/encounter loop,
  save/reload and a full campaign run without uncaught errors or missing resources.
  No broad legacy-browser compatibility program is required.
- Record performance on the actual test machine; target smooth 60 Hz rendering
  for normal scenes while keeping simulation results independent of frame rate.
- `PROGRESS-REMAKE.md` records each completed step, evidence, deviations and
  next action; each implementation checkpoint is committed separately.

Optional follow-ups after completion: original disk-save compatibility, physical
gamepad support, installable/offline-hosted PWA, additional locales, and deeper
audio/timing fidelity. These do not displace the complete core game.
