# Setup, bounds, and buffer recovery

Fourteen additional bodies are recovered directly from the assembly, using the
component identities in the [first group](game_18.md). This brings coverage to
39 procedures and 2,879 original instructions. Native 22:15 has an evidenced
interface; its implementation remains in assembly.

| Procedure | Entry through return | Attributes | Instructions | Pascal |
| --- | --- | --- | ---: | --- |
| game 18:16 | `$0B78..$0CC3` | `$0CCE` | 186 | [proc_16.pas](../../src/pascal/game_18/proc_16.pas) |
| game 18:17 | `$0B2C..$0B6B` | `$0B76` | 45 | [proc_17.pas](../../src/pascal/game_18/proc_17.pas) |
| game 18:18 | `$0CD0..$0D50` | `$0D5C` | 75 | [proc_18.pas](../../src/pascal/game_18/proc_18.pas) |
| game 18:19 | `$0D5E..$0DFE` | `$0E0A` | 109 | [proc_19.pas](../../src/pascal/game_18/proc_19.pas) |
| game 18:20 | `$0E0C..$0EA5` | `$0EB0` | 83 | [proc_20.pas](../../src/pascal/game_18/proc_20.pas) |
| library 22:16 | `$00A8..$00B2` | `$00BC` | 5 | [proc_16.pas](../../src/pascal/library_22/proc_16.pas) |
| library 22:17 | `$01CE..$01DD` | `$01E8` | 8 | [proc_17.pas](../../src/pascal/library_22/proc_17.pas) |
| library 22:18 | `$01EA..$01FF` | `$020A` | 18 | [proc_18.pas](../../src/pascal/library_22/proc_18.pas) |
| library 22:37 | `$06DA..$06EE` | `$06F8` | 18 | [proc_37.pas](../../src/pascal/library_22/proc_37.pas) |
| library 22:50 | `$0A36..$0A55` | `$0A60` | 20 | [proc_50.pas](../../src/pascal/library_22/proc_50.pas) |
| library 22:51 | `$0A9A..$0B21` | `$0B2C` | 88 | [proc_51.pas](../../src/pascal/library_22/proc_51.pas) |
| library 22:52 | `$0B2E..$0B7A` | `$0B84` | 48 | [proc_52.pas](../../src/pascal/library_22/proc_52.pas) |
| library 22:53 | `$0B86..$0BAA` | `$0BB4` | 28 | [proc_53.pas](../../src/pascal/library_22/proc_53.pas) |
| library 22:63 | `$0A62..$0A8E` | `$0A98` | 21 | [proc_63.pas](../../src/pascal/library_22/proc_63.pas) |

## Addresses, byte copies, and unit I/O

The [storage declarations](../../src/pascal/storage.pas) overlay a 16-bit word
with byte-buffer and integer pointers. These are views of existing addresses,
not newly allocated buffers. DATASEG29 words 372/373 are pointer-valued storage;
the compiled fixture loads their values from global slots 374/375. The entire
DATASEG29 stand-in still occupies 760 bytes. The 2048-byte array view describes
the buffer span used here, not a recovered bound for all pointer consumers.

Library 22:63 copies 2048 bytes from pointer 373 to pointer 372 when its argument
is true, then clears external flag 116. The false path reverses the pointers
and leaves the flag alone. Both paths use `moveleft`, matching CSP 2. The supplied
interpreter at `$E878..$E8CC` consumes source/destination byte pointers and copies
in increasing address order. This retains forward-overlap behavior rather than
substituting a host `memmove` or record assignment.

Library 22:53 captures its raw buffer-address argument in one local word, then
uses unit 4, a byte count of `512 * blocks`, block number `block + 3`, and mode
zero. The Boolean selects CSP 5 (read) or CSP 6 (write). The vectors at `$D10A`
and `$D10C` lead to `$F041` and `$F046`, which select the original unit-I/O
handler. No retry, extra I/O check, or runtime replacement was added. Both
branches and the pointer representation reproduce the original body bytes.

Native 22:15 pops the return address and one argument word at `$0E2E..$0E38`.
It selects work using the low byte at `$0EA1..$0EAB` and restores only the return
address at `$0EAD..$0EB3`. The Pascal declaration takes an integer and returns
no result; the original native screen-memory effects remain authoritative.

## Library state and bounds

Library 22:18 takes a bounds record by reference followed by four scalar values.
It writes lower-first, upper-first, lower-second, upper-second in that order.
Arguments are captured before writes, including when destination storage aliases
an input location. Library 22:16 stores two arguments in external words 371/370;
22:17 converts a Boolean argument to a canonical 0/1 in word 359. Library 22:37
tests the lower bound first and only tests the upper bound if the first test
fails. Reversed bounds therefore retain the original branch behavior.

Library 22:50 sets bounds at external word 11, invokes 19 with mode zero, and
updates words 19, 18, and 17 from its scalar parameters. Library 22:51 exits when
external counter 20 exceeds 1, copies the buffer when it is already positive,
then increments it. It performs the original mode/bounds/native calls, derives
two clamped coordinates, stores bytes at offsets 2000/2001 of pointer 373, and
updates position/bounds before calling native 15 and clearing mode 359.

Library 22:52 is the paired transition: it exits for a nonpositive counter,
calls native 15, rereads and decrements the counter, and restores buffer and
position/bounds only if the new counter is positive. Byte loads occur after
the copy, and global counter loads remain on their original sides of native
calls. No balancing or underflow policy was invented.

## Game setup and nested bounds conversion

Game 18:16 first dereferences parent slots 4 and 3, in that order, for the call
to library 51. The fixture keeps the parent's four parameter words raw, named
`arg4` through `arg1`; local pointer views express these two observed address
uses without claiming the full unrecovered parent interface.

The routine loads one 512-byte block at `$4000`. Its `IXA 16` establishes a
32-byte entry stride. Each entry contains five two-word packed bounds, one
word of modes (4/4/8 bits), and trailing bytes starting at word 11. The array
of 16 entries describes that loaded block, not proof of all valid input indices.
The WITH pointer is captured once and retained through library calls.

Parent value 11 selects index 1. Otherwise, the index combines `4*(arg1-7)`
with the sum of the low six bits of external word 38 and low five bits of word
39, modulo four. The source reads unsigned low bytes and applies MOD 64/32.
These expressions were checked over every 16-bit bit pattern against the
original masks; their sum is at most 94, so this substitution introduces no
intermediate overflow. Other arithmetic keeps its original grouping.

Nested 18:17 copies the incoming two-word packed bounds before writes. It adds
external-origin offsets to the high/low bytes, calls library 18 with the VAR
destination, and calls 19 only for nonzero mode. The compiler emits the same
initial `LLA 4; SLDL 3; MOV 2`; its lexical level remains 3. Five calls in
procedure 16 process table bounds 4, 3, 2, 1, 0, in order. Parent bounds at slot
107 are the destination for entry 1; the other calls use a local bounds value.

Subsequent stores retain the byte-to-signed-offset conversions, minimum value 3
for parent slot 113, zero-to-128 replacement for slot 122, ordered random call,
parent flags, and final bounds call. The parent still occupies 298 local bytes.
Procedure 16 itself uses 20 local bytes instead of 18 because the raw parent
address reads have explicit temporaries; no nested child depends on those slots.

## Grid and bounds initialization

Game 18:18 fills all six bytes of the three packed-reference words using the low
byte of external word 293. It then derives three regions, draws each through
library 14/7, and draws a separator for the first two. The separator edge is
incremented only when **odd**, matching the original FJP low-bit test. A
nonzero test would alter even coordinates. The six-byte fill and branch survive
compilation; the original constant loop limit needs no separate local word.

Game 18:19 captures three external-origin values before setting parent bounds
99 and 103. Each of four iterations performs two bounds/native calls, sets its
packed parent flag, then calls procedure 15 with false. That order is retained
so 15 observes the flag update. The final bounds restore is outside the loop.

Game 18:20 selects the setup path using parent slot 1. Value 16 reads four
blocks into `$1800` (6144), derives coordinates from the dereferenced parent
parameters, sets the external counter, and calls native 15 before storing the
buffer's trailing coordinate bytes. Its second-coordinate clamp has lower bound
8, unlike library 51's lower bound 7. It then calls library 50 and copies the
resulting external bounds into parent slots 131..128. The other path calls 16,
then calls 18 if parent flag 139 is true, or 19 only if 139 is false and 136 is
true. This preserves the original precedence when both flags are set.

## Verification

All 39 recovered bodies compile together without diagnostics. Their parameter
byte counts and lexical levels match original metadata. The existing three
exact-body matches remain valid, and two new ones pass:

| Body, including RNP operand | Bytes | SHA-256 |
| --- | ---: | --- |
| Library 22:37 `$06DA..$06EF` | 22 | `7137843bb03b0207371f936021345b36f849ae76bd9805f939d8ff01bd42429e` |
| Library 22:53 `$0B86..$0BAB` | 38 | `318d2ee784a95c4e75b10c9e86a347b8daafc0a981e70f5bdb416d552d04266c` |

The [receipt](checks/game_18_receipt.json) pins current sources, compiled output,
frames, and mappings. The [focused verifier](checks/verify_game_18.py) additionally
checks the nested copy, table stride and five calls, both forward buffer-copy
paths, six-byte fill, odd-edge branch, and two new CSP EXIT targets. Use the
[existing reproduction commands](game_18.md#validation-and-reproduction).

These are static and compile-time checks. The fixture has unlinked native
interfaces, stand-in global storage, and an empty parent body. It has not been
executed, and the disk-I/O source has not read or written any disk. No claim of
whole-module recompilation or runtime/gameplay equivalence follows from these
checks. Invalid pointers and out-of-range callers remain outside the review.
