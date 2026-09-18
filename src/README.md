# Source

Reconstructed executable source belongs here. `pcode/system_entry.s` is the
first 36-byte procedure of SYSTEM.PASCAL, rebuilt using the verified encoding
subset in `pcode/encoding.inc`. Run `python3 tools/build_pcode_probe.py` to
assemble it and compare its bytes with the original disk. This is a toolchain
proof now integrated into the incremental disk build.

`native/bootstrap.s` reconstructs all 768 bytes of the native boot component,
including its identified tables and text, padding, and preserved tail bytes.
`native/title_draw.s` reconstructs the next native routine and its scanline tables
at `$4000`–`$43FF`; its source bitmap remains temporary.
`native/pcode_primitives.s` reconstructs the interpreter's alternate bank and
shared comparison tail; see `docs/pcode-native.md` for its boundaries and tables.
`python3 tools/build_disks.py` assembles these components and combines them with
explicitly temporary remaining inputs. See `docs/reconstruction.md` for coverage;
this is not yet the final source-and-assets-only build.

Generated exploratory disassembly belongs under `build/` until its addresses
and code/data boundaries are verified. Most executable regions still await
reconstruction; see `docs/pascal-segments.md` for the structural inventory.
