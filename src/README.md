# Source

Reconstructed executable source belongs here. `pcode/system_entry.s` is the
first 36-byte procedure of SYSTEM.PASCAL, rebuilt using the verified encoding
subset in `pcode/encoding.inc`. Run `python3 tools/build_pcode_probe.py` to
assemble it and compare its bytes with the original disk. This is a toolchain
proof; no full source-to-disk build is available yet.

Generated exploratory disassembly belongs under `build/` until its addresses
and code/data boundaries are verified. Most executable regions still await
reconstruction; see `docs/pascal-segments.md` for the structural inventory.
