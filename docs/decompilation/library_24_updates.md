# Library 24: movement, damage, and update entry

This group recovers library24 procedures12/13/9 and game8 procedures3/4 directly
from their p-code listings: 1,218 original instructions. Native24:4's interface
is also reviewed. Coverage at this group's checkpoint was 97 of 570 p-code bodies, 7,698 instructions, and 16 of 38 native
interfaces. Library24 still lacks p-code bodies 1/2/6/10 and native interfaces
3/5. The full source-recovery plan remains incomplete.

The component is `library_24`, SHA-256
`acaadfd85907933575a035fe67f716630e3c3695430008f90a4b48ea6b1fd68c`, from assembly
revision `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`. Disk extents remain in
`src/pcode/library_24.adopt.json`. All findings and checks here are static.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 24:12 | `$02B4..$0676` | `$068E` | 539 | [proc_12.pas](../../src/pascal/library_24/proc_12.pas) |
| 24:13 | `$0690..$0A8D` | `$0AAA` | 581 | [proc_13.pas](../../src/pascal/library_24/proc_13.pas) |
| 24:9 | `$0E06..$0E50` | `$0E5A` | 33 | [proc_09.pas](../../src/pascal/library_24/proc_09.pas) |
| 8:3 | `$00A4..$00FB` | `$0108` | 53 | [proc_03.pas](../../src/pascal/game_8/proc_03.pas) |
| 8:4 | `$007A..$0098` | `$00A2` | 12 | [proc_04.pas](../../src/pascal/game_8/proc_04.pas) |

The game8 component hash is
`49588749543660839355c65b1acaacc2cb5679ae726d914ed1c1c2a5be92d89d`;
its disk extents are in `src/pcode/game_8.adopt.json`.

## Storage and native contract

[Storage views](../../src/pascal/storage.pas) add six-word aggregates at external
words36/66/72/228; bounds303/307/323/343; and 4/5/7-bit views at words67/73.
The existing byte view addresses both halves of word72 as bytes142/143 and
the low half of word41 as byte80. Byte371 is word90's byte193. These overlays
retain the 760-byte DATASEG29 allocation and its aliasing.

Word23 holds an existing table pointer. Each selected row spans ten words;
the final two words expose eight nibbles. The four-bit selector uses a one-based
row index. The declared 15-row window documents those accesses, not allocation,
ownership, or validation of the pointer/selector. No range guards are invented.

[Native24:4](../../src/pascal/library_24/native_interfaces.pas), entry `$0F5E`,
pops ten bytes into zero page: return address, second output pointer, first
output pointer, second input, first input. It writes two-byte results first
through `$04/$05`, then through `$02/$03`, and restores only the return address.
The interface therefore has two scalar inputs and two VAR outputs. The native
table/arithmetic body and relocation records remain authoritative; the Pascal
fixture does not implement or link it.

## Movement and arrival

Procedure12 does nothing unless flag1 is initially set. It saves phase352
before the random call and reads the byte230 threshold afterward. Movement
uses phase bit0; the independent amount decrement uses full phase equality
with3. Display coordinates are converted before and after movement when the
saved draw predicate permits it.

Arrival copies six words66->72, saves word40 and the low byte of41, copies
66->36, then restores those two fields. The new high byte of41 from the copy
is retained. Flag7 permits a further copy66->228. Sounds and flag updates keep
their order. Clearing flag1 does not skip the rest of the current invocation.

The encounter checks preserve unconditional random calls within their enclosing
branches. Planet bits are captured before the first call; table nibble3 and
nibble7 are each captured before their respective calls. The table row itself
is captured once with `WITH`, preserving local11's original pointer lifetime.
The failed second test rereads and decrements nibble7. Final display update
at `$0629` runs whether an encounter was selected or not.

## Damage update and shared entry

Procedure13 retains the two movement/timer paths, the pending-event path, and
the separate scheduling path. Calls22:40 and22:3 are evaluated in their original
order even when a Boolean result could otherwise short-circuit. The word217
load precedes22:40. The code23 scan calls random once for each of its twenty
bytes, including bytes that do not match23. Both successive bounds343 mode3
calls at `$0886/$088E` are retained.

The damage loop intentionally preserves two unusual details. At `$0922`, an
empty group's marker changes the group to6 without recalculating the base
offset. At `$09B8`, the selected byte replaces the damage accumulator; the
subsequent subtraction512 uses that replacement. Changing either behavior to
a more conventional damage algorithm would contradict the listing. The loop
executes at least once on this path. Final phase signaling and restoration of
the saved word216 happen after either event path.

Procedure9 saves word227 before the optional clock update, wraps/increments
phase352, passes the same local amount to12 and15 in order, then tests flag40
for13. It stores the local amount back only afterward and draws bounds323.
These dependencies now have reviewed bodies, rather than placeholder calls.

Game8:3 chooses library24:9 when mode nibble1 is at most2, otherwise22:29.
If parent slot15's low bit and flag60 are set, it calls nested4, redraws all
four condition bars, calls nested4 again, then clears flag60. Nested4 tests
its parent's first Boolean argument before the second, reading its
grandparent's coordinates afresh on each invocation. Existing call sites at
`$03CE/$04F0/$0981/$0B6B` pass canonical0/1 argument pairs.

After restoring drawing mode1, state nibble2 equal to12 calls22:52 and executes
`EXIT(8,1)`. The source names its enclosing entry `proc8_1` for this ancestor
exit. At this group's checkpoint that body was unrecovered, so the fixture supplied
an empty parent scope. The [completion group](game_8_complete.md) now supplies
the actual parent body at the same fixture number107.

## Verification and limits

At this checkpoint all 97 recovered bodies compiled without diagnostics using the existing
[fixture commands](game_18.md#validation-and-reproduction). Fixture external103
is native24:4; procedures104/105/106 are24:12/13/9. Game8's enclosing entry
is107, and procedures115/116 are8:3/4. Parameter widths and lexical
levels match original metadata. Locals are28 versus20 bytes for12 (explicit
call-order temporaries and captured pointer),20 versus24 for13 (unused slots
omitted), and the original2 bytes for9. There are no nested lexical consumers
of these changed local layouts. Globals remain912 bytes.
Game8:3/4 retain their original4/0 local bytes and lexical levels2/3; their
parent retains118 local bytes and two argument words.

The [verifier](checks/verify_game_18.py) checks the six-word copies and field
restoration, table stride/captured pointer and pre-call nibble loads, random
ordering, duplicate bounds calls, damage-variable reuse, the shared entry's
call/store sequence, and game8's nested access/ancestor EXIT. All seven existing exact body matches still pass; no new
exact-body match is claimed. Byte accesses replace equivalent eight-bit packed
accesses; pure comparisons may short-circuit; calls/globals are relocated in
the fixture. Whole-module equivalence and runtime execution remain unverified.

Next: game8's update callers, followed by its remaining dependencies. Original
assembly and disk-reconstruction inputs are unchanged.
