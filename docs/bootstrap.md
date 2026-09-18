# Bootstrap findings (step 04 in progress)

## Confirmed native load boundaries

An apple2ts breakpoint session followed the original disk-1 boot without changing
CPU registers, executable memory, or input bytes. It used `APPLE2EE`, 64 KB
auxiliary RAM configuration, and the private MCP server described in
`toolchain.md`. `reference/boot1-at-reader.json` contains the initial memory
capture, load parameters, runtime-entry receipt, and measured component hashes.

| Observation | Evidence |
| --- | --- |
| Native entry at `$0801` | Boot-sector bytes begin with a page-count byte, then `CPX #$60`; slot-6 requirement is explicit |
| Bootstrap in `$0800`–`$0AFF` | 768 captured bytes match disk image offsets `$0000`, `$0E00`, `$0D00`, except the count byte changes from 1 to 5 |
| First reader call at `$08FF` | `A=0`, `$0F=$C9`, `$02=$24`, `$3F=$40`: block 201, 36 pages, destination `$4000` |
| Call into `$4000` | Breakpoint reached; all 9,216 bytes at `$4000`–`$63FF` equal disk-1 logical blocks 201–218 |
| Second reader call | `A=0`, `$0F=$DB`, `$02=$30`, `$3F=$D0`: block 219, 48 pages, destination `$D000` |
| Third reader call | `A=0`, `$0F=$F3`, `$02=$10`, `$3F=$D0`: block 243, 16 pages, destination `$D000` in the other bank |
| Runtime entry `$FEF2` | Breakpoint reached after indirect jump through `$FFF8`; mapped `$D000`–`$FFFF` exactly matches the first 12 KB of SYSTEM.APPLE |
| Bank-1 entry `$D152` | `$FEF2` reads `$C08B` then jumps here; mapped `$D000`–`$DFFF` exactly matches the final 4 KB of SYSTEM.APPLE |

At the primary entry, `$D000`–`$DFFF` uses language-card bank 2 and
`$E000`–`$FFFF` is common language-card RAM. The later `$D152` entry uses bank 1.
The loader accesses `$C081` twice before the primary load, `$C089` before the
alternate-bank load, and `$C080` before jumping through `$FFF8`.

The reader turns the low block byte in `$0F` and high byte in A into track and
sector coordinates, then uses the physical-sector table at `$093E`. A requested
page count in `$02` is consumed while the high destination byte `$3F` advances.
The slot-specific reader begins at `$094E`, with `X=$60`, and reads Disk II data
via `$C08C,X` (slot 6's `$C0EC`). The bootstrap is now reconstructed in
`src/native/bootstrap.s` and assembled in the exact-disk build. Its `$4000`
callee's native prefix is documented in [title-draw.md](title-draw.md).

The capture includes `$0B00`–`$0CFF` as context. Those pages were **not** loaded
as part of the three-page bootstrap and must not be treated as code merely
because the modified count byte is 5. Only the first 768 captured bytes are used
for the bootstrap equality claim.

## Repeat the breakpoint sequence

1. Pause the private emulator, mount the original disk-1 bytes via an upload
   ticket, set breakpoint `$08FF`, and boot. Wait for a confirmed breakpoint.
2. Read zero page `$00`–`$3F` and the bootstrap at `$0800`. Set breakpoint
   `$4000`, clear `$08FF`, and resume. Compare `$4000`–`$63FF` with disk blocks
   201–218 using the mapping in `disk-layout.md`.
3. Restore breakpoint `$08FF`, clear `$4000`, and resume. Record the next reader
   parameters, then resume once more to record the alternate-bank request.
4. Set breakpoint `$FEF2`, clear `$08FF`, and resume. Read **active mapped**
   memory `$D000`–`$FFFF` and compare against SYSTEM.APPLE bytes 0–12287.
5. Set breakpoint `$D152`, clear `$FEF2`, and resume. Read active mapped memory
   `$D000`–`$DFFF` and compare against SYSTEM.APPLE bytes 12288–16383.

Explicit physical `main` reads were used for zero page and the `$4000` load.
Use active mapped reads for language-card memory; ordinary physical main RAM is
not a substitute for the selected language-card bank.

## Remaining architecture work

- Trace subsequent directory reads and alternate directory selection. The first
  directory read is now confirmed as an explicit block-79 request (see below).
- Identify code-file segments and their procedure dictionaries, including files
  on disk 2 that have no local directory record.
- Determine the exact p-code instruction dialect from segment metadata and the
  running native interpreter. Names, copyright strings, or another platform's
  port are insufficient to identify it.
- Establish native and bytecode entry points, runtime patches, and the complete
  memory map before choosing final reconstruction formats.

The [UCSD cross-tool source](https://github.com/jdykstra/ucsd-psystem-xc), inspected
at commit `397cf201ddf22ca25a82d0ad5401e5d70a38f849`, provides code-file and segment
format references (`lib/codefile/file/ii_1.*`, `lib/seginfo.*`). It has not yet
been built or validated against these files. Several observed segment headers
have zeroed name fields and metadata that require investigation; generic tool
acceptance must not be assumed. The PRD's Wizardry reference uses its own
Pascal version and supplies context, not a SunDog dialect identification.

An attempted MAME Lua memory-tap probe produced empty logs despite successful
reference gameplay; it did not establish any execution evidence and was not
retained as a project tool. The confirmed observations above come from apple2ts
breakpoint receipts and memory reads.

## Runtime initialization (step 04b)

The continuation of that same private emulator session is recorded in
`reference/runtime-init.json`. Run `python3 tools/verify_runtime_evidence.py`
to compare its five captured source ranges with the original disks.

Bank-1 `$D152` jumps to common-memory `$F269`. That routine copies five pages
from `$F290`–`$F78F` to `$6800`–`$6CFF` and jumps to `$6800`. All 1,280 bytes
at the destination were verified before execution. Absolute references within
this initialization code use both its copied addresses and its original
language-card addresses; disassembling it only at `$F290` is misleading.

The initialization begins by clearing `$0000`–`$1FFF` (static loop at `$680A`).
At `$69EB`, it pushes literal `$4F` as the low block number for the `$FF12`
read service. At the return breakpoint `$6A02`, all 512 bytes at `$6000` match
disk-1 block 79. Thus this initial directory lookup needs no block-2 remapping.
This observation does not establish the behavior of later directory calls.

The directory search finds SYSTEM.PASCAL starting at block 251. At `$6B32`,
the 512-byte header at `$6000` matches block 251, and `$84/$85` contains `$00FB`.
The check at `$6B15` masks the header's version bits with `$E0` and requires
`$A0`, i.e. segment format version 5. This is consistent with Apple Pascal 1.2
in the independently researched [Apple Pascal technical reference](https://www.mgsdl.com/apple-pascal-notes.html).
It establishes the required segment version, not blanket compatibility with
an off-the-shelf UCSD II.1 disassembler.

The loop at `$6B34` constructs a 16-entry table at `$BE3E`: each six-byte
record contains device 4, absolute disk block, and segment byte length. It adds
the file's block-251 base to the relative block numbers in the header.
Initialization then loads header slot 15 and slot 0. At `$6BBA`:

| Part | Disk-1 source | Memory | Verified bytes |
| --- | --- | --- | ---: |
| Header slot 15 | Block 259 | `$BC72`–`$BD1B` | 170 |
| Header slot 0 | Blocks 252–258, first 3,124 bytes | `$F248`–`$FE7B` | 3,124 |

Loading slot 0 overwrites the original language-card initialization code. This
explains why it had to be copied to main RAM first. At `$6C43`, the p-code
instruction pointer `$58/$59` is `$F248`, and `$6000`–`$6C30` has been cleared
to zero, including most of the copied initialization code. The final jump goes
to bank-1 `$D293`, whose dispatcher reads an opcode through `$58/$59`.
For opcodes with the high bit set, `$D29A` writes the doubled opcode into the
low operand byte at `$D29E` of `JMP ($D000)`. This is intentional self-modifying
dispatch code; the on-disk operand is zero and must stay zero in reconstruction.

To repeat this continuation, start at the bank-1 `$D152` stop above and move
the breakpoint successively to `$6800`, `$6A02`, `$6B32`, `$6BBA`, and `$6C43`,
clearing the preceding breakpoint each time. Use physical main reads for the
copied code and directory/header, and active mapped reads for `$F248` and the
bank-1 dispatcher. No emulated memory or register edits were used.
