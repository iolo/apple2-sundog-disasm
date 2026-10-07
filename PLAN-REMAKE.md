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
| R06 — City and building exploration **(complete, R06s)** | Integrate live city tiles, runtime map composition/variants, ship-to-city transitions, doors/interiors, basic NPC interaction and the dialogue interpreter/actions needed here. | Leave and reenter ship/buildings without losing state; known tile/door locations behave correctly; a recorded dialogue branch works in both languages. Depends on R05. |
| R07 — Trading and banking **(complete, R07h)** | Implement shops, cash/system accounts, transfers, exchange quotes, buy/sell, warehouse ownership, cargo loading and capacity. Resolve price/stock update rules and relevant dialogue conditions. | Local trade loop reconciles cash, banks, stock, warehouse and cargo; insufficient funds/capacity cannot partially commit. Test manual-described bank-first purchases and local deposits against source/runtime. Depends on R06. |
| R08 — Engineering and ground transport **(complete, R08m)** | Implement equipment failures/replacement, repair/fuel services, ship readiness, pod boarding/departure, surface traversal and return. Resolve walkable/drivable terrain and ship/pod/cargo ownership. | A damaged ship can be serviced with proper costs; pod can reach a supported destination and return with inventory intact; invalid terrain and transitions are rejected. Depends on R07. |
| R09 — Flight and regional world **(complete, R09f)** | Integrate verified system/planet/city associations and full live map dataset. Implement navigation scales, destination confirmation/cancellation, launch, orbit, in-system travel, warp, landing, fuel/charge/time and failure paths. | Travel between two systems, land, trade, return and reload with consistent location/resources. Validate all content references and reachability of required campaign destinations. Depends on R08. |
| R10 — Encounters and combat **(in progress, R10d)** | Complete dialogue predicates/actions, ground threats, pirate encounters, negotiation/evasion, tactical controls, weapons/shields/damage, cargo jettison and defeat/recovery. | Deterministic fixtures cover avoid/fight/lose outcomes; at least one ground and one space encounter has original-game evidence; timing is independent of display refresh. Depends on R09. |
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

Checkpoint R05e (2026-09-29) exposes equipment inspection at all six engineering
bays, with source-mapped three-system frame cycling, installed/spare component
identification and performance readings. Campaign creation data remains immutable;
inspection leaves the existing save scope unchanged. Next: trace complete component
transfer/recalculation and timing rules, add active equipment and save validation,
then enable replacement. Ship exits and the later city/trade milestones remain
pending. See `docs/remake/engineering.md`.

Checkpoint R05f (2026-09-29) implements compatible carried/installed component
exchanges and source-derived performance recalculation. Corrected the former
"spares" label: bytes20–23 are fixed socket requirements. Campaign version2 adds
active equipment and validates/upgrades version1 without automatic slot writes.
Next: ship exits/city scene transitions on the main R06 path; retain the remaining
encoded repair, fuel/services and power controls for their R08/R09 rules. Full
navigation/trade/colony gameplay is still pending. See
`docs/remake/component-exchange.md`.

Checkpoint R06a (2026-09-29) implements ordinary-city background composition and
an English/Korean city inspector alongside the stored-layout preview. All57 named
cities use the source's private RNG sequence, 40×24 buffer and automatic two-bank
selection. The 10×6 camera wraps horizontally and stays within valid rows;
records58–60 remain stored-only. Campaign state/save scope is unchanged. Next:
trace collision and exterior ship/pod overlays, then implement airlock exit/reentry
with active scene/location persistence. Doors, NPCs and dialogue remain later R06
work. See `docs/remake/city-maps.md`.

Checkpoint R06b (2026-09-29) enables landed foot-airlock exit/reentry and bounded
Drahew walking with source-derived city glyphs, pattern9 collision and the attached
ship silhouette. Version3 saves retain the active scene and reachable exterior
position, upgrading valid version1/2 saves without automatic writes. Equipment,
inventory, condition and time survive transitions. R06 remains partial: next trace
building entrances/interiors and the NPC/dialogue interpreter actions they need.
Surface travel, pod driving and encounters remain out of scope for this checkpoint.
See `docs/remake/city-walking.md`.

Checkpoint R06c (2026-09-29) ports the source city-door footprints and enables
bank entry/inquiry/return with localized, accessible service UI. Version4 saves
preserve visits only at reachable bank doors and upgrade valid version1/2/3
records. The door table and existing interior-layout assets are documented in
`docs/remake/city-buildings.md`. R06 remains partial: next port scene5 layouts,
fixtures, collision/exit gates and NPC/dialogue state. Financial transactions
remain R07 work and require active economy state.

Checkpoint R06d (2026-09-29) enables walking interiors for city types9/10 using
eight source layouts, separate room SVGs/player glyph, full indoor collision and
doorway exit. Version5 saves retain both street and room positions, upgrading
versions1–4. Source adaptations and remaining NPC/fixture work are documented in
`docs/remake/building-interiors.md`. R06 remains partial: next add NPC generation,
interaction/dialogue and the special fixtures for types8/11. Bank transactions
remain R07 work.

Checkpoint R06e (2026-09-29) adds the source initial population for those eight
rooms: visitors, counter occupant, glyph23 collision overlays and continuing
saved gameplay RNG. Version6 saves regenerate stationary occupants from the
entry seed and upgrade versions1–5; legacy interiors remain empty until re-entry.
The unresolved no-visitor reversed-range fallback rejects entry atomically.
See `docs/remake/room-occupants.md` for source references and the explicit limits.
Next port NPC movement/activity/counter following, then dialogue and remaining
fixture-dependent interiors. R06 remains partial; transactions remain R07.

Checkpoint R06f (2026-09-29) adds visitor arrivals/departures, collision-aware
movement, blocked-route recovery and counter following in the eight supported
rooms. Version7 saves retain live actor targets, queue/mover references and RNG;
versions1–6 migrate under their original rules. Player and NPC movement share an
explicit50ms browser step. Counter target references survive actor compaction.
See `docs/remake/room-traffic.md` for source scope and adaptations. Next implement
player counter interactions/dialogue and the remaining fixture-dependent room
types. R06 remains partial; financial transactions remain R07.

Checkpoint R06g (2026-09-29) exports all96 classified dialogue records and adds
pure bank lookup, random/conditional/mood selection and transition overrides.
Source tracing identifies selector21's fallback messages and preserves random
reuse and false-predicate overrides. The normalized catalogue round-trips all
1,175 original script/table bytes;114 browser rule groups pass. See
`docs/remake/dialogue-selection.md`. This foundation does not yet enable live
counter dialogue. Next implement text expansion, dialogue setup and predicates,
then controls/actions, player queue/return behavior and persisted conversation
state. Version7 campaign saves and R07 transaction scope remain unchanged.

Checkpoint R06h (2026-09-30) implements source English dialogue text expansion:
all 165 messages, nested dictionary alternatives, fixed captions, setup strings,
mood/speaker forms and random place names. Bank98 retains the prior supplement;
RNG cycles and invalid expansions fail explicitly. Source text round-trips to
the classified assets, and 125 Chrome rule groups pass. See
`docs/remake/dialogue-text.md`. Next implement dialogue setup and predicates,
controls/actions, player queue/return persistence and localized conversation
presentation. Live dialogue and R07 transactions remain pending.

Checkpoint R06i (2026-09-30) adds fresh counter setup, all byte-predicate families
and negotiation valuation refresh. It preserves same-city flags, source RNG
draws, luck reduction and internal state changes without committing campaign
transactions. Twelve system defaults match the clean-character capture;
139 Chrome rule groups pass. See `docs/remake/dialogue-state.md`. Next implement
packed controls, actions and built-in transitions, then the conversation runner,
player queue/return persistence and localized UI. Saves remain version7.

Checkpoint R06j (2026-09-30) adds packed controls, all eight actions, built-in
transitions and a pure conversation runner. Both counter roots execute source
greetings, quotes, information branches and exits with continuing RNG. Record
ordering and predicate-dependent target writes have regression coverage;
152 Chrome rule groups pass. See `docs/remake/dialogue-runner.md`. Next integrate
player queue/return state, conversation persistence and English/Korean UI.
Inventory transfers and financial transactions remain R07; live conversations
are not yet enabled and saves remain version7.

Checkpoint R06k (2026-09-30) connects player service requests to staff approach,
counter dialogue and return in a pure room controller. The player takes source
slot1 priority; mood/greeting state survives return and later requests. Queue
cancellation/dispatch removes the player's count exactly once as a documented
browser repair. All eight layouts across three seeds pass, with163 Chrome rule
groups total. See `docs/remake/room-counter.md`. Next add durable campaign dialogue
fields and versioned conversation validation, then English/Korean controls and
presentation. The live visitor-only path and version7 saves retain their existing
contract. Inventory transfers and transactions remain R07.

Checkpoint R06l (2026-09-30) enables live counter dialogue in the eight type9/10
rooms, with English source text, Korean templates, information/item quotes,
player queue/return and version8 campaign saves. Open conversations save their
starting RNG and bounded input history, then replay during validation/load.
169 Chrome rule groups and19 conversation UI checks pass, including a recorded
English/Korean branch and mid-conversation reload. See `docs/remake/dialogue-ui.md`.
R06 remains active: `docs/remake/r06-completion.md` tracks remaining type8/type11
interiors, their interaction coverage, special city composition review and final
cross-scene validation. Purchases and transfers retain R07 scope.

Checkpoint R06m (2026-09-30) exports the five remaining foot-interior fixture
layouts and adds independently tested lodging door geometry. Native modulo
tracing resolves the empty-population entry failure: an explicit browser repair
normalizes fallback X endpoints while preserving two RNG draws. Staff-only
entry, dialogue, IndexedDB reload, exit and reentry pass in both live counter
classes. See `docs/remake/room-fixtures.md`. Tavern seating and lodging interaction
still need live integration; R06 remains active.

Checkpoint R06n (2026-09-30) enables type11 lodging: clerk approach, kind23
dialogue, localized quotes, payment, random room assignment and doors that reopen
from inside. Version9 stores active cash and rental/door state, migrates version8
conversations and supports saves behind a closed bedroom door. Lodging debits are
included here because they unlock R06 rooms; other trading/banking remains R07.
179 Chrome rule groups,27 lodging UI checks,19 existing dialogue checks,102 room
and28 bank regression checks pass. See `docs/remake/lodging.md`. R06 still needs tavern
interaction, special city composition review and final cross-scene validation.

Checkpoint R06o (2026-09-30) adds the tavern traffic/controller foundation:
six-seat reservations, counter/seat retargeting, player sitting, source21/22
contact dispatch and both NPC return paths through the secondary mover. Derived
reservations and repaired queue/mover references prevent orphaned actors and
seats. 189 Chrome rule groups pass, including48,000 tavern simulation ticks and
JSON replay. See `docs/remake/tavern-traffic.md`. Type8 live entry, dialogue,
localization and campaign saves remain next; this does not complete R06.

Checkpoint R06p (2026-09-30) enables all four tavern layouts through type8 doors.
Bartender12 and visitor21/22 dialogue include social branches, matched jokes,
quotes, adjustable tips and actual-speaker return.92 Korean templates preserve
chosen place names without extra RNG. Version10 saves replay seated, moving,
mid-joke and mid-offer visits and validate versions1–9 before migration.
196 Chrome rule groups and36 tavern UI checks pass, along with102 room,27 lodging,
19 dialogue,28 bank and44 city regressions. See `docs/remake/tavern-dialogue.md`.
R06 still needs special city composition and service-dispatch review, followed
by its final completion audit; food/item trading retains R07 ownership.

## Validation and completion

Checkpoint R10d (2026-10-07) records a prepared original-game city encounter
from a fresh owned MAME0.285/Apple IIe boot on copied disks. Declared city/foot
fields and seed10804 enter the unmodified Game21 gate/chase/catch; kind16 then
initializes six Game17 actors. All six packed records, the carried weapon swap
and final native RNG match the browser core in29 draws. Ten hashed raw captures
and a receipt-derived regression fixture preserve the comparison. All381 Chrome
rule groups pass without failures/page errors. See
`docs/remake/ground-encounter-reference.md`. Both original-game encounter evidence
gates now have valid controlled observations. Live threat production/chasing,
enemy dialogue and campaign/save/UI integration, cargo loss, defeat/recovery,
ordinary avoid/fight/lose and live timing acceptance remain R10 requirements.
The eligible scene3 is the city map; the scene4 world surface still consumes the
eager gate RNG but does not satisfy the encounter scene predicate. Version23
remains current; neither isolated cores nor native captures complete R10.

Checkpoint R10c (2026-10-07) adds the source Game17 ground-combat session:
actor placement, player/NPC movement and history, laser/scatter volleys, personal
shield charges, knock-out/robbery, surrender/cancellation, NPC recovery and
dialogue suspension. Twenty new rule groups include source byte/RNG vectors,
avoid/fight/lose outcomes, glyph collision/friendly fire and equal30/60/144 Hz
continuations with mid-tick JSON reload. All380 Chrome rule groups pass with
no page errors;21 exporter tests,170 artifacts and584 source strings verify.
See `docs/remake/ground-combat.md` and `r10-completion.md` for source scope and
the full original requirement audit. R10 remains in progress: prepared ground
threat/chase and native evidence, encounter dialogue, campaign/save/UI ownership,
tactical controls, cargo loss and defeat/recovery acceptance remain. Live saves
stay version23 until integration; no live encounter completion is claimed.

Checkpoint R10b (2026-10-07) captures an original-game space contact and enemy
Comm dialogue in owned MAME0.285/Apple IIe on copied media. Declared RAM setup,
normal joystick input, screenshots and native before/setup/after receipts are
retained with hashes. Scene9, workspace kind9 and enemy level2 verify. Source
disks remain unchanged; input overrides and the owned emulator are released.
The bootstrap/ROM wrapper verifies. See `docs/remake/encounter-reference.md`.
Only the space-observation portion of R10's evidence gate is covered: direct
ground scene injection produced an invalid window and is excluded. Prepared
ground entry, native damage, live campaign/save/UI integration and full R10
avoid/fight/lose acceptance remain. The R10a360-group rule receipt remains current.

Checkpoint R10a (2026-10-07) adds isolated source ship encounter, motion, fire,
damage and jettison rules. Jump-table tracing preserves attacks during movement
cooldown/aim/retreat, eager RNG on every selected jettison slot, cryogen encounter
eligibility, signed16 strength overflow, repeated hull penetration and the
zero-output record-pointer defeat. Fifteen new deterministic groups compare RNG
continuation with an independent byte/carry oracle. All360 browser rule groups
pass without page errors. See `docs/remake/ship-combat.md` and
`r10a-rules-validation.json`. R10 remains active: live campaign/save/UI integration,
ground threats/combat, enemy dialogue/negotiation, bounty/wreck/loss/recovery,
original-game ground/space evidence and avoid/fight/lose acceptance remain.

Checkpoint R09f (2026-10-07) closes R09. The final ordinary-play journey buys,
transports and sells cargo across two systems, refuels abroad and returns home
through repeated reloads. All 345 rule groups and 667 UI checks pass in Chrome
154.0.8037.97; 21 exporter tests, 169 deterministic artifacts and 584 classified
source-string records verify. Coverage includes all 18 worlds, all 57 ordinary
city landings plus Banville, independent economies and pods, version23 flight
saves, historical migration and affected R08 services/ground/room regressions.
See `docs/remake/r09-completion.md` and `r09-validation-summary.json` for the
requirement audit, current receipts and explicit timing/evidence boundaries.
Next: R10 encounters and combat; colony contract progression remains R11.

Checkpoint R09e (2026-10-07) closes the source audit: corrected left-shift flight
duration and strict engine comparison, generated-terrain colony validation,
actual regional counter coordinates and historical quote preservation. All345
Chrome groups pass, including all57 ordinary cities plus Banville.21 exporter
tests/169 artifacts/584 strings verify. Final UI/regressions and audit remain.

Checkpoint R09d (2026-10-07) enables live version23, localized navigation and
regional services.44 navigation checks cover three scales/four viewports/both
locales. A64-check ordinary-play two-system land/trade/refuel/return/reload
journey passes, including gravity failure and profitable cargo settlement.
Affected R08 regressions, content coverage and the completion audit remain.

Checkpoint R09c (2026-10-07) validates opt-in version23 regional-flight saves,
all18 capital domains and exact mid-flight reload continuation. Historical
versions1–22 validate before migration. All340 Chrome rule groups pass. The
live loader still uses22; navigation/UI and ordinary-play acceptance remain.

Checkpoint R09b (2026-10-07) adds source flight rules and capital landing exports.
All335 Chrome rule groups,21 exporter tests and169 deterministic artifacts pass.
The planetary overlay's resumable5/20-minute browser timing is an explicit
adaptation. See `docs/remake/flight.md`. Regional saves/live navigation and the
two-system ordinary-play acceptance remain required; live saves remain version22.

Checkpoint R09a (2026-10-07) adds regional membership/economic ownership,
3D source jump distance and charge requirements, destination service context,
origin-aware cargo settlement and global cryogen conservation.325 rule groups
pass in Chrome. Live app/saves remain version22; flight rules, regional save/UI
integration and the two-system acceptance journey remain required for R09.
See `docs/remake/regional-world.md`.

Checkpoint R08m (2026-10-03) closes R08. A74-check fresh-character journey combines
component replacement, exact-cost hull/fuel services, working machinery, two
purchased cargo lots, surface parking/foot retrieval, Obburg arrival and loaded
return with repeated full-state reloads.319 rule groups additionally cover all
six starting-world city/colony entry/parking/return/save paths. The closing
inventory records 1,070 UI checks across 23 runs, including power/failure, trading,
rooms, old-save migration and English/Korean surface help.20 exporter tests,
168 deterministic artifacts and 584 source-string records verify. See
`docs/remake/r08-completion.md` for the requirement audit and explicit boundaries.
Next: R09 regional navigation/flight/landing and other-city economy.

Checkpoint R08l (2026-10-03) connects source ground camera/geometry, surface
rendering/input, independent parking and city entry to the live UI. Version22
is active.52 fresh-character UI checks prove purchased cargo through surface
parking, foot ship visits, another source city and loaded return, with reloads
and both locales.318 rule groups cover geometry, historical saves and remote
service guards. City parking42, depot61, rooms102 and outer-street services8 checks also pass. See
`docs/remake/surface-travel.md`. The combined engineering/service/ground
acceptance journey and final R08 requirement audit remain open.

Checkpoint R08k (2026-10-03) prepares version22`landed-ground-1` persistence for
ground-aware callers. Actual terrain/domain/camera/occupancy validation preserves
remote cargo and source arrival exceptions, rejects unsupported remote services,
and validates versions1–21 historically before migration.317 rule groups pass,
including cross-city/foot-retrieval round trips, every old schema, malformed
imports and immediate boarding recovery at an overlapping source arrival.
The live UI remains version21 until the next controls/rendering integration;
the full normal-control surface and combined acceptance journeys remain required.

Checkpoint R08j (2026-10-03) adds source camera hysteresis, expanded city geometry
and explicit player/pod city-or-surface domains. Ground reducers preserve remote
ship/cargo ownership, commit initial colony RNG once, and support surface parking,
foot city visits, boarding and return.313 rule groups include collision-routed
city01→city02→city01 and parked-pod retrieval journeys. Surface row wrapping is
an explicit browser adaptation; see `docs/remake/surface-travel.md`. Live controls,
versioned persistence/migration and the combined R08 acceptance journey remain open.

Checkpoint R08i (2026-10-03) exports original surface tile/glyph pixels and57
ordinary city coordinates, composes all18 maps with private terrain RNG and
city overlays, and implements separate colony placement/revisit RNG ownership.
The surface core uses source pixel collision, seam wrapping and strict city
entry/exit coordinate rules.308 browser rule groups,20 exporter tests and166
deterministic artifacts pass. See `docs/remake/surface-travel.md` for the original
overlapping arrival anchors and required live integration. The surface scene,
cross-domain ownership/saves, return journey and combined R08 audit remain open.

Checkpoint R08h (2026-10-03) connects independent parked pod/player state,
source collision/exit/boarding rules and version21 saves. Foot city, room,
service and ship visits preserve the unattended pod; remote cargo loading and
auxiliary purchase are rejected. The absent-pod ship uses its original section
artwork/collision.302 rule groups and205 UI checks pass:42 fresh-character parking,
61 depot/auxiliary/power and102 room regression checks. Native pod-room exit/drive
choices are represented by explicit buttons; see `docs/remake/parked-pod.md`.
Surface traversal/return and the combined R08 acceptance audit remain required.

Checkpoint R08g (2026-10-03) traces independent native pod location, city parking
artwork, boarding bounds and foot-exit placement. The geometry core preserves
visible-glyph XOR/pattern9 collision and source-ordered expanding exit search.
297 rule groups pass, including actual city walking away/return and boarding
recovery at a constrained parking point. See `docs/remake/parked-pod.md`.
Live parking ownership, controls and saves remain pending; version20 is unchanged.
Surface travel and the combined R08 acceptance gate remain required.

Checkpoint R08f (2026-10-03) connects landed gun/shield/cloaker controls, equipment
dependencies and auxiliary consumption to one aboard power/survival clock.
Version20 preserves phase and active resources; versions1–19 retain historical
validation before migration.293 rule groups and139 UI checks pass, including a
fresh-character depot/auxiliary purchase, docking, engineering walk and running
systems journey. Source control/cadence adaptations are explicit in
`docs/remake/ship-power.md`. Independent pod parking/boarding, surface traversal
and the combined acceptance audit remain required for R08.

Checkpoint R08e (2026-10-03) implements the source power-phase core: odd-phase
guns, shield steps/maintenance, cloaker cost, warp RNG/charge, refueling order and
fuel-exhaustion cleanup. It distinguishes machinery's add255-at-zero auxiliary
consumer from Game15's set255-below5 docking refill. The latter is now live and
verified through a fresh-character purchase/return/reload journey. General power
controls and phase/clock/save integration remain pending; version19 is unchanged.
See `docs/remake/ship-power.md`. Parked pod ownership, surface traversal and the
full R08 acceptance gate remain required.

Checkpoint R08d (2026-10-03) connects live faulty-component installation, delayed
failure and working replacement to reachable engineering bays. Version19 preserves
the pending byte/offset and temporary output, while versions1–18 retain historical
validation. The panel displays hull/fuel/offline units and provides Saves. Updates
use a documented250ms presentation cadence; pending moves wait, and frame entry
canonicalizes the native stale output cache.278 rule groups pass. The faulty-part
UI journey uses a declared carried fixture; ordinary current-city acquisition is
not proven. Fresh-character replacement and depot regression journeys also pass.
See `docs/remake/equipment-failures.md` and the progress receipts. R08 still needs
active machinery/dependencies/auxiliary consumption, parked pod boarding and
surface traversal/return, followed by the combined acceptance audit.

Checkpoint R08c (2026-10-03) implements the source encoded-component failure
lifecycle and system dependency cleanup as an isolated core. Source tracing
corrects the earlier delayed-repair interpretation: Game14 burns faulty parts
out; working replacements restore output. Tests connect the existing trader
appraisal producer to this lifecycle and cover eager shunt propagation RNG.
Version18 and live engineering remain unchanged pending fault/update/save
integration. See `docs/remake/equipment-failures.md` and the full R08 audit.

Checkpoint R08b (2026-10-03) connects active ship hull/fuel, reachable foot/pod
depot visits and confirmed localized repair/refuel/auxiliary purchases. Version18
persists resources and world-origin auxiliary cargo, including warehouse loading
and loaded docking, while preserving historical migration restrictions. The
fresh-character depot journey and current rule/regression receipts are documented
in `docs/remake/depot-services.md`. Next: encoded component damage/repair and
readiness, independent pod parking/boarding, then surface traversal/return.
The full R08 requirement audit remains in progress.

Checkpoint R08a (2026-10-03) adds source depot pricing and atomic hull repair,
refueling and auxiliary fuel operations as an isolated service core. Source
tracing distinguishes hull from component repairs, accepts exact depot funds,
and resolves auxiliary fuel's world-origin field. Active resource/depot UI and
save integration are next; all remaining R08 requirements are tracked in
`docs/remake/r08-completion.md`. See `docs/remake/depot-services.md`.

Checkpoint R07h (2026-10-01) enables bartender Buy/Sell referrals, source visitor
seat targeting, kind17 conversations and exact slot handover. Version17 persists
requests and encoded trader items while preserving all historical replay gates.
Source appraisal supports charged item values above one byte without changing
the actual transferred byte.252 rule groups,368 browser UI checks,19 exporter
tests and165 deterministic artifacts pass. R07 is complete; requirement evidence
and explicit boundaries are in `docs/remake/r07-completion.md`. Next: R08
engineering and ground transport. See `docs/remake/trader-matching.md` for the
matching lifecycle and version17 migration.

Earlier checkpoint notes below retain their historical status.

Checkpoint R07g (2026-10-01) connects local pod driving, cargo entrance access,
Store/Fetch/Swap and loaded docking to active campaign state. Version16 owns pod
position/orientation and two cargo slots, including them in wealth and cryogen
conservation. See `docs/remake/pod-cargo.md`. Bartender trader matching and the
final R07 completion audit remain; broader transport stays R08/R09.

Checkpoint R07f (2026-10-01) enables source visitor purchases and personal-item
sales with explicit slot confirmation. Charged bytes leave the selected slot;
cash, inventory, speaker return and gross sale proceeds commit together.
Version15 saves replay pending transfers and migrate versions1–14 only after
historical validation.242 rule groups and34 new UI checks pass. See
`docs/remake/personal-trading.md`. Bartender matching remains gated.
Next connect the cargo core to minimal pod movement/entry, active cargo saves
and loading controls; R07 remains in progress.

Checkpoint R07e (2026-10-01) implements the isolated cargo-loading core:
four warehouse/two pod slots, first-empty Store/Fetch, occupied-slot Swap,
capacity failures and complete lot conservation. Live exchange lot validation
shares the new validator; version14 saves and foot access remain unchanged.
The ship Cargo display reads the same pod manifest, not a second hold.
See `docs/remake/cargo-loading.md` and `personal-item-resale.md`.

The resale audit distinguishes a direct seated-visitor Sell path from bartender
trader matching; ordinary shops do not switch to selling mode. R07f implements
bounded visitor trade and sale-income save accounting. Cargo integration now
needs minimal pod departure/arrival and exchange entry from R08, an active pod
save boundary and loading controls. Pull these transport prerequisites forward
for the R07 loop; do not require all of R08 or invent remote pod loading.

Checkpoint R07d (2026-10-01) enables cash-paid shop/equipment and bartender
food/ale purchases into empty carried slots. Explicit slot confirmation preserves
source prices, exact-cash acceptance and charged item bytes. Version14 purchase
replay survives saves before/after transfers and commits cash/items together on
conversation return. Prior versions reject injected purchase/food inputs.
See `docs/remake/shop-purchases.md`. Personal-item resale and cargo loading remain
R07 work; visitor trade matching remains gated.

Checkpoint R07c (2026-10-01) enables local foot exchange purchases and warehouse
sales, bank-first payments, source stock reductions and atomic offer/RNG updates.
Version13 persists local markets, four warehouse slots and quote bases while
protecting creation data and initial cryogens.222 Chrome rule groups and the
exchange, banking, service and full exploration UI regressions pass. Both
languages fit five viewports. See `docs/remake/exchange-trading.md` for source
rules and explicit stable-review/per-confirmation settlement adaptations.
R07 remains in progress: shop item/food transactions and cargo loading remain.

Checkpoint R07b (2026-10-01) implements ordinary exchange prices, origin-based
resale ceilings, eight entry offers and a staged visit combining market refresh
with continuing RNG. Static pricing/geography fields match the existing clean
character capture.215 Chrome rule groups,19 exporter tests and160 artifact checks
pass. See `docs/remake/exchange-quotes.md`. This is a core-rule checkpoint;
version12 saves and the exchange preview remain unchanged. Next: active market,
offer and warehouse state, then atomic payment/stock/cargo transactions.

Checkpoint R07a (2026-10-01) enables deposits, withdrawals and inter-system
transfers using source amount increments, ALL and CLEAR. Version12 adds active
system accounts, preserves a single carried-cash value, and validates versions1–11
before migration. Atomic operations reject insufficient funds and overflow;
cancelled drafts change no balances.207 Chrome rule groups and44 banking UI checks
pass, plus bank/lodging/tavern/dialogue and the full R06 route regressions.
See `docs/remake/banking.md` and `r07-completion.md`. R07 remains in progress:
next trace exchange payment/quote/stock rules and introduce active market and
warehouse state before enabling commodity purchases or cargo transfers.

Checkpoint R06s (2026-09-30) completes R06. A fresh campaign follows a continuous
558-step route through all eight building classes and back aboard, including
fresh-page save/load, both languages and reentry at every visit.200 rule groups
and423 final route/UI checks pass, alongside the earlier120 colony inspector
checks,18 exporter tests and159 artifact checks. The requirement-by-requirement
audit is `docs/remake/r06-completion.md`; receipts are `r06-journey-validation.json`
and `r06-final-*.json`. Saves are version11. Next: R07 trading/banking, beginning
with active economy state, source transaction rules and atomic conservation tests.
The checkpoint notes below retain their historical partial statuses.

Checkpoint R06r (2026-09-30) resolves service-door classification and enables
read-only TransStation, depot and exchange visits. All classified foot doors now
enter the proper scene class; version11 saves validate their exact reachable door.
200 Chrome rule groups and77 service checks pass. See `docs/remake/city-services.md`
for source dispatch and later transaction ownership. The final cross-scene route
and regression audit remain before R06 can be marked complete.

Checkpoint R06q (2026-09-30) adds source-derived colony clipping and Banville's
ten-phase inspector. Independent references cover57 ordinary and11 colony maps,
including clamped progress;198 Chrome rule groups and120 inspector checks pass.
Records58/59 are reserved dummy layouts. Preview phase changes cannot affect
campaign progress or RNG, and saves remain version10. See
`docs/remake/colony-maps.md`. R06 still needs service-dispatch review and the final
cross-scene audit; travel and colony progression remain R09/R11.

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
