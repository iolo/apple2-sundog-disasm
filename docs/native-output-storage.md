# Native assembler output-buffer storage

The tails of the title and viewscreen-transition native containers are classified
as **output-buffer storage**: cleared allocation bytes followed by one retained
uncleared byte. This classification combines complete native metadata, known
two-block allocations, the exact placement of the exceptional byte, and an
independently verified behavior of the Apple Pascal assembler.

| Component | Complete native container | Zero storage | Retained byte |
| --- | --- | --- | --- |
| Title, disk 1 blocks 201–202 | Offsets 0–927 | 928–1022, 95 bytes | Offset 1023: `$04` |
| Viewscreen transition, disk 2 blocks 86–87 | Offsets 0–943 | 944–1022, 79 bytes | Offset 1023: `$04` |

Both containers have one native procedure, four empty relocation lists, a
backward entry displacement resolving to offset zero, native attributes and a
complete procedure dictionary/trailer. The viewscreen caller fetches exactly
1,024 bytes. The title bootstrap fetches 9,216 bytes: this 1,024-byte native
prefix followed by the independently classified 8,192-byte bitmap. These
boundaries were established before this storage classification. See [title-draw.md](title-draw.md)
and [viewscreen-transition.md](viewscreen-transition.md).

## Historical writer evidence

The [archived Apple Pascal 1.2 disk 2](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/programming/pascal/ucsd/UCSD%20Pascal%201.2_2.DSK)
contains `SYSTEM.ASSMBLER`. Its `PROCEND` segment is 3,224 bytes at file block 30,
segment number 9. Full decoding validates nine procedures. Procedure 9 performs:

- At `$0700–$0731`, two `NEW` allocations of 256 words each, preserving the first
  pointer in global word 72. The two adjacent allocations provide 1,024 bytes.
- At `$0732–$073A`, `LDO 72; SLDC 0; LDCI 1023; SLDC 0; CSP 10`: clear 1,023
  bytes starting at offset zero. **Offset 1,023 is not cleared.**
- In procedure 1, `$08A8–$08C1` computes `(BUFFERPOS+511) DIV 512`, then writes
  that many complete blocks from the same buffer through system procedure 28.
  A completed native segment of 928 or 944 bytes therefore writes 1,024 bytes,
  including the uncleared final byte.

The related [UCSD assembler source](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/arch/z80/assembler/asm2.text#L452)
corroborates the algorithm: `FIRSTPROC` allocates two blocks and calls FILLCHAR
with `BUFLIMIT`; [the constants](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/arch/z80/assembler/main.text#L91)
define two blocks and a limit of 1,023. This source is for the Z80 assembler;
the independently decoded **Apple 6502 assembler binary** establishes that the
same buffer behavior exists on the relevant platform. The Apple Pascal runtime
uses word counts for NEW and byte counts for FILLCHAR; its allocator advances
the heap pointer without initializing the allocated bytes. Those runtime
semantics are documented in the [Pascal 1.1 interpreter listing](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf),
printed pages 50 (NEW) and 148–149 (FILLCHAR).

`docs/reference/assembler-buffer-evidence.json` freezes the disk/file/segment
hashes, 85 relevant instruction bytes and their disassembly. The original file
SHA-256 is `595659812b4d2a15486f9b09a1dd2e97d20126424b315ee38498b88cb958ddbe`.
An optional external replay decodes the complete original PROCEND segment and
checks both excerpts against its procedure-aware instruction inventory.

## Interpretation and limits

The classification is an inference from the matching writer behavior and two
complete SunDog native allocations. It does **not** prove which assembler
release built SunDog, reconstruct the exact historical build session, or assign
a meaning to the retained `$04`. The observed storage is consistent with a
cleared output buffer whose last byte survives from earlier memory contents.
It is not treated as another native instruction, parameter, or segment trailer.

This evidence resolves the earlier concern that the nonzero ending alone
prevented classifying either tail. The conclusion is limited to these two
matching native-container allocations. It does not automatically classify
nonzero RLE tails, dialogue storage, the fourth boot sector, or arbitrary
unreached code/data elsewhere.

The title's 96 bytes were already source-built and are now explicitly named
storage declarations. The viewscreen's 80 bytes are newly source-built by
`src/data/viewscreen_output_storage.s`. No byte is normalized or dropped.

## Verification

```sh
python3 tools/test_native_output_storage.py
python3 tools/test_early_native_footers.py
python3 tools/native_output_storage.py --verify
python3 tools/early_native_footers.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The audit freshly assembles both native components, parses their metadata,
checks both complete tails, verifies disk ownership and validates the frozen
assembler evidence. Tests reject all footer/tail byte mutations, truncated
allocations and changed writer instructions. To replay against the separately
extracted historical file, add `--external-assembler /path/to/SYSTEM.ASSMBLER`.
Historical files are validation references only, never normal build inputs.
