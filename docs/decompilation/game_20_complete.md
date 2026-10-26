# Game20 pricing, trading, and completion

Game20 now has all 32 p-code bodies recovered directly into
[Pascal](../../src/pascal/cargo_exchange/run_cargo_exchange.pas). This group adds procedures 1 and 16–31:
17 bodies and 2,015 original instructions. Overall coverage is **202 of 570**
targeted bodies, covering 18,226 instructions; 368 bodies remain. Native interface
coverage remains 16 of 38. Runtime execution has not been performed.

The [inventory](inventory.json) records source identities and review status.
The component hash remains
`f93e6492e63ad109ab1f4484b1fe9e61bc6de7c63b67dc7c69abf976f07aecdf`.
The [warehouse notes](game_20_warehouse.md) describe the preceding 15 bodies.

| Procedures | Recovered behavior |
| --- | --- |
| 16–19 | Pricing, overflow-sensitive integer scaling, and source-city planet/system searches. |
| 20–22 | Inventory decrement, offer generation, and duplicate-offer search. |
| 23–24 | Price/demand display, acceptance, and warehouse/pod selection and storage. |
| 25–27 | Selling/delivery, capacity checks, and the buying loop. |
| 28–31 | Exchange/warehouse dispatch, scrolling offers, input, and headings. |
| 1 | Segment loads, setup, interaction, state restoration, and releases. |

The recovered parent replaces the empty fixture scope and retains 328 local
bytes. Captions occupy 168 bytes beginning at parent slot 60; eight two-word
offer records occupy slots 144–159. An offer's high byte is quality, whereas the
same byte in a cargo item holds its source city. The conversion explicitly
writes the three-bit category field and the origin byte. Value items and
amounts retain two-word copies, including procedure 24's unused amount argument.

Pricing reads byte 15 of the 16-byte name row. Procedure 18 retains the
`32767 div scale <= operand` threshold and its two different multiplication/
division orders. Procedure 16 applies the original ordered clamp after the
source-city adjustments. Exhausted searches leave planet 19/system 13; no new
fallback, widened arithmetic, or zero-divisor guard is introduced.

Offer generation copies all seven inventory words, including padding. Its
attempt count persists across outer iterations. The final availability value
is loaded before the random call, and that call still runs in contract mode
or after attempts run out. Contract wrap to kind 0 still performs the packed
lookup. In the supplied interpreter, IXP at `$DA1D` calls the division helper
at `$D7D9`; index -1 gives quotient 0 and magnitude remainder 1, so IXP 5,3 reads
bits 3–5 of the first word. The Pascal retains the unchecked index and requires
these interpreter semantics. It does not insert a bounds check or substitute
host-language negative-index behavior. Duplicate detection scans all eight
offers and compares kind/high byte while ignoring category bits.

Buying requires cash strictly greater than the offer. Caption formatting pads
through byte 14 and forces the length byte to 14, leaving byte 15 alone. Selling
updates demand before pricing the contract bonus; the bonus accumulator is
captured before price/shift calls. Buying regenerates the selected offer before
the amount check and charges cash before storage selection, as the listing
does. A failed capacity check still polls input 1, then returns normally. Inner
selection cancellation uses the original explicit self EXIT.

The scrolling display emits 22 bytes from the 168-byte ring and advances its head
by one. Timer update precedes the random refresh decision. Menu input preserves
the duplicate output address passed to the flash routine and snapshots the
selection before unconditionally polling input 1. Procedure 28's early EXIT after
setup bypasses procedure 7's cleanup.

Heading construction preserves the first append's nine-character limit: an
overlong city name contributes no text. The suffix is written into parent 28's
slot 4 string. A nine-character city plus ` Center` produces 16 characters, while
procedure 10 retains SAS 15. The reference compiler therefore reports an expected
string-capacity warning for the 24-character heading variable passed to text15.
SAS at `pcode_primitives.s:$D94B..$D989` rejects an overlong string; the recovery
preserves that failure behavior instead of truncating or enlarging the callee.

All 202 recovered bodies compile. The [existing verifier](checks/verify_game_18.py)
passes source/output hashes, parameter sizes, lexical levels, seven earlier
exact-body matches, and focused checks for arithmetic order, storage/copies,
polling, and EXIT targets. Other local allocations may differ; no whole-module
byte equality or runtime equivalence is claimed. The
[reproduction commands](game_18.md) and [receipt](checks/game_18_receipt.json)
record the compiler and its expected warning.

The parent loads 25/28 and releases 28/25. Its original exit attribute targets
the release epilogue at `$1A53`; the fixture's exit is RNP. Native/data-segment
bindings and this nonlocal-exit epilogue remain runtime integration requirements,
as with games 18/19. The fixture has an empty main and is not an executable game.
Assembly, native source, shared tools, and reconstruction inputs are unchanged.
