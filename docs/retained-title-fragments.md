# Retained title-image fragments in the disk-control block

Three ranges of disk-1 logical block 83 retain the title bitmap's pixel data.
Each byte maps to `assets/title/title.hgr` at **4096 + block offset**. The
donor is independently classified by its native renderer and bootstrap load;
see [title-bitmap.md](title-bitmap.md). The relationship is an inferred retained
image copy, not a claim that the disk-control consumer renders these bytes.

| Block offsets (end exclusive) | Donor offsets | Bytes |
| --- | --- | ---: |
| `$008–$058` | `$1008–$1058` | 80 |
| `$05A–$0A5` | `$105A–$10A5` | 75 |
| `$100–$161` | `$1100–$1161` | 97 |

All **244 visible bytes** match the donor in all seven pixel bits. The **eight
HGR hole bytes**, block offsets `$078–$07F`, match in all eight bits. Overall,
191 bytes are exact copies; 61 visible bytes differ only in bit 7, the HGR
color-phase bit. This is a continuous spatial correspondence across three
bounded fragments of the same image, including its interleaved row layout and
one padding run. No XOR adjustment to pixel bits or approximate pixel match is
used to classify these 252 bytes. The copied hole's position and exact donor
match identify it as retained image padding.

`assets/retained-title/pixels.json` lists each byte's original block offset,
donor offset, scanline, byte column, seven pixel bits, and separate stored/donor
phase bits. Hole records instead preserve the complete byte. These records
repack exactly to `fragments.bin`, SHA-256
`e11d3928139623d4c98c6b36ffb6b41cb18eae5d4e95305610ff9c76fb5e8bcc`.
The build retains the original phase bits; it does not substitute donor bytes.

The eight-byte [disk-control record](disk-control.md) is a separate component.
Offsets `$058–$059`, `$0A5–$0FF`, and `$161–$1FF` are separately classified as
[252 altered image bytes](retained-title-changes.md). Their long constant-XOR
relationships are not phase changes: the later audit reproduces their pixel
values with a sparse differential 6-and-2 symbol model. The strict same-pixel
classification here is unchanged. The historical copy/write sequence and cause
of the alterations remain unestablished.

## Archive comparison

The archived [clean side-A sector image](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/Sundog%2C%20Frozen%20Legacy%20%28Clean%20Crack%29%20-%20Side%20A.DSK)
and [side-A nibble image](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/Sundog%2C%20Frozen%20Legacy%20side%20A.nib)
have the identical 504-byte block-83 tail and complete title bitmap. Thus they
corroborate the stored fragment but provide no alternate donor that explains
its remaining differences. These archives may share an ancestor; independent
historical provenance is not asserted. Neither is a build dependency.

| Reference | Size | SHA-256 |
| --- | ---: | --- |
| Clean side A DSK | 143360 | `b25c07699a712f8d8fd3dd153a2ea5097a78605fbfcf7eea0704285bdb2a8e7d` |
| Side A NIB | 232960 | `58b70e451dbb8c91af142cbe93f5ca019d727a461c3fd9e6301bf17c25b03cd8` |
| NIB tracks 0–33, decoded and reordered into DOS image order | 139264 | `824a6e9dad9c329f5bba0756d22ad2eb8f7045efb912b39c25ea2e99e1d6e8bc` |
| Complete block-83 tail, offsets 8–511 | 504 | `9a50be44ef7fadbbba5e4754e16080bf11797aa5983eca8c1dc5651aeb6aca92` |

The nibble comparison uses a2kit 4.4.2, `get -t sec -f '0..34,0,0..16'`.
For each track, the returned physical sectors are reordered using
`(0,13,11,9,7,5,3,1,14,12,10,8,6,4,2,15)` to obtain DOS image order. Pascal
block extraction then uses the repository's ordinary logical-sector mapping.
No missing final-track sector contents are invented for this comparison.

## Verification

```sh
python3 tools/test_retained_title_asset.py
python3 tools/retained_title_asset.py --verify assets/retained-title
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Extraction requires an exact rebuilt baseline and the classified title donor.
Verification checks all pixel bits, exact hole bytes, frozen phases, reversible
records, range boundaries, generated metadata and manifest ownership. Mutation
checks reject changed pixel/phase bits, truncation, extension and a wrong donor.
Strict adoption maps only the three reviewed ranges out of temporary storage.
Both disk outputs remain byte-identical, retaining the existing emulator
validation baseline.
