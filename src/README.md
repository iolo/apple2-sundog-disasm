# Source

Reconstructed executable source and typed data declarations belong here. `pcode/system_entry.s` is the
first 36-byte procedure of SYSTEM.PASCAL, rebuilt using the verified encoding
subset in `pcode/encoding.inc`. Run `python3 tools/build_pcode_probe.py` to
assemble it and compare its bytes with the original disk. This is a toolchain
proof now integrated into the incremental disk build.

`pcode/startup_disk1.s` reconstructs the complete six-procedure disk-1 startup
segment, including case tables, procedure attributes, and dictionary. See
`docs/startup-pcode.md` for decoder scope and verified interpreter formats.

`native/bootstrap.s` reconstructs all 768 bytes of the native boot component,
including its identified tables and text, padding, and preserved tail bytes.
`native/title_draw.s` reconstructs the next native routine and its scanline tables
at `$4000`–`$43FF`; its bitmap is extracted under `assets/title/`.
`native/pcode_primitives.s` reconstructs the interpreter's alternate bank and
shared comparison tail; see `docs/pcode-native.md` for its boundaries and tables.
`native/native_io.s` reconstructs bank-2 disk, device, and console services;
see `docs/native-io.md` for overlapping instructions and runtime operand patches.
`native/native_shared.s` reconstructs common procedure/segment handling, numeric
and device routines, and the initializer-copy stub; see `docs/native-shared.md`.
`native/native_init.s` reconstructs the five-page initializer at its copied
execution address; `docs/native-init.md` records original-address aliases and
the unresolved 42-byte initialization payload.
`native/native_high.s` reconstructs the final bank-switch/service stubs and
preserved tail; see `docs/native-high.md`. These five runtime components cover
the entire SYSTEM.APPLE image, with provisional code/data boundaries and
unresolved data meanings documented.
`python3 tools/build_disks.py` assembles these components and combines them with
explicitly temporary remaining inputs. See `docs/reconstruction.md` for coverage;
this is not yet the final source-and-assets-only build.

The remaining `pcode/` sources now reconstruct the utility module, shared library
segments 25/27/28, startup segment 7, alternate-startup modules, system segments
1–6, and the compatible game segments. `library_23.s` combines one p-code and
three native procedures with explicit native relocation lists. Module audits in
`docs/reference/pcode-modules/` record code/data classification and provenance.

Generated exploratory disassembly belongs under `build/` until its addresses
and code/data boundaries are verified. `docs/executable-coverage.json` tracks the
complete inventoried-segment ownership and explicitly excludes unresolved
non-segment regions from its completed count. See `docs/pascal-segments.md` for the inventory.

`data/pascal_header_tables.s` reconstructs the first 288 bytes of all eight
inventoried segment headers as data tables. Header tails are excluded; see
`docs/pascal-header-tables.md` for evidence and scope.

`native/raw_screen_init.s` reconstructs the callable screen-table initializer
and its HGR high-address table from disk-1 block 2. This raw code has no Pascal
procedure dictionary. See `docs/raw-screen-init.md`; other raw overlays remain.

`native/raw_buffer_transform.s` reconstructs the evidenced 93-byte entry path
of the raw block-156 transformation routine. Its trailing indirect-jump candidate
and metadata remain separately tracked; see `docs/raw-buffer-transform.md`.
