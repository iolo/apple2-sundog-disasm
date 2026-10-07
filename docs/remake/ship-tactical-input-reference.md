# Original-game tactical input and Comm return — R10n

Two owned MAME0.285 unenhanced Apple IIe sessions resumed the supplied play slot
on disposable media. [Metadata](../reference/remake-tactical-input-reference.json)
inventories19 source contexts and48 hashed artifacts. The Comm session retains
matching operation receipts and its observed terminal exit0. The input session
also exited0 after clearing its breakpoint and releasing the joystick. All
three original disk/manual hashes still match. A bootstrap-only session whose
console handle was lost is excluded from gameplay proof.

These are declared contact/charge/reticle fixtures followed by native joystick
input, not naturally generated encounters or fresh-character acceptance.
`tactical_input_reference.lua` records the explicit RAM edits. Unsuccessful
menu positioning, microsecond release/repress and unfinished macro probes are
excluded; a scheduled go or input receipt alone is not completion evidence.

## Aim, fire and cached contact

The Guns screen is reached through the native joystick. At proc17 `$0F70`,
the firing/focused locals are1 and cached contact local31 is1. The declared
fixture centers205/206 at512, sets speed/velocity0, cooldown40, health200,
range20, charge100 and counter354=0. Other source owners are retained.

| Capture | Game12 offset | Observed result |
| --- | --- | --- |
| `held-menu` | `$0F7A` | Charge100/health200/counter0: the selecting button remains consumed. |
| `aim-before` | `$0B5D` | Proc12 samples x8/y−7; reticle angle16/radius128, counter1. |
| `aim-after` | `$0B70` | Reticle23/120, x528/y498, cooldown39, counter1. |
| `release-poll` | `$0F7A` | Releasing primary spends no charge. |
| `shot` | `$0F7A` | After another declared center fixture and fresh press: health0, charge0, counter2, cooldown4. Cached contact/visibility are0 while global40 remains true. |
| `held-fire` | `$0F7A` | An explicit refill of226 to100 remains100 on the next held-primary loop. No repeat shot. |
| `ammo-zero` | `$0454` | A later released/new empty-space press reaches charge0 with both global40 and cached contact false. |
| `loop-exit` | `$0FBC` | Secondary exits the gun loop; firing and gun power are false. |

Library22 native proc2 `$0C89–$0CB5` combines the sampled button with the
dispatch-hook latch, consumes that latch and returns a rising edge for argument0.
The hook at `$0CDF–$0CEE` ORs physical buttons into the latch between polls.
Holding primary cannot fire again merely because power restores charge.
Proc17 polls before movement; proc12 polls again after its first movement.

The browser saves both the held input and `{latched,previous}` in opt-in28.
A short released press remains buffered until a logical frame consumes it.
One fixed input sample per50ms logical frame cannot create a second edge at
the second native poll; it can clear the history of a released buffered press.
This is an explicit input/timing adaptation, not CPU-cycle identity. The native
physical joystick Y=255 yielded source−7 in this capture; it is not evidence
that physical255 must universally map to−8. The native paddle-counter lookup
remains the source mapping authority.

Gun proc7 tests parent local31, rather than global40. A kill clears that cache
before the next Library24 combat call clears40. The host now passes the actual
cache, so an empty-space press spends charge without another hit, cooldown,
range-memory update or duplicate kill.

## Full kill continuation remains required

The visually inspected [message](../reference/remake-tactical-input-kill-message.png)
shows TARGET DESTROYED and a1000Cr bounty. It is an ordinary paused Library22
message context, not a Game12 debugger stop. Metadata therefore retains its
actual VM segment/IP without inventing a Game12 offset.

Game12 proc6 `$0197–$021D` grants bounty when system word8/nibble3 + enemy type>12,
uses nibble4 to calculate at least one thousand-credit unit, then eagerly draws
the wreck gate0..5. A wreck sets parent local27, inhibition36 and subsequent
cargo/type/quality draws. The kill capture has local27=1 and changed RNG bytes.
The held-fire capture's range20→21 belongs to the wreck branch, not ordinary
contact movement. The gun arithmetic alone draws no RNG; the full kill does.

Bounty, wreck, inhibition, tractor/salvage and their persistent campaign owners
remain to implement. This observation does not establish salvage collection,
full ship-death/recovery or ordinary combat acceptance.

## Comm byte return and dispatcher correction

At the main stop `$1388`, the declared fixture writes parent angle local44=−1
and radius local45=777. Native joystick input reaches Comm; source `$1320`
has workspace byte16=9 and byte17=255 after both stores. The actual pirate
dialogue appears, with Agree/Refuse/Dismiss It. Dismiss It opens the next topic;
secondary cancel reaches the hostile funeral message, then primary acknowledges
it. These are verified screen transitions, not a synthesized direct return.

The owned return breakpoint `$07D1` captures restored angle255/radius9,
cleared35/41, retained hostility44 and repeat guard47. Charisma15→7 is also
retained by the source dialogue predicate. The clock remains bytes21,21,0,0;
phase352 advances3→4. Game13 main `$2588` runs one actual Library24 proc9 before
Game12 consumes the return bits. Game12 skips its three startup calls.

R10m's host omitted that dispatcher call. Opt-in28 now commits Game16 personal,
account, flags and RNG outputs, runs one actual machinery phase, then consumes
Game12's return flags. It retains the saved fractional-frame budget. A newly
agreed deadline starts at6 afterward; the dispatcher does not decrement it.
Contact can disappear or forced sleep/defeat can interrupt this dispatch, so
restoration cannot require a surviving global40 or recreate an ended controller.

## Reproduction and limits

Use the [a2-mame skill](/home/iolo/.codex/skills/a2skills/a2-mame/SKILL.md), the
disposable `encounter_bootstrap.py --debug` workflow and the four helpers named
in metadata. Verify actual debugger stop/model/media before changing RAM.
Set owned dispatch breakpoints with `tacticalOpcodeBreakpoint`, record their
returned IDs, and use `tacticalStoppedSave(path,offset)` to assert actual source
position before saving. Physical button changes need native frame progression;
changing release/press only at adjacent microsecond stops is not consumed input.
Clear owned breakpoints, release touched inputs and observe terminal exit.

Live space controls, localized help,30/60/144Hz display-refresh/sleep/reload,
legitimate ground/space avoid/fight/lose, native death/recovery and rare reward224
remain required by the full [R10 audit](r10-completion.md).
