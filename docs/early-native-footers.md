# Native metadata in the bootstrap and title prefix

Two existing source components retained provisional tails before native Pascal
footers were understood. The same dictionary and relocation parsers used for
the [raw block overlays](native-block-tails.md) now validate their metadata.
This audit classifies **48 already source-built bytes as data**; it does not
reduce the manifest's temporary-byte count or claim every provisional region
in these components is resolved.

| Component | Footer offsets | Entry word and destination | Attributes | Dictionary/trailer | Following storage |
| --- | --- | --- | --- | --- | --- |
| Bootstrap, origin $0800 | $02E0–$02EF | At $02E8, value $02E8 → offset 0 | $02EA: native, level 0 | $02EC: displacement 2; $02EE: segment 1, count 1 | Sixteen zero bytes to the verified three-page loader boundary at $0300 |
| Title prefix, origin $4000 | $0390–$039F | At $0398, value $0398 → offset 0 | $039A: native, level 0 | $039C: displacement 2; $039E: segment 1, count 1 | 96 bytes at $03A0–$03FF remain provisional, including final $04 |

Each footer begins with four zero relocation counts in interpreter, procedure,
segment and global order. Its displacement resolves to the component start,
the dictionary resolves to its native attributes, and the trailer consistently
describes one native procedure. The footer starts exactly after independently
identified tables: the bootstrap's two twelve-byte phase-delay tables, and the
title prefix's 192-byte HGR high-address table. All sixteen footer bytes have
explicit structural roles.

The bootstrap's remaining sixteen zeros are bounded allocation storage after
the complete native container, ending at the three-page load boundary confirmed
by the [bootstrap capture](bootstrap.md). This uses the established load extent
and parsed footer, not merely a scan for zero bytes. The fourth boot sector is
outside this component and remains separate work. The title tail's nonzero
ending prevents applying the same complete-zero-storage rule there.

The bootstrap metadata points to its page-count byte at offset zero; the boot
entry is offset one. This retained container metadata is not used to infer a
new execution path through the page-count byte. Likewise, no runtime Pascal
loader use of either footer is asserted. Their structural data classification
does not depend on current execution.

Both assembly sources now emit named fields and symbolic backward displacements.
The title source explicitly labels its remaining 96-byte range as provisional.
`tools/early_native_footers.py` freshly assembles both sources, checks the exact
component hashes, reruns the dictionary/relocation parsers and records each data
field and remaining provisional extent. The machine-readable audit is
`docs/reference/early-native-footers.json`.

```sh
python3 tools/test_early_native_footers.py
python3 tools/early_native_footers.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests reject damaged relocation counts, displacements, attributes and trailers,
and nonzero bytes in the newly classified bootstrap storage. Both components
and complete disks retain exact bytes, so existing runtime captures remain
applicable; no new emulator execution is claimed.
