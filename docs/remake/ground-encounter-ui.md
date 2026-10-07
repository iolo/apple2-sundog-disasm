# Live ground encounters — R10h

The live asset loader now supplies both source ground encounter datasets and
enables campaign version24 `ground-encounters-1`. City/surface movement and time
run through the [R10g ground host](ground-host.md), replacing the UI's separate
movement and one-minute-per-second survival updates on those scenes. Ship,
service, interior and sleep controllers retain their existing owners.

The UI passes whole milliseconds from differences of absolute frame timestamps.
It does not round individual frame durations or discard normal ground update
time. The host owns the serialized50ms remainder, movement edges, due clock,
threat RNG and encounter ticks. Pause, help, saves, inventory and dialogue stop
the corresponding simulation. Scene and dialogue transitions resume paused;
held controls clear at modal/scene boundaries and after loading.

## Controls and presentation

Chase opens on the actual eligible city due tick and draws source window rows,
player and pursuer glyphs. Arrow keys or held pointer/touch movement can reach
the source escape edge. Catch derives the Game17 arena and opens mandatory
Game16 dialogue before active combat. Replies return to the same actor/history
activation, and a win opens the source post-fight conversation.

Combat controls are:

- Arrow keys or a held left pointer in Move mode move the player.
- Hover aims; hold Space or the right mouse button to fire.
- The Move / Aim & fire toggle lets a held primary pointer use firing, including
  touch input. It is presentation state and grants no weapon or ammunition.
- S or Cancel surrender sends the source cancellation input while an agreed
  surrender is pending. Source equipment/condition gates still decide behavior.
- Pause, help and saved games remain available. Inventory, boarding and pod
  actions return after the encounter ends.

English/Korean hints show source actor health and remaining contacts. The canvas
uses exported low-seven-bit glyph rows and the source cleared window geometry
over the frozen city map. A thin presentation outline identifies the combat
window; it does not create a collision wall. Ground player coordinates remain
arena coordinates while the campaign map pose remains the legitimate return
point. This is the documented browser arena adaptation, not full native copied
background or Apple II video/cycle parity.

## Saves and outcomes

All four campaign slots and JSON import/export support partial due clocks,
chase, mandatory dialogue, combat and post-fight dialogue. Restore validates and
replays before replacing live state, clears held input and resumes paused. It
does not store/import arbitrary actors or interpreter frames. Room dialogue
uses its existing independent session and retains historical compatibility.
The standalone walkthrough retains its separate checkpoint format and session.

Escape publishes no personal loss. Source surrender/knockout commits cash/item
losses and condition once; source post-fight return commits the validated quote
and any gift. Health/vigor zero opens the existing ended-campaign scene and can
now be saved/exported with a durable defeat marker. Loading that save preserves
death and cannot restart time/movement. Loading a living save remains an explicit
recovery choice. No automatic healing, replacement inventory or new native
death/wreck continuation is invented; full source recovery dispatch remains R10.

## Evidence and remaining gates

`tools/remake/ground_encounter_smoke.js` imports declared actual-map contexts and
gate seeds10804/10753, then uses real UI production, replies, movement, aiming,
fire, source terminal outcomes and fresh-page saves. Read-only replay supplies
enemy coordinates for aiming. The armed fixture transfers the actual starting
laser; the fatal fixture uses the actual preceding knockout injury. Neither
injects actors, damage or outcome cash. These live integration fixtures do not
replace the required fresh-character ordinary-play campaign acceptance.

The receipt `r10h-ground-ui-validation.json` covers controls, partial-clock and
encounter saves, escape, surrender/cancellation, laser victory/reward, later
fatal damage, ended-session persistence and both locales at640×480,390×844,
844×390 and1920×1080. Explicit30/60/144Hz browser display-timer shims exercise
the actual UI loop without replacing game reducers or campaign state.
The Korean portrait combat screenshot is visually inspected. Existing room
dialogue and regional navigation regressions accompany the full rule suite.
Chrome154.0.8037.97 passes431 rule groups and144 UI checks:81 ground encounter,
19 room dialogue and44 navigation.22 exporter tests,171 deterministic artifacts,
584 classified strings and original input hashes verify. The receipt inventory
is `r10h-validation-summary.json`; it does not claim every older UI script was
rerun after activation.

[The R10 audit](r10-completion.md) remains authoritative. Ship production and
combat UI, cargo/cryogen loss, native death/wreck/recovery dispatch, rare reward
entry224 and ordinary-play avoid/fight/lose acceptance remain required.
