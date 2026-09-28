# Personal condition and consumables — R05c

The walkthrough shows vigor, rest, health and nourishment. Carry food or
rapidheal, select it, then choose Eat food or Apply rapidheal. Each use consumes
one item and restores up to 80 of its condition byte. Initial condition is full;
the UI warns that using an item at full still consumes it. No hunger or fatigue
accumulates yet. These rules remain separate from character drafts and campaign
initialization.

## Source mapping

Offsets below are relative to the named p-code segment. Condition occupies four
bytes at data segment29 word60, or bytes48–51 in the saved globals snapshot.

| Rule | Source | Browser behavior |
| --- | --- | --- |
| Field order | `game_8.s` procedure7 `$017E–$0249`, labels at `$01BB` | Vigor, rest, health, nourishment in that order. |
| Meter extent | Game8 procedure2 `$0000–$006D` | `(value+7) div8`, from 0 to 32 filled units. Accessible meters also expose the exact 0–255 value. |
| Initial condition | `utility_disk1.s` procedure21 `$0922–$092B` | All four bytes are 255; independently verified against the clean-character capture. |
| Item identification | `library_27.s` procedure11 `$034B–$035A` | Low five bits select the type. Supported types are food8 and rapidheal10. |
| Rapidheal | Library27 procedure11 `$036C–$0375` | Original action2, head, selects type10 and condition index2 (health). |
| Food | Library27 procedure11 `$0377–$037E` | Original action1, mouth, selects type8 and condition index3 (nourishment). |
| Recovery | Library27 procedure14 `$02C6–$02E6`; library22 procedures34/35 | Absolute signed index identifies the condition byte; sign multiplied by 80 gives the delta. Both implemented effects are positive. |
| Clamp | Library27 procedure11 `$0399–$03B8`; library22 procedure37 `$06DA–$06EE` | Add 80 to the selected byte and clamp to 0–255. Other condition fields remain unchanged. |
| Consume | Library27 procedure11 `$03C2–$03CC` | Clear the used held item, including when the condition was already 255. |

Procedure14's subsequent attribute and ale branches do not apply to types8/10.
Ale and boosts require separate attribute effects and random penalties; this
checkpoint does not expose them. Shields, weapons, engineering parts and shunts
are transferable but have no new use action.

## Original-game evidence and limits

The four default bytes match `docs/reference/remake-clean-character.json`.
An additional owned MAME 0.285 Apple IIe session used disposable disks and a
**controlled RAM fixture**, not natural depletion. After closing personal
status, a paused, read-back-verified write set the condition bytes to
`[128,90,120,100]` and carried bytes to `[8,10,235,12]`. Reopening showed the
four condition bars. Rest became 88 during that interval. The receipt and
screenshot record `[128,88,120,100]`:

- [Fixture and observation](../reference/remake-condition-fixture.json)
- [Original condition display](../reference/remake-condition-fixture.png)

Joystick targeting attempts did not establish a successful item pickup/use;
captured carried bytes stayed unchanged. Therefore food/rapidheal effects are
**source-derived and rule-tested, not independently observed in the original**.
No timing calibration or natural survival loop is claimed. The owned emulator
exited successfully, and original disk/manual hashes were verified.

## Browser adaptation and remaining work

The original places a held item on the mouth or head. The browser exposes one
localized action for a selected carried food/rapidheal item. It requires carrying
the item first. Use atomically commits the condition and inventory change, clears
selection, announces the result and returns focus to the empty slot. It cannot
consume a second item from a repeated activation. Cancel and locale changes
preserve the selected item until use or a transfer is committed.

Meters use the existing ivory display palette; original threshold colors are
not reproduced. Four meters occupy the space below the carried slots, while the
selected-item warning and action share the inventory footer. The existing 4:3
composition, local font and English/Korean controls remain in place.

Game8 procedure17's sleep loop also advances simulation and handles interruption
and scene-dependent behavior. The native/library survival clock, hunger, fatigue,
sleep and other consumables need their own implementation and evidence. No new
timer or arbitrary depletion was invented for this checkpoint. Condition and
inventory survive reopening the walkthrough or changing language; reload resets
both, and Return to start only moves the player. Campaign saves remain pending.

See [validation](condition-validation.md) for rule and browser coverage.
