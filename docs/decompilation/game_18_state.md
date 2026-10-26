# Frame state and input bounds recovery

This group adds six recovered Pascal bodies and five native interfaces, using
the component identities in the [first group](game_18.md). The current total is
45 bodies, representing 3,451 original instructions; 11 native interfaces are
reviewed. The assembly remains the disk-build source.

| Procedure | Entry through return | Attributes | Instructions | Pascal |
| --- | --- | --- | ---: | --- |
| game 18:21 | `$0EB2..$1057` | `$1066` | 218 | [restore_room_session.pas](../../src/pascal/building_interiors/restore_room_session.pas) |
| game 18:22 | `$1068..$113C` | `$1148` | 122 | [save_room_session.pas](../../src/pascal/building_interiors/save_room_session.pas) |
| game 18:24 | `$1372..$142C` | `$1436` | 120 | [probe_counter_neighbor.pas](../../src/pascal/building_interiors/probe_counter_neighbor.pas) |
| library 22:42 | `$079A..$07F9` | `$0804` | 47 | [initialize_pointer.pas](../../src/pascal/graphics_and_io/initialize_pointer.pas) |
| library 22:61 | `$071A..$0768` | `$0772` | 41 | [read_pointer_position.pas](../../src/pascal/graphics_and_io/read_pointer_position.pas) |
| library 22:62 | `$0774..$078E` | `$0798` | 24 | [configure_pointer_axis.pas](../../src/pascal/graphics_and_io/configure_pointer_axis.pas) |

## Native interfaces

The [native declarations](../../src/pascal/graphics_and_io/native_interfaces.pas)
preserve these stack contracts without replacing the native implementations:

- **22:2**, entry `$0C4A`: removes the return address, four reserved result bytes,
  and the selector's low byte. It leaves the selector's high byte on the stack
  and pushes the result low byte at `$0CB8..$0CC1`. The integer interface retains
  that behavior; selectors 4, 0, 5, 1 used here yield canonical Boolean words.
  Input-state and dispatch-hook effects mean discarded calls remain necessary.
- **22:24**, entry `$0F26`: removes the return address and four reserved result
  bytes, then restores the return address. The argument address itself remains
  as the one-word result. A VAR integer parameter exposes that address without
  reading the pointed-to value.
- **22:5**, entry `$0DAA`: removes the return address and one pointer. Stores at
  `$0DF4`, `$0DF9`, `$0E18`, and `$0E1D` write four consecutive bytes through it,
  forming two words. The source uses a `wordpair` record passed by reference.
- **22:30/31**, entries `$0FA8`/`$0F6C`: remove four reserved result bytes and
  the count word; its low byte controls shifting of the value word. Count zero
  leaves the original value on the stack. Nonzero counts return a shifted word.
  The native left/arithmetic-right shift bodies remain authoritative.

## Input bounds and aliasing

Library 42 takes two VAR coordinates, a scalar code, and a four-word bounds
value. Its initial `MOV 4` precedes every external write. It derives inset
bounds at external word 375, then calls its nested procedure 62 twice, with
extents 140 and 96. It sets the drawing bounds, obtains coordinates through 61,
and calls 41 using the reread VAR outputs.

Nested 62 writes `ord(span > extent)` through its first VAR argument, rereads
that argument, conditionally doubles its scalar extent, and writes the offset
through the other VAR argument. The source keeps this order instead of folding
the Boolean into a private temporary. Library 42's unused local words 9..12
are omitted; the nested body has no lexical-parent accesses to them.

Library 61 passes adjacent local words 3/4 to native 5, optionally scales each
through native 30, adds external offsets, and clamps through procedure 37.
The two final VAR stores remain sequential, preserving the result if callers
pass the same address for both outputs. External flags 379/380 are interpreted
using their low bits, matching FJP.

## Parent-frame restore and initialization

Game 21 first calls native 2 with selectors 4, 0, 5, 1. Each result is assigned
to an otherwise unused local, keeping every effectful call. Parent parameter
slot 2 contains a pointer. If its value is positive, the routine stores -9408
(`$DB40`) in parent slot 152 and computes the address difference between parent
slots 151 and 5 using native 24. This is 292 bytes: slots 5..150 inclusive.
It copies that span forward from `$DB40` into the parent frame, leaving slots
151..153 outside the restored region. The raw address is preserved without
assuming a host buffer, allocation, or a different bank mapping.

After the copy, the routine writes parent flags and external word 2, then
rereads the caller's pointed-to value to select its next path. The restored
path captures an entry pointer, may call 10/11, updates packed fields from
external bytes, and handles flags 48..51/65. The random branch tests bit zero.
The new-state path saves external values, clears flags 57 and 64..71, and calls
setup 20 followed by initialization 14. Both paths clear the same trailing
parent fields and caller value before invoking library 42. The captured entry
pointer is retained across calls even if parent indices change.

Game 22 handles the other direction. If external word 45's middle-upper nibble
is 7..10, it copies the same parent span forward to `$DB40` and sets external
byte 551. Other values take the bounds/native-state path, perform the original
nibble transitions, restore external words 351/353, and clear flag 57. The flag
347 test retains its low-bit meaning. The new storage views for word 45's
nibbles and word 37's six bits at offset 9 alias their existing word/byte views.

The 292-byte copies intentionally span several Pascal declarations. UCSD
`moveleft` uses the base address and explicit count; it does not limit the copy
to the declared size of `g18items`. The fixture's 298-byte parent-local layout
and both endpoint addresses were checked in disassembly. The source requires
that evidenced frame layout and valid caller storage.

## Packed reference update

Game 24 derives a row from entry 1's first coordinate and the parent interval.
It chooses a column using the original signed absolute-value comparison, writes
reference 1 into that cell, encodes row/column in the entry high byte, and loads
the neighboring cell. The neighbor's address is formed before the positive-index
test. For an eligible neighbor, bit tests select parent value 17 or 21, then
external byte 550 and parent flag 141 are updated. No bounds checks or fixes for
a zero-width interval were introduced. Pure RAM predicates may short-circuit
in the reference compiler; effectful calls are not skipped or reordered.

## Verification and remaining dependency

All 45 bodies compile together without diagnostics. Parameter byte counts and
lexical levels match original metadata; global storage remains 760 bytes and
parent locals remain 298 bytes. The five earlier exact body matches still pass.
The [receipt](checks/game_18_receipt.json) records the new source hashes, frames,
and mapping. The [focused verifier](checks/verify_game_18.py) checks the four
discarded input calls, copy endpoint construction and both copy directions,
value-parameter copy, nested VAR write/read, and adjacent native input buffer.
Use the [existing reproduction commands](game_18.md#validation-and-reproduction).

Game 23 is still unrecovered. Its call to game 8:1 requires recovering that
module's interface and dependencies; no placeholder game-8 body was substituted.
The remaining game-18 bodies and full procedure inventory remain outstanding.
The fixture is compile-only; native input, copied frame state, and game behavior
have not been exercised at runtime.
