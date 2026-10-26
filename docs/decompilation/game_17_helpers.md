# Game17 setup, selection, and hit helpers

This note records the initial helper checkpoint. The later
[completion group](game_17_complete.md) recovers the remaining bodies and
documents the current VAR parameter declarations and physical copy behavior.

Twelve bodies are recovered directly from `src/pcode/game_17.s`: procedures2–10
and13–15, totaling1,033 original instructions. The project now has123 of570
targeted bodies recovered (10,527 instructions). Game17 procedures1,11,12,16,17
remain outstanding. No new decompiler or native implementation was added.

The assembled component is3,532 bytes, SHA256
`40a1e9a4fa6e0ea4276826a25cf91b480bada8c2b6392d3967c9aa33cee09515`, matching
the reconstruction manifest. Assembly revision and procedure identities remain
in the [inventory](inventory.json). Segment17 alone is not the component identity.

| Procedure | Entry / attributes | Recovered behavior |
| --- | --- | --- |
| 2 | `$0000 / $001C` | Drawing mode2 query with the canonical Boolean result from DATASEG29 word1. |
| 3 | `$001E / $0044` | Capture an entry, select mode1, position, and draw its word2 high-byte code. |
| 4 | `$0046 / $0096` | Draw/remove an entry, shift following ten-byte records, decrement count, set word42 when one remains. |
| 5 | `$0098 / $00DA` | Set entry1 delay from flag48, set parent78, and update nibble45:1 when life is zero. |
| 6 | `$00DC / $0130` | Scan packed equipment bytes for low-five-bit code11 and extract the upper bits. |
| 7 | `$0132 / $01C4` | Find code12/13, exchange its byte with slot0, retain the tracked index, and update entry1's active bit. |
| 8 | `$01C6 / $0210` | Repeated random placement until procedure2's query returns false. |
| 9 | `$0212 / $03DC` | Clear and initialize item records, trail records, display bytes, and random placements. |
| 10 | `$03DE / $0416` | Optional library51 setup through caller coordinates, followed by four bound loads. |
| 13 | `$0608 / $068A` | Random distance threshold and strict coordinate-distance scan, returning a Boolean and VAR index. |
| 14 | `$068C / $07CC` | Hit query, drawing/sound sequence, equipment consumption, damage, and removal. |
| 15 | `$07CE / $08D2` | Preserve coordinates, clamp and adjust them by the original direction case, then write mode/result state. |

## Storage and interfaces

[types.pas](../../src/pascal/game_17/types.pas) describes the original196-byte
parent local area, beginning at frame slot4 after three raw address arguments.
`startup_disk1.s:$0125..$012B` supplies addresses of caller slots4,3,1, in that
order. The fixture retains this six-byte parameter convention; child10 and15
dereference those words through the established address view.

The frame overlays preserve these evidenced offsets:

- Words4–38 contain seven five-word entries (indices0–6). Procedure9 clears
  exactly70 bytes. Each entry has second/first coordinates at words0/1,
  code/draw bytes at word2, radius/life bytes at word3, and delay/active/spare
  fields at word4. Active occupies only bit8, leaving seven spare bits.
- Words39–42 are separate flags accessed through the raw word view. Words43–46
  are a four-word saved bound record; its save/restore consumers remain pending.
- Words47–74 contain seven four-word trail records. Procedure9 initializes
  offsets3,2,1,0 in that order.
- Remaining fields keep their parent slot numbers. Word94 is the active count;
  bounds use84–87. The raw view extends through101, preserving the full frame.

The entry declaration describes accesses, not proof that every restored count
or input index is valid. No bounds repair or invented default was added.
All required library bodies and native signatures already existed.

## Decisions checked against the instructions

Procedure4 captures the upper bound after drawing and copies all five words
per shifted entry. Its initial unused address calculation performs no memory
read and is omitted. Procedure5 likewise omits an unused local word.

Procedure6 reads DATASEG29 byte`122 + index` and calls native32 before testing
`index < 4`. It therefore reads byte126 at the terminating index4. The recovered
condition keeps that ordering. Procedure7's exchange preserves the original
update of parent77 only when its previous value was zero; code12 leaves parent75
unchanged. The item scan in procedure13 uses the distinct strict `found < count`
test before incrementing, visiting entries1 through count.

Procedure8 captures the selected entry once and does not add a retry limit.
Procedure9 preserves the order of both random MOD5 calls and reads radius after
the later random delay call. Its direction cases retain no-op defaults for
unlisted values. The original packed stores, including life truncation before
the comparison with32, remain packed stores.

Procedure13 always calls random before testing distance, even for an empty
scan. Both absolute-value calls run before their Boolean results combine.
Strict comparisons are retained for distance, count, and both coordinate
thresholds. Procedure14 exits on `origin = found` before drawing, retains both
drawing sequences, and captures life before the damage random call. Damage
clamps negative results to zero; records are removed only on the original
non-player zero-life path. No health or gameplay meaning beyond these accesses
is assumed by the raw storage declarations.

Procedure15 uses the original coordinates to compute direction before clamping
to10..39 and7..23. Case values1/2/4/5,3/6,7/8,9 select the four pairs of signed
two-unit adjustments. The default changes neither coordinate. VAR pointer
views preserve sequential stores when caller outputs alias.

## Validation and remaining work

The [existing fixture](checks/game_18_compile.pas) appends compile-only parent131
and children132–143, preserving all earlier procedure numbers. Parent131 has
the original196 local bytes, six parameter bytes, and lexical level1, but an
empty body: it is excluded from the recovered mapping and count. The maintained
source includes only the twelve recovered child bodies and their storage views.

All123 recovered bodies compile without diagnostics with the documented
reference compiler/options. Parameter widths and lexical levels match the
original metadata for all twelve new bodies. Local sizes differ where unused
temporaries were removed or explicit effect-ordering temporaries were added;
none of these children has nested consumers of its local frame.

The [receipt](checks/game_18_receipt.json) records source/output hashes, frames,
and mapping. The [verifier](checks/verify_game_18.py) checks the five-word stride
and copy, packed offsets,70-byte clear, equipment scan ordering, random ordering,
strict count comparison, both distance calls, saved life, direction case, and
self-EXIT target. Seven previously established exact body matches still pass;
no exact byte match is claimed for these game17 bodies. These are scoped static
checks, not runtime execution or a general equivalence proof.

Use the commands in [validation and reproduction](game_18.md#validation-and-reproduction).
Next recover procedures11/12's frame save/restore, procedures16/17's updates,
and procedure1's entry. The stack-relative extent of the save/restore copies
needs explicit review before changing their frames or calling them equivalent.
