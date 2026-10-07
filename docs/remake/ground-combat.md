# Ground combat rules — R10c

`remake/js/core/ground-combat.js` ports the source-facing Game17 activation
record and its complete player/NPC combat iteration. This is an isolated core;
the live campaign remains version23 and does not produce or display encounters
yet. Ground threat production/chasing, campaign ownership, enemy dialogue setup,
controls, persistence and original-game ground evidence remain required R10 work.

## Source procedures

Offsets are segment-relative in `src/pcode/game_17.s`. Library22 procedure3
supplies the seven-shift RNG; procedure40 supplies inclusive ranges; procedure22
attempts diagonal, horizontal, then vertical movement using the same HGR pixels
that draw actors. All arithmetic vectors use the source's packed byte fields.

| Procedure | Implemented behavior |
| --- | --- |
| 9 `$0212`, 11 `$0418` | Kind16 chooses2–6 actors, including the player. Kinds18/22 create one initially passive visitor. Player position is window-left+67/window-top+51; combat health packs `health*strength/90` into a byte before clamping to33. NPC health70–250, two skill draws and cooldown10–15 follow the source RNG order. Approach direction positions the first NPC; later actors use random collision-free placement. Seven movement-history records start at the player. |
| 6 `$00DC`, 7 `$0132` | First carried shield by masked ID11; first laser/scattergun by masked ID12/13, swapped into slot0. If a shield moves out of slot0, its identity follows the swap. Passive visitors initially disable the player's weapon. |
| 13 `$0608`, 14 `$068C` | A shot draws its distance gate even on a miss. Player tolerance uses dexterity/10, distance subtracts intelligence; NPC tolerance is3. Rectangular comparisons are strict. The first nonzero-health actor within tolerance is hit. Shields spend a charge without a damage draw; unshielded damage is `4*(RNG MOD16)`. Health≤32 changes glyph25; zero-health NPCs are removed immediately. Killing the last NPC sets kind15 for the later source dialogue. |
| 16 `$08D4` | Primary movement advances at most one pixel per axis toward pointer−3/+3 and exits at source window margins. Secondary firing resolves one laser shot or all five scattergun shots, then spends one scatter charge and prepares the next weapon. Knock-out has a ten-iteration robbery countdown; surrender has two iterations, may be cancelled, and preserves carried items while clearing cash. History updates on every iteration, including knock-out: jump pointers `$0B3C/$0B3E` both target `$0AFF`. |
| 17 `$0B4E` | Each NPC draws a history index before decrementing cooldown. Knocked-out NPCs recover to33 at zero cooldown. Active NPCs chase distant/history targets, follow one randomly selected movement axis nearby, or flee after truce/robbery. Fleeing retries a blocked move with the player's glyph hidden. Source boundary margins remove departing actors. Available hostile NPCs shoot at the chosen historical player position. |
| 4 `$0046`, 5 `$0098` | Actor removal compacts records; the final removal ends the encounter. Player knock-out sets mode1/cooldown; zero health changes the **middle** scene nibble to12, rather than falsely writing the current high nibble. NPC friendly-fire compaction preserves the source retained slot-pointer behavior for cooldown updates. |
| 12 `$0528`, 11 resume | Suspension writes packed shield/scatter charges, converts combat health back to personal health and limits vigor to twice that health. Actor records/history survive JSON serialization. Dialogue return transfers the interpreted personal state and RNG into that same session; flags48/49 select surrender/truce without regenerating NPCs. |

The actor record is five unsigned words: `[y,x,visibleGlyph*256+24,
health*256+skill,cooldown+weaponReady*256]`. Source indices1–6 map to browser
array indices0–5. `data/ground-combat.json` exports shared-font glyphs22–25,
including the full7×8 collision glyph24 and the fallen glyph25. Dynamic actors
XOR their visible pixels into an owned background before collision tests.

Zero-charge shields/scatterguns remain enabled in the source. Subtraction only
breaks a device when its charge becomes exactly zero. The core retains signed16
underflow and byte packing: a charge of−1 writes shield235 or scattergun237 on
suspension. This is a source quirk, not an invented replenishment rule. Ordinary
charged-device use exhausts and switches equipment normally.

## Host contract and declared browser adaptations

`createGroundCombat` receives verified personal state, kind, approach direction
and an already prepared combat arena. It does not decide where or when a threat
appears. `stepGroundCombat` performs one player-plus-NPC iteration. The host owns
the arena, world return position, clock, campaign ledgers, dialogue dispatch and
defeat scene. `fireGroundShot` exposes procedure14 as an isolated primitive;
normal player volleys and charge expenditure go through `stepGroundCombat`.
`checkpointGroundCombat` writes personal condition/charges while retaining the
session. `resumeGroundCombat` applies the interpreted dialogue result to it.

The browser serializes the native suspended activation record as JSON. Its
explicit50 ms iteration cadence is an adaptation, not native CPU timing. The
elapsed remainder persists across JSON save/resume and freezes during pause.
Rendering never advances RNG or combat. A single advance call is bounded to60
seconds; it processes all logical ticks rather than dropping delayed frames.
After zero player health changes the source return nibble to12, subsequent
browser combat iterations stop so the host can present defeat.

The cursor is absent from collision, so hiding it and repeating an identical
step does not change the result. The source's player-hidden flee retry still
does. Native target scanning can inspect a record beyond the active actor count;
the browser scans active actors only. Native repeated placement can loop forever;
the browser detects repeated RNG states and also bounds work to65,536 attempts,
rejecting atomically. Direct adjacent placement rejects a blocked/overlapping
prepared window rather than inventing a relocation or extra RNG draws. Self
shots reproduce the source SYSTEMERROR17,14 as an atomic error.

These are source-derived rules. No original-game ground-combat observation,
campaign save migration, ordinary live-UI encounter journey or complete R10
acceptance is claimed by this checkpoint.

## Validation

Twenty ground rule groups cover initialization, native byte packing, shield
identity/exhaustion/underflow, strict hit tolerance, full scatter volleys, NPC
collision, player-hidden fleeing, friendly-fire compaction and recovery,
avoid/fight/lose outcomes, surrender/cancellation,
fatal hits, dialogue suspension, JSON continuation, pause and display refresh
independence. RNG checks use an independent little-endian byte/carry oracle.

Seed12345 creates three actors in11 draws in the declared clear140×96 fixture:
player `(67,51)` health200/skill5; first NPC `(60,43)` health106/skill1; second
NPC `(76,67)` health220/skill5. Player fire at seed29 causes28 damage in two
draws. NPC fire at seed12345 causes56 damage in two draws, or spends one shield
charge in one draw. These are fixture/source vectors, not natural campaign
encounters. [The full Chrome receipt](r10c-rules-validation.json) reports380
passing rule groups with no failures or page errors in Chrome154.0.8037.97.
