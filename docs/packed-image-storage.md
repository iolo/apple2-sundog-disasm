# Retained data after two packed images

The 488-byte tail of the ship-section allocation and the 192-byte tail of the
FLIP DISK image are classified as **data by bounded format inference**. Each
starts on a complete RLE packet boundary with a repeat-zero record, followed
only by zero storage to the established allocation boundary. The classification
combines the neighboring format, exact packet alignment, zero value, storage
pattern and independently established image allocation. It is not a general
rule that unexecuted bytes or arbitrary valid RLE pairs are data.

| Disk-2 location | Complete image bytes | Retained control/value | Zero storage |
| --- | ---: | --- | ---: |
| Blocks 33–36, offset 1560 | 1560 | `$01 $00` (format count 2) | 486 bytes |
| Blocks 0–1, logical offset 832 | 576, starting at logical 256 | `$78 $00` (format count 121) | 190 bytes |

The [ship-image consumer](packed-ship-images.md) explicitly reads four blocks
of image data and selects this allocation as the alternative to the full-ship
image. The full-ship allocation independently has a complete RLE stream followed
by [zero storage](asset-block-storage.md). The [play boot decoder](play-disk-boot.md)
starts its image at `$0900`; the next separately identified payload begins at
logical offset 1024 with the record templates. The boot image's tail stays
within the image storage before that boundary. This does not classify the
separate tail of the native boot sector or the template's last seven bytes.

For both images, the declared counts of consumed packets total exactly 8192.
The final consumed controls are `$3A` (59 zeros) and `$1A` (27 zeros), respectively.
Thus the retained pair does not complete a clipped literal or repeat packet.
Its format interpretation is the same repeat-zero format immediately preceding
it. The remaining bytes are all zero; their preservation uses bounded storage
declarations, without inventing additional rendered pixels.

**Limits of the inference:** the historical compressor and reason it left the
extra pair have not been recovered. These pairs are not asserted to be required
terminators, live fields, checksums, or evidence of a larger image. Both native
decoders finish the HGR page before reading them. Their format run lengths
describe the stored pair, not an additional 2 or 121 pixels in the decoded image.
The source preserves the pairs and zeros exactly. No codec stop condition or
packet-encoder acceptance rule is changed.

## Verification

```sh
python3 tools/test_packed_image_storage.py
python3 tools/packed_image_storage.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The audit checks exact disk baselines, existing asset hashes and manifest owners,
complete consumed packet boundaries, retained records, zero extents, assembled
source and final ownership. Tests verify that appending the retained pair is
still rejected by the image encoder; changing the entire unconsumed tail leaves
the decoded page and consumed length unchanged. Every changed storage byte and
shifted allocation boundary requires a new review. The generated audit is
`docs/reference/packed-image-storage.json`.
