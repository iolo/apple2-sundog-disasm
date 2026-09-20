# Retained FORTRAN protection table

The initializer's 42 bytes at original `$F418`, copied `$6988`, and installed
`$BF56` are **nine data bytes and 33 code bytes**. The code comprises seventeen
complete instructions (32 bytes) and one deliberately clipped STA opcode.
The payload is now disassembled in `src/native/native_init.s`; it is not an
unidentified literal block.

## Evidence

Apple's [Pascal 1.1 ATTACH-BIOS documentation](https://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Software/Operating%20Systems/Apple%20Pascal/Manuals/Apple%20II%20Pascal%201.1%20Attach-BIOS.pdf),
Barry Haynes, printed page 38, explicitly reserves `$BF56–$BF7F` for FORTRAN
protection. The same listing occurs on PDF page 52 of the combined technical
notes cited in [native-high-metadata.md](native-high-metadata.md).

Willi Kusche's [Pascal 1.1 interpreter disassembly](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf),
page 195, contains the identical table at `$F308`, but leaves its contents
unexplained. That establishes earlier provenance, not internal classification.

The missing consumer is in the historical
[FORTRAN FORT2 disk](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/programming/fortran/187_Fortran_FORT2.dsk).
Independent extraction and decoding of `SYSTEM.COMPILER` establishes:

- Segment 9 starts at file offset `$2200` and is `$0682` bytes long.
- Its procedure dictionary identifies native procedure 4 at file offset
  `$2698`; native relocation metadata bounds its body independently.
- At file offsets `$26BB–$26DD`, it reads the pointer at `$BF23/$BF24`, copies
  eight bytes into four zero-page pointers, then twelve bytes into scratch
  storage at procedure-relative offsets `$0163–$016E`.
- At `$26DE–$2721`, it replaces three placeholder operands: the restore buffer,
  table address plus 21, and that address plus the byte at table offset 20.
- At `$2744–$2772`, it saves and replaces three bytes at each pointer. It selects
  bank 2 for the first three writes and bank 1 for the fourth.

These compiler addresses are **file offsets**, not execution addresses.
The native relocation table marks the `$0163–$016E` scratch operands as
procedure-relative; they do not refer to the hardware stack page. Their stored
bytes reside at file offsets `$27FB–$2806` after the restore routine.
`src/native/evidence/initializer_fortran_protection.json` records the source
URL, disk/file/segment hashes, procedure/relocation metadata and bounded
consumer excerpts. The external disk is research evidence, never a build input.

## Complete layout

| Table offset | Installed address | Classification and use |
| --- | --- | --- |
| `$00–$07` | `$BF56–$BF5D` | Data: four patch-site address words |
| `$08–$0A` | `$BF5E–$BF60` | Code template: JSR, operand replaced with `$BF79`, installed at bank-2 `$D2C0` |
| `$0B–$0D` | `$BF61–$BF63` | Code patch: LDA `$46` followed by the STA zero-page opcode, installed at bank-2 `$D55C` |
| `$0E–$10` | `$BF64–$BF66` | Code template: JMP, operand replaced with `$BF6B`, installed at bank-2 `$D37A` |
| `$11–$13` | `$BF67–$BF69` | Code template: JMP to the supplied restore buffer, installed at bank-1 `$D20F` |
| `$14` | `$BF6A` | Data: helper displacement 14 |
| `$15–$22` | `$BF6B–$BF78` | Ten-instruction checksum/state helper ending in RTS |
| `$23–$29` | `$BF79–$BF7F` | Three-instruction write helper ending in JMP `$D310` |

The three `$B3B3` operands are placeholders, not executable destinations.
The partial STA inherits operand `$CF` from the existing bank-2 instruction
at `$D55E/$D55F`. Thus the installed four-byte sequence is LDA `$46`; STA `$CF`,
although the compiler copies only its first three bytes. The following table
byte `$4C` belongs to a separate JMP patch; it is **not** the STA operand.

The helpers are stored alongside templates but execute at their installed
addresses. The checksum helper combines A with `$AB` and zero-page `$CD`,
uses shifts/comparison to update `$46`, then returns. The write helper loads Y
from `$46`, executes BIT `$00`, and transfers to the bank-2 disk-write code.

This identifies retained FORTRAN support. It does not establish SunDog
activation of those patches, or require the game to include the FORTRAN compiler.
The four addresses must be interpreted with the consumer's bank selections;
looking them all up in the p-code bank gave misleading results.

## Validation

`check_native_init.py` independently disassembles the newly identified complete
instructions and checks the copier, published pointer, table fields, templates,
helper displacement, retained STA operand and disk-write continuation.
Its current audit is `reference/initializer-fortran-protection-audit.json`.

```sh
python3 tools/build_disks.py
python3 tools/check_native_init.py
python3 -m unittest discover -s tools -p test_initializer_protection.py
python3 tools/verify_disks.py
```

For independent research reproduction, extract `SYSTEM.COMPILER` from the linked
disk using the command recorded in the evidence JSON, then pass its local path
with `--fortran-compiler`. This additionally verifies every frozen consumer
excerpt and its native procedure provenance against that file.
