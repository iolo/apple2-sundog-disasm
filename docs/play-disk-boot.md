# Play-disk boot program and FLIP DISK notice

Disk 2 starts with one count byte and 192 bytes of native 6502 instructions.
The Disk II ROM loads this sector at $0800 and enters $0801. The program asks
the slot-six ROM at $C65C to continue loading, then decodes an HGR notice and
waits for acknowledgement before restarting the boot ROM at $C600.

The source is `src/native/play_boot.s`; its evidence recipe and complete
instruction/branch audit are in `src/native/evidence/play_boot.json` and
`docs/reference/raw-modules/play_boot.json`. No unreachable bytes are silently
converted to data. The count at offset zero is explicitly data; every byte at
offsets 1–192 belongs to an instruction. Offsets 193–255 remain unresolved.

## Loading and decoding

At $0801 the code compares $0800 with ten. Below that threshold it adds two,
increments the ROM sector counter at $3D, and jumps to $C65C. Along with the
ROM's own counter increment this requests alternate sectors. On the observed
boot, the count becomes eleven and the first six logical 256-byte sectors are
present at $0800–$0DFF. The count is therefore not the number of loaded pages.

At $0812 the decoder reads the stride at $0900, initializes its input pointer
to $0901, and writes four interleaved planes into $2000–$3FFF. Plane `p` writes
addresses `$2000+p, $2000+p+4, ...`, stopping when the destination high byte
reaches $40. The input cursor continues between planes.

Each control byte encodes `(control & 127)+1` output bytes. With bit seven
clear, the next byte is repeated; with bit seven set, literal bytes follow.
Both kinds stop at the plane boundary even if the control count has not run
out. A repeat consumes its single value byte; a literal consumes only the
values actually written. This clipping matters when repacking original
packet boundaries. The shared codec supports the evidenced strides one and
four and retains packet controls and payloads for exact inversion.

The complete stream is **576 bytes**, including its stride byte, at disk-2
logical offsets 256–831 (block 0 offset 256 through block 1 offset 319).
Its decoded 8,192-byte HGR page shows a floppy icon and **FLIP DISK**. The
following 192 bytes in block 1 are outside the consumed stream and remain
unresolved. The first 505 loaded bytes in block 2 belong to the separately
classified [record templates](working-state.md); its last seven remain unresolved.

At $0897 the program selects HGR, page one and full graphics, switches off
the disk motor, and clears the keyboard strobe. At $08AC it polls the two
button inputs and keyboard strobe. Acknowledgement reaches $08BB, reads
$C08A, then jumps to $C600. The classification does not depend on assigning
a purpose to that final soft-switch read.

## Runtime evidence and reproduction

MAME 0.285, verified `apple2e` ROMs, slot-six Disk II, and an isolated copy of
the rebuilt disk reached PC $08AC without memory/register patches or input.
The paused $0800–$0DFF capture matches the first 1,536 logical disk bytes
except that the count at $0800 changed from one to eleven. Zero-page bytes
$00–$05 are `03 40 40 0B 04 04`: destination $4003, input $0B40, stride four,
and completed plane index four. The live HGR page exactly matches the static
decode, SHA-256 `22fd11bbf71e1e914cdfa73f463a5c3b795fd653981ffb01682a2ba63a146da1`.
The screen capture also visibly shows FLIP DISK. See
`docs/reference/play-boot.json` for capture hashes and configuration.

The owned emulator exited cleanly. This verifies direct play-disk boot and
the decoder; it does not claim the final disk-swap/save/load test suite.
The existing full-game behavior baseline remains applicable because the
rebuilt image bytes are unchanged.

```sh
python3 tools/prepare_raw_component.py src/native/evidence/play_boot.json
python3 tools/play_boot_asset.py --extract assets/play-boot
```

Those maintenance extraction commands require unadopted baseline bytes and
new output paths. Routine checks after adoption are:

```sh
python3 -m unittest discover -s tools -p test_packed_hgr_asset.py
python3 tools/play_boot_asset.py --verify assets/play-boot
python3 tools/build_disks.py
python3 tools/verify_disks.py
```
