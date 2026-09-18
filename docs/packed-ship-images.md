# Compressed ship-outline HGR images

Two RLE streams under `assets/ship-images/` decode to complete 8,192-byte HGR
pages. Their monochrome previews show a complete ship outline and a shorter
ship-section outline. These names describe the stored artwork; they do not
assert a particular upgrade or damage state. Later game overlays are separate.

| Asset | Compressed bytes | Packet count | Provenance |
| --- | ---: | ---: | --- |
| `full_ship` | 1,687 | 574 | Disk 2 block 29 onward; identical stream at disk 1 block 188 |
| `ship_section` | 1,560 | 564 | Disk 2 block 33 onward |

## Consumer and byte boundaries

Game 15 sets its image buffer to `$4000` at `$02F4`. At `$0315`–`$032B`, a flag
selects data-segment 29 word 32 or word 32 plus 4. Startup 7 sets word 32 to 26;
library 22 procedure 53 adds 3. The four-block read at `$0333` therefore selects
blocks 29–32 or 33–36. The subsequent call at `$033C` invokes library 24
procedure 5, whose native entry is `$1010`. That decompressor reads the header
from `$4000`, the stream from `$4001`, and writes the HGR page `$2000`–`$3FFF`.
The identical disk-1 stream is classified by complete byte equality to this
confirmed asset, not by assuming all nearby disk-1 content is an image.

Both headers specify stride 1. A control byte's low seven bits plus one give
its run length. A clear high bit repeats the following byte; a set high bit
copies literal bytes. The native output pointer advances by the header stride
and stops at the page boundary, even within a packet. The extractor supports
only this evidenced stride-one case and models the exact consumed extent.
It retains high bits and all HGR memory-hole bytes in the decoded output.

Every adopted byte belongs to the header or a consumed compression packet.
The four-block reads fetch additional bytes after the complete streams: 361
for each full-ship copy and 488 for the section. Those bytes are excluded from
this adoption and remain in the unresolved regions. In particular, the section
has a `$01` immediately after its consumed stream; it is not silently absorbed
as an unexplained terminator or normalized into padding.

## Reproduction and verification

```sh
python3 tools/test_packed_hgr_asset.py
python3 tools/packed_hgr_asset.py --extract build/ship-images-check
```

Each asset includes the original compressed stream, a packet listing, decoded
HGR bytes, a preview, provenance/hash manifest, and adoption recipe. The packet
encoder reconstructs the original compression choices exactly; it does not
recompress pixels into a possibly different stream. Tests cover literal and
repeat packets, high bits, native termination inside the final packet, and
malformed/trailing packet rejection. Extraction checks both copies and exact
packet round trips before writing artifacts.

The previews were visually reviewed as ship outlines. They show monochrome
layout only; artifact colors and later labels/equipment are not simulated.
Normal builds read the compressed streams directly, without original images,
Pillow, or a decompression step. Full-disk comparisons verify all 4,934 adopted
disk bytes. No fresh emulator rendering of these particular images is claimed.
