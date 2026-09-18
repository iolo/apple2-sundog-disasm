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
via `$C08C,X` (slot 6's `$C0EC`). Static disassembly is currently exploratory
output under `build/`; it is not yet accepted reconstructed source.

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

- Trace the bank-1 bootstrap and native disk services to identify directory
  redirection (conventional logical block 2 versus stored blocks 79–82).
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
