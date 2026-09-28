# Ship resources and location copies — R04g

The initial campaign record now includes hull, fuel, warp/shield/gun charges and
controls, destination and pod locations, and pod attachment. These are utility
save defaults. Startup, machinery ticks, navigation and combat can change them;
those transitions are not implemented in this checkpoint.

## Creation correction

Utility21 calls utility20 at `$0A33`, after the six equipment groups. Utility20
`$087B–$088A` writes `13 + random % 4` to equipment-bank byte 192 (globals byte 300).
Library24's damage branch `$0925–$096F` handles group 6 as the hull and terminates
the ship when this value reaches zero. The clean capture has hull 16.

R04f omitted this random draw. Its generation order tests compared the same
incomplete composition and therefore did not detect the omission. Recipe
`shipped-defaults-2` adds the hull draw between equipment and system generation;
later seeded navigation and cryogen placements consequently change. The four
saved gameplay RNG bytes and starting cash precede this draw and are unchanged.
New tests check the hull expression independently and all four outcomes. Recipe1
is rejected by the new campaign save codec; no campaign UI or persisted campaign
format existed before this correction.

## Resource fields

Utility21 clears the globals area before setting the hull. Resource words below
therefore start at zero. Game15 `$00BE–$00F0` labels the meter rectangles FUEL,
GUNS, SHLD and WARP; `$018D–$01BE` supplies their corresponding values.

| Browser field | Segment29 source | Consumer evidence |
| --- | --- | --- |
| `hull` | Equipment bank byte 192; globals byte 300 | Utility20 initialization; library24 hull damage branch |
| `fuel` | Word227 | Game15 fuel meter; library24 fuel update |
| `warp.targetSystemId` | Word221; zero becomes null | Game13 warp selection/cancel; `$1716–$1725` clears target and request |
| `warp.targetCharge` / `charge` | Words222 /223 | Library24 `$0CC5–$0D14` approaches target by charging or discharging |
| `warp.charging` | Flag0 at word 82 | Warp charging request; game13 warp cancel clears it |
| `shields.targetCharge` / `charge` | Words224 /225 | Library24 `$0C55–$0CA6`; game15 shield meter |
| `guns.charge` / `powered` | Word226 / flag2 | Library24 `$0BE2–$0C4B` charges powered guns or drains inactive guns |
| `enginesPowered` | Flag1 | Game13 `$1B36–$1B44` stores destination and starts engines |

Charge words are preserved as named integers; this step does not invent UI units,
fuel purchases, equipment effectiveness or energy-cost rules.

## Destination and pod

Utility18 copies the initial six-word location block to word 66 (globals byte 60),
word 72 (byte 72), and word 228 (byte 384). The initial anchors all equal (147,115).
Game13 `$1B36–$1B44` copies the selected destination to word 66 and enables engines.
Library24 `$042F–$044A` copies that destination into ship/player locations on
arrival. It is a destination, not a second ship.

Game15's pod exit `$027A–$02D5` switches the ship/pod mode, clears flag 7 and copies
word 228 into the player's current location. Library24 `$0457–$0468` updates this
pod location on ship arrival while flag 7 is set. Flag 7 also selects the full-ship
versus detached-pod artwork in game15/startup7. It starts true in utility21.
The named `podAttached` field uses **flag 7 at word 82**, not scene word 45 bit 13.
Both happen to be true in the clean capture; a synthetic decoder test distinguishes
them. Player, ship, destination and pod location objects are independent.

`tools/remake/campaign_reference.py` now decodes all these fields from the original
512-byte globals capture. Its checked-in fixture is reproducible; runtime creation
does not import it. A nonzero synthetic record verifies the separate resource
word addresses and power bits, since zero defaults alone cannot prove the mapping.

The initial source-backed fields now support the [landed-ship save scope](campaign-saves.md).
Further scene modes, encounters, machinery and travel need their own state rules
and save-version changes before being enabled.
