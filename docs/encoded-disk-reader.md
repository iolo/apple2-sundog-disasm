# Retained encoded disk reader

Disk-1 block 196 offsets 0–126 contain **127 encoded instruction bytes**.
`src/native/encoded_disk_reader.s` reconstructs all 66 instructions, including
the NOP delay subroutine at the end. The byte at offset 127 is now separately
classified as retained native word-alignment data; offsets 128–511 are the independently classified
[interaction-record copies](interaction-records.md).

## Encoding and address evidence

Adding `$5B` modulo 256 to every stored byte reveals the native routine:

```text
decoded[i] = (stored[i] + $5B) & $FF
stored[i]  = (decoded[i] - $5B) & $FF
```

This transform was found by comparing constant-byte transformations with
already classified components. The first twelve decoded bytes match the
pointer-consuming native prologue of the screen initializer: four PLA/STA
pairs save the return address in $00/$01 and the argument in $02/$03. The
remainder is a different routine. Its complete control flow, controller
addresses and matching return sequence provide independent code evidence;
the short prologue match alone is not the classification criterion.

The absolute JSR operands establish an internally consistent origin of
**$E000**: $E070, $E074 and $E07A select progressively shorter paths through
fourteen NOPs at offsets $70–$7D, ending at the common RTS at $7E. All three
targets are internal instruction boundaries. From the single entry at offset
zero, the strict decoder covers every one of the 127 bytes, with no external
calls, overlapping instructions, data declarations or additional guessed roots.

The inferred source origin does not establish a current loader, decoding
consumer, language-card mapping or live invocation. In particular, these are
local delay calls, not calls into the shipped p-code interpreter's unrelated
$E000 memory contents. The current game must not be assumed to execute this
retained routine merely because it can be disassembled coherently.

## Instruction behavior

- `$E000–$E00B` consumes the native return address and pointer argument.
- `$E00C–$E013` sets X to $60 and reads $C089,X and $C08A,X: the slot-6
  motor-on and drive-one switches, $C0E9 and $C0EA.
- `$E014–$E032` initializes Y to 255 and polls $C0EC for bytes with bit 7 set.
  It searches for the sequence `$AA,$D5,$A7`. The second/third-byte mismatch
  paths decrement Y again; the first-byte polling loop does not consume Y.
  Thus Y is a retry counter, not a general timeout for absent disk data.
- `$E034–$E057` calls the three local NOP delay entries: once at $E07A,
  six times at $E074 and five times at $E070.
- `$E058–$E065` waits for another high-bit-set disk byte, stores it at the
  supplied pointer and clears the following byte. The retry-exhaustion branch
  enters at $E062 with Y=0 and clears only the first result byte.
- `$E066–$E06F` reads the motor-off switch $C0E8 and restores the original
  return address before RTS. `$E070–$E07E` is the called delay subroutine.

No track seek, sector decoding or full-block read is performed. The marker's
purpose and the routine's historical caller remain unknown.

## Reproduction and boundary checks

`src/native/evidence/encoded_disk_reader.json` records the stored hash,
constant transform, inferred origin, disk extent and single entry. The normal
raw-component generator produced the source and per-instruction audit in
`docs/reference/raw-modules/encoded_disk_reader.json`. Existing storage encoding
support uses seed 91 and step zero; no new encoding algorithm is introduced.

```sh
python3 tools/test_encoded_disk_reader.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests assemble the committed instruction source, reproduce its stored hash and complete
control-flow audit, check all twelve local calls, and reject a branch into an
operand, an external call and automatic inclusion of the trailing byte. The
stored byte at offset 127 is `$A5`, which decodes to zero under the same
transform. It remains excluded from the strict instruction graph; its separate
alignment classification uses the writer evidence below.

## Retained native word alignment

The historical Apple Pascal assembler pads odd-length native bodies with one
zero byte before emitting relocation data. This is independently visible in
the source's `IF ODD(BUFFERPOS) THEN PUTBYTE(0)` and the Apple 1.2 binary:

- PROCEND segment 9, `$06AF–$06B6`: load the output position, skip the zero-byte
  call when its low bit is clear, otherwise push zero and call segment 1,
  procedure 12. The interpreter's FJP tests bit zero of its Boolean operand.
- Segment 1, procedure 12, `$08E5–$08F0`: write the parameter byte at the output
  buffer plus its current position, then increment that position by one.

The source reference is [the UCSD assembler's procedure completion](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/arch/z80/assembler/asm2.text#L440).
That source is for Z80; the matching Apple 6502 assembler behavior is checked
by full procedure-aware decoding of both relevant segments from the historical
`SYSTEM.ASSMBLER` identified in [native-output-storage.md](native-output-storage.md).
The 20 instruction bytes and their disassembly are frozen in
`src/native/evidence/encoded_reader_alignment.json`.

Here, the 127-byte instruction body ends with RTS at offset 126. Its following
decoded zero is precisely the byte needed to reach the next even boundary,
128, where independently classified interaction-record copies begin. This
combination supports a **retained assembler alignment byte**. It does not
establish the historical assembler release, imply that a complete footer
survives, or invent a live decoding/entry path. The current record data at 128
is not reinterpreted as the reader's relocation metadata.

`src/native/encoded_reader_alignment.s` emits one explicit zero with the same
inverse encoding, reproducing stored `$A5`. The combined disk-reader prefix is
therefore 127 instruction bytes plus one classified data byte. Verification
also checks the independently classified record donor and exact ownership:

```sh
python3 tools/encoded_reader_alignment.py
# Optional full historical-segment replay:
python3 tools/encoded_reader_alignment.py --external-assembler /path/to/SYSTEM.ASSMBLER
```

Normal builds assemble instructions and apply the inverse transform without
reading either original disk. Full-image equality preserves the existing
behavior baseline; this checkpoint does not claim a new emulator run.
