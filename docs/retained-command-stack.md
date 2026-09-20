# Retained Pascal command-prompt stack

Both disks retain the same 184 bytes at block 139 offsets 328–511. Block 103
also retains the final 138 bytes of this window, at the same block offsets.
These are historical Pascal activation-stack data. The reconstructed data
source is `src/data/retained_command_stack.s`.

The block-103 counted prompt (offsets 418–485) already had source ownership.
This checkpoint preserves that mapping and adds its 44 preceding and 26
following bytes on each disk, plus both complete block-139 tails: **508 newly
classified disk bytes** from 184 source bytes. This completes classification
of the library-header residue left open in step 08c.

## Format and address evidence

The layout follows the 128K conditional paths in Willi Kusche's
[Pascal interpreter disassembly](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf):
copied strings carry an original p-code address and next-list pointer before
their count/text (pages 62–66); call frames save a string-list head before
the saved Pascal stack pointer (pages 108 and 113). The ordinary twelve-byte
mark record agrees with the locally reconstructed native interpreter. See
[the earlier retained-stack analysis](retained-pascal-stack.md) for the
conditional-path distinction and local instruction references.

Four consecutive dynamic links resolve under one inferred mapping:

```
memory address = $B58C + containing-block offset
retained window = $B6D4–$B78B
```

| Mark offset | Mark address | Dynamic link | Saved stack top | Saved string head | CPU SP |
| --- | --- | --- | --- | --- | --- |
| `$146` (clipped) | `$B6D2` | `$B6EE` | missing | missing | `$EF` |
| `$162` | `$B6EE` | `$B704` | `$B700` | zero | `$F1` |
| `$178` | `$B704` | `$B71A` | `$B716` | zero | `$F3` |
| `$18E` | `$B71A` | `$B776` | `$B72A` | `$B72A` | `$F5` |
| `$1EA` | `$B776` | `$B798` (outside window) | `$B78E` | `$B78E` | `$F7` |

All four complete frames have static link `$B7CA`. Each twelve-byte mark stores
static/dynamic links, saved JTAB, SEG, IPC, one CPU stack-pointer byte and one
retained unused byte. Its four-byte prefix stores the string-list head and
Pascal stack top. The clipped frame retains its dynamic link through unused
byte only; its static link and saved-state prefix are outside this tail and
are not reconstructed by inference.

The mapping is constrained independently by the copied prompt. At offset
`$19E` (memory `$B72A`) its header contains original p-code address `$9FAF`,
zero next pointer, and count 67. Its text is:

```
Command: E(dit, R(un, F(ile, C(omp, L(ink, X(ecute, A(ssem, ? [1.2]
```

The frame at `$B71A` has both saved stack top and saved string head pointing
exactly to this node. The node occupies 72 bytes and ends at `$B772`, the next
frame's saved-state prefix. No alignment byte is required for this odd-length
string. Its original code address is address data; no external code at that
address is claimed to be present in this window.

## Intervening storage

For each complete frame, the interval from mark plus twelve bytes to its saved
stack top is parameter/local storage. These intervals contain six, six, four,
and twelve bytes, respectively. Only ten bytes of the final interval survive;
the two bytes beyond this block and the pointed-to string at `$B78E` are not
invented.

The clipped first frame ends at `$B6DE`. Twelve bytes remain before its parent's
prefix at `$B6EA`, whose position is established by that frame's surviving
dynamic link. They are interframe activation storage. The missing saved stack
pointer prevents assigning a more specific division into locals and earlier
temporary values; it does not make them an executable region. The complete
frame chain, copied-string pointer, monotonic CPU stack values and exact
allocation boundaries together establish the stack-data interpretation.

The audit partitions every byte into saved frame fields, copied-string data,
or bounded activation storage. Individual local-field meanings remain unnamed.
These historical contents do not assert a current SunDog activation, a SunDog
128K requirement, or that the old stack remained live when copied to disk.

## Verification

`tools/retained_command_stack.py` checks frame links and bounds, the prompt's
header/count/text/allocation, the complete byte partition and a hash limiting
acceptance to the reviewed window. It checks both block-139 tails and both
block-103 copies, assembles the declarations exactly, and verifies regenerated
artifacts and manifest ownership. The complete audit is
`reference/retained-command-stack.json`.

```sh
python3 -m unittest discover -s tools -p test_retained_command_stack.py
python3 tools/retained_command_stack.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests reject altered links, bounds, saved string heads, copied text and
unreviewed local bytes. Normal builds use committed declarations and do not
read downloaded interpreter evidence. No new emulator run is implied.
