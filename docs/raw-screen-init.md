# Raw screen-address initializer

Disk-1 block 2 is mixed native code and data, outside the Pascal segment
inventory. Its first 192 bytes are the high bytes of HGR page-1 row addresses.
The following 105 bytes are a callable native initializer. This component adopts
only these 297 bytes; the rest of the block remains under investigation.

## Load and call evidence

`startup_disk1.s` at segment offset `$0199` calls library 22 procedure 53 with
buffer `$4000`, count 1, relative block 80, and read flag 1. Procedure 53 at
`$0B86` adds 3 to the requested block and uses CSP 5 for reads, so this reads
disk block 83. Startup reads byte 6 of that buffer, subtracts 3, and passes the
result to library 22 procedure 54. The supplied disk-1 byte is 2.

Procedure 54 loads that selected block through the same wrapper into `$0E80`
and invokes procedure 25 with target `$0F40`. Procedure 25 patches its JMP
operand from that argument. Thus the observed disk bytes select block 2,
load it at `$0E80`, and enter it at byte 192 (`$0F40`). These statements follow
the reconstructed instructions and input bytes. The subsequent step-06x apple2ts
capture confirms entry at $0F40 and all 512 loaded bytes. The same startup source on disk 2 does not imply block 2 on that
side contains the same component: startup selection happens before the play-side
swap. Only the verified disk-1 extent is adopted.

## Code and data boundaries

For row `y=0..191`, the initial table byte is the high byte of
`$2000 + (y&7)*1024 + ((y>>3)&7)*128 + (y>>6)*40`. All 192 bytes match this
formula. Drawing routines in library 22 read the table at `$0E80,Y`; for example
native procedure 15 at `$0E83` checks `Y < $C0`, then reads the paired low/high
tables at `$0DC0,Y` and `$0E80,Y`.

The `$0F40` entry removes its native return address and one pointer argument from
the stack. Its first nested loop writes the complementary 192 low-address bytes
to `$0DC0`–`$0E7F`. Its second loop writes low/high halves of 96 linear row
addresses, starting at `$1800` and increasing by 20, to `$0D00` and `$0D60`.
It restores the return address and returns at `$0FA8`. All branches stay within
the decoded instructions. The popped pointer is not used by this initializer.

These consumer and call boundaries distinguish the 192 data bytes from the 105
instruction bytes. The following bytes are not automatically called padding.
The audit and recipe are under `docs/reference/raw-modules/` and
`src/native/evidence/`; `native_raw_source.py` rejects code/data overlaps,
branches into operands, unclassified bytes, and unsupported indirect transfers.
`prepare_raw_component.py` proves the generated source assembles exactly before
writing an adoption recipe. Normal builds read the committed source directly.

Further raw overlays exist. Startup segment 7 loads disk-1 block 156 at `$0F40`
and later calls that address, replacing this initializer. Disk-2 block 83 also
contains native-looking code at a different load address; its consumer and full
extent need separate reconstruction. Neither is counted as completed here.

## Runtime confirmation

`docs/reference/raw-screen-runtime.json` records the continued unpatched apple2ts
reference session stopped at $0F40 and then $0FA8. All 512 bytes at $0E80 match
disk-1 block 2. At the return instruction, all 384 generated table bytes at $0D00
match the 96 linear low/high row addresses and 192 HGR low row addresses. The
stack pointer advances by two bytes, consistent with consuming one pointer
argument while retaining the return address. `tools/verify_runtime_evidence.py`
rechecks these facts. The session then reaches the title prompt and is paused;
no joystick interaction or buffer-transform execution was claimed in this trace.
