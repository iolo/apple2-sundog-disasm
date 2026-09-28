# Engineering inspection — R05e

Campaign play now exposes the six engineering bays. Walk to a bay and choose
Engineering, or press Enter with the ship focused. The panel identifies installed
components, missing/destroyed parts and shunts, the four unit performance values,
total performance and four spares. Selecting a component displays its name;
previous/next cycles the three systems in the current bay bank. Personal inventory
remains available through Inventory or I.

## Evidence

The supplied manual, PDF pages 11–12 (1-based), labels the six engineering
locations and describes local engineering windows. This checkpoint visually read
those pages and traced the reconstructed source; it adds no emulator observation.
The existing initialization fixture independently captures the equipment records.

`game_15.s` procedure14 `$07CC–$08A1` maps player anchor cells to interaction
IDs8–13. Procedure16 `$0945–$0957` hands the interaction to game14. Game14
procedure3 `$027D–$0282` starts its equipment index at interaction−9, then
procedure7 `$04EA–$0509` advances `(index+1) mod 3` and adds3 for IDs≥11.
Thus initial inspection selects interaction−8 and subsequent frames cycle only
within that bank. Previous is a browser convenience with the same wrap boundary.

| Interaction | Initial system | Reachable anchor used by rule checks |
| --- | --- | --- |
| 8 | Warp drives | (109,60) |
| 9 | Sub-c engines | (116,63) |
| 10 | Ship's guns | (109,67) |
| 11 | Tactical display | (109,138) |
| 12 | Force shields | (116,143) |
| 13 | Pilotage | (109,147) |

Game14 procedure3 `$01AD–$0234` supplies system names. Procedure4
`$02B0–$0345` reads components with five-byte unit strides; procedure5
`$0356–$03F9` reads unit and aggregate performance (0–4 and 0–16).
Utility19 and the independent reference decoder already establish four units
plus four spares in each 28-byte record; see [initialization](initialization.md).
Existing item labels and separate component SVGs are reused. The browser table
puts units in rows and sockets in columns; this is a presentation adaptation.
Performance is a component rating, not a claim that the system is powered.

## State and UI boundary

The validated campaign creation record is the equipment source while machinery
is immutable in `landed-ship-1`. `inspectEquipment` returns an owned copy; inspection,
frame changes and component selection never write campaign data or transfer items.
Save scope/version and recipe remain unchanged. Preview walking has no generated
equipment and does not expose the panel.

Opening inspection pauses simulation and clears held movement. Background controls
are inert, Tab stays within the panel, and Escape/Back returns focus to Engineering
with play still paused. Locale/resize preserves the selected component and frame.
The explicit open button and paused inspection follow the existing browser panel
conventions; they do not reproduce the original window's live timing or entry
side effects (such as game14 procedure7's byte25 and damaged-item cleanup writes).

Visual thesis remains the dark shipboard display, ivory source-derived component
SVGs and amber selection. The system name leads, the component table is the main
workspace, and a short text line identifies the selection. Existing focus/hover
transitions provide feedback without restarting an entrance on each selection.

## Next engineering work

Component replacement must use active equipment state separate from immutable
creation data, conserve full item bytes across carried/spare/installed slots and
extend save validation explicitly. Library24 procedure8 `$014C–$0261` recalculates
unit performance, special-component availability and related power/charge flags.
Its rules include control-node restrictions, shunt penalties, comparison against
the spare row, and special socket exceptions. Game14 procedures8/11 and their
callers also require complete transfer/timing analysis. Do not add a swap action
that changes only the displayed component and leaves these dependent values stale.

Repairs, services, fuel, power controls and ship exits remain pending. See the
[validation receipt](engineering-validation.md) for the verified inspection scope.
