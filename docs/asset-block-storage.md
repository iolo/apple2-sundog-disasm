# Bounded zero storage after complete assets

`src/data/asset_block_storage.s` reconstructs 978 disk bytes as explicit zero
storage declarations. These ranges follow complete, independently classified
data payloads within evidenced block allocations. The classification uses the
payload format, consumer extent and allocation boundary together; zero bytes
elsewhere on either disk are not automatically classified.

| Location | Complete payload | Bounded zero storage |
| --- | --- | --- |
| Disk 2 blocks 29–32 | Full-ship RLE image, 1,687 bytes | 361 bytes |
| Disk 1 blocks 188–191 | Identical complete four-block image allocation | 361 bytes |
| Disk 1 block 26 | Four 64-byte save descriptors | 256 bytes |

## Full-ship image allocation

The [ship image consumer](packed-ship-images.md) reads exactly four blocks into
`$4000`. Its native decoder writes the complete 8,192-byte HGR page from the
first 1,687 bytes. The final packet is control `$37` and value `$00`: exactly
56 repeated zero bytes finish the page. It leaves no partially consumed literal
payload. The following 361 bytes are all zero, filling the remainder of the
same four-block data allocation. They are classified as unused zero storage
after the complete image, not additional pixels or compression packets.

The complete 2,048-byte disk-1 allocation, including the image and zero tail,
equals its consumer-backed disk-2 counterpart. No new disk-1 read path is claimed.
The section image at disk-2 blocks 33–36 has a different 488-byte tail beginning
with `$01`. It remains unresolved; this classification does not assign a meaning
to that byte or admit nonzero remnants as padding.

## Save descriptor block

Library 26 procedure 6 reads one block from relative block 23 into `$1600` at
`$0360`–`$0366`; library 22's +3 adjustment selects block 26. The slot checksum
selection immediately afterward computes `$161E + 64*slot` at `$0369`–`$0378`.
Utility initialization independently bounds the descriptor loop to slots 0–3
at `$00D0`–`$00D9`, using `IXA 32` (64 bytes) at `$00DE`.

These [four typed descriptors](save-state-banks.md) end at byte 256. The other
256 bytes in their single-block allocation are all zero and are preserved as
spare descriptor-block storage. This does not extend the slot count or classify
the separate saved-game bank tails, which can contain retained code.

## Validation

```sh
python3 tools/test_asset_block_storage.py
python3 tools/asset_block_storage.py --verify
```

Preparation checks current exact disk hashes, existing asset component hashes,
every payload byte's manifest ownership, precise decoded/record boundaries and
all-zero tails. It assembles 617 bytes of source declarations and maps them to
978 disk bytes, reusing the ship-storage declaration for both copies. Changed
payloads, wrong allocation sizes or any nonzero tail are rejected. Tests cover
these failures and exclusion of the section-image tail. Normal builds use only
the generated source declarations, with no original-image dependency.
