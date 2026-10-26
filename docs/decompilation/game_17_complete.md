# Game17 entry, save/restore, and updates

Game17 now has all 17 p-code bodies recovered, totaling 2,071 original
instructions. This group adds procedures1,11,12,16,17 (1,038 instructions)
to the [earlier helpers](game_17_helpers.md). Overall coverage is 128 of570
targeted bodies and 11,565 instructions. No runtime execution is claimed.

The [complete entry](../../src/pascal/street_encounters/run_street_encounter.pas) supplies the parent
scope and includes all children. The component identity remains SHA256
`40a1e9a4fa6e0ea4276826a25cf91b480bada8c2b6392d3967c9aa33cee09515`;
the [inventory](inventory.json) records the assembly revision and offsets.

| Procedure | Entry / attributes | Recovered behavior |
| --- | --- | --- |
| 1 | `$0D64 / $0DA6` | Setup11, initial selection15, input setup42, updates16/17, final selection/drawing, cleanup12. |
| 11 | `$0418 / $0526` | Restore or initialize state; poll selectors4/5 until both clear; initialize equipment and drawing flags. |
| 12 | `$0528 / $0606` | Store equipment/life state, then restore the outer display or save the current frame. |
| 16 | `$08D4 / $0B4C` | Input, delay and equipment transitions, player movement retries, hit calls, and trail updates. |
| 17 | `$0B4E / $0D62` | Other-entry updates: delay, revival/removal, movement direction and retries, bounds removal, and hits. |

## Physical copy extent

The original save and restore do **not** compute the size of the declared
parent record. Procedure11 subtracts the address of its own local slot2 from
parent slot99; procedure12 uses its own local slot1. Both pass the resulting
count to CSP2, starting at parent slot4 and the saved address `$DB40`.

The interpreter provides the evidence:

- `native_shared.s:$E116..$E11C` takes the current free-stack pointer.
  `$E197..$E1CC` subtracts local bytes, parameter bytes, and a12-byte mark.
  `$E254..$E272` leaves the next free pointer at the new mark minus2.
- `pcode_primitives.s:$D315..$D338` computes local addresses as
  `mark + 10 + 2*slot`. Native22:24 returns that address without dereferencing it.
- CSP2 dispatches at `$D104` to `$E878`; `$E8AA..$E8CE` copies bytes forward.
  MOV4 uses source-last/destination-first stack operands through `$D59B` and
  the same forward copying loop.

Let the parent mark be `M`, with its free pointer still `M - 2` when it calls
the child. The original zero-parameter children have these layouts:

| Child | Local bytes | Child mark | Count variable address |
| --- | --- | --- | --- |
| 11 | 4 | `M - 18` | slot2: `M - 4` |
| 12 | 2 | `M - 16` | slot1: `M - 4` |

Parent slot99 is `M + 208`, yielding **212 bytes**. Starting at parent slot4,
that covers slots4–109, while declared locals end at101. It includes16 bytes
above the declared local area. This is a static derivation for the original
allocator/call context, not a runtime observation or proof that the overrun was
intentional. Shortening it to190 or196 bytes would change the supplied program.

The source keeps the address subtraction, exact child frame sizes, and count
variable slots. A new parent overlay exposes slot100 as the saved-address
pointer without allocating another word. Parent arguments are now ordinary
`VAR integer` parameters, retaining the original three address words and
avoiding extra pointer temporaries in child12. Helpers10/15 were adjusted to
use those VAR parameters directly. Their caller aliasing remains intact.

After restore, procedure11 copies saved parent43–46 **to** DATASEG29 bounds11.
Before save, procedure12 copies bounds11 **into** parent43–46. The fixture
checks both MOV4 directions as well as both raw CSP2 directions. The copy still
touches memory outside the Pascal record: future runtime integration must
preserve the original frame/caller context or explicitly account for this
behavior. Compiler acceptance alone does not validate it.

## Branch and effect review

Procedure11 calls both input selectors4 and5 on every poll, including when4
already returned true. Fresh mode16 chooses count2..6; other modes except15
set count2. Mode15 leaves count94 unchanged. No initial value was invented for
that field or for other parent fields the original does not initialize.

Procedure12 retains the packed byte store before rereading and doubling it,
the original multiplication/division order, and the two alternative cleanup
paths. Its saved-address/count work fits exactly one local word; the existing
parent slot100 holds the pointer. Bounds7 drawing, nibble updates, word351
restoration, and the caller result store remain in their original order.

Procedure16 captures flag48 and the `parent78 = 1` predicate before calling
input0 and input1 unconditionally. The normal movement path retains two possible
movement calls separated by drawing. Both input5 calls remain, even though the
first result is discarded. The hit path can make five procedure14 calls; no
stale coordinates are cached across them. It retains the word47/46 clear order,
equipment-byte clears, and all four trail stores before advancing parent89.

Procedure17 selects a random trail before reading input. It retains the
post-input `index = count + 2` branch, the low-bit random direction test, and
up to three movement attempts. Removing an entry decrements the index before
the common increment, so the shifted entry is visited next. The entry address
stays captured across procedure14, which can compact the array; the final delay
store reads radius through that same address after the call.

Procedure1 runs both updates in each admitted iteration, even if16 changes the
completion flag. Normal exit draws the final position before cleanup12. There
are no new segment-runtime bindings in this module.

## Checks and limits

All 128 recovered bodies compile without diagnostics using the
[documented commands](game_18.md#validation-and-reproduction). Fixture131 now
contains the real parent; its12 existing children keep132–143, and new children
11/12/16/17 use144–147. The parent retains196 local bytes and six parameter
bytes; child11/12 retain4/2 local bytes. Child16/17 use24/12 local bytes instead
of22/14; neither has nested consumers or participates in the address-difference
copy calculation.

The [receipt](checks/game_18_receipt.json) pins hashes, mapping, frames, and
instruction totals. The [verifier](checks/verify_game_18.py) checks the copy
operands and directions, input-call ordering and snapshots, movement call
counts, random low-bit branch, captured post-hit store, and parent dispatch and
cleanup. Seven previously established exact body matches still pass. No exact
game17 body match, runnable fixture, or runtime/save compatibility is claimed.

Next follow the startup dispatcher into game19, recovering its required
library25/28 bodies and library22 procedure36 as needed.
