# Play-side final track: sector-image fill

Disk 2 logical blocks 272–279 (image offsets `$22000–$22FFF`, track 34) are
4,096 zero bytes. Step 08m classifies them as **data: sector-image container
fill for a non-sector track**, reconstructed by `src/data/play_disk_final_track.s`.
This conclusion uses independent track-format and neighboring-content evidence,
not zero contents alone or an invented disk-2 filesystem directory.

## Independent disk representations

The [archived version-2 disk-2 ZIP](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/sundog_ver2_disk2.zip)
contains `SUNDOG2.DSK`, exactly matching the supplied disk-2 SHA-256. Two other
representations in the same archive provide additional evidence:

- The [side-B nibble image](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/Sundog%2C%20Frozen%20Legacy%20side%20B.nib)
  is 232,960 bytes: 35 tracks of 6,656 disk-stream bytes. a2kit 4.4.2 decodes
  all 544 standard sectors on tracks 0–33. After converting physical-sector
  order to DOS-image order, **532 sectors match exactly**. All 378 differing
  bytes are on track 6, within the known working-state area. This identifies
  the corresponding play-side layout without assuming every saved state is equal.
- All 32 sectors on tracks 32–33 match exactly. They contain the final segment's
  allocation at logical blocks 256–271, hash
  `69d4b9319c1bc0953edf4d0b57df1781bcec92beaead214b7bb36e282e42a796`.
- Nibble track 34 is entirely `$FF` except for 30 recorded bytes. It has **no
  `$D5,$AA,$96` address markers and no `$D5,$AA,$AD` data markers**, including
  across the circular track seam. a2kit's request for track 34 sector 0 returns
  `SectorNotFound`. Thus its raw stream supplies no standard 256-byte sectors
  to decode into the DSK's final 4,096-byte region.
- The [clean-crack side-B DSK](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/Sundog%2C%20Frozen%20Legacy%20(Clean%20Crack)%20-%20Side%20B.DSK)
  independently has the same complete final segment allocation followed by
  the same 4,096 zero bytes.

The combination supports a representation-level fill classification. It does
not establish which converter produced the supplied file, nor does it equate
zeros with the nibble track's actual stream bytes. The complete non-sector
track is retained as a sparse reference record (default `$FF`, 30 exceptions)
and checked against its SHA-256. No claim is made that the DSK preserves raw
copy-protection track contents; the task's exact input is the supplied DSK.

## Local bounds and code/data distinction

The play header at block 140, slot 15, locates segment 21 at relative block 116
(absolute 256), length 8,132. Its valid 41-procedure dictionary ends inside
block 271. The block-rounded allocation ends at 272, the track-34 boundary;
no declared nonempty segment in this header extends past it. The complete
preceding two tracks are already reconstructed and match the nibble reference.

This header bound is corroboration, not a claimed complete filesystem map.
Disk 2 has no conventional Pascal directory header. Likewise, raw disk
protection routines elsewhere are not evidence of executable instructions in
this zero-filled sector representation. They remain separately classified and
reconstructed. This checkpoint changes only the final 4,096 sector-image bytes'
input ownership, and changes no emitted byte.

## Verification and reproduction

`src/data/evidence/play_disk_final_track.json` freezes full reference-image hashes,
URLs, track geometry, the sparse raw-track content, matched allocation hash,
and sector-comparison results. `docs/reference/play-disk-final-track.json`
records the successful audit. External files are evidence only, never ordinary
build dependencies.

```sh
python3 tools/test_play_disk_final_track.py
python3 tools/play_disk_final_track.py
# Optional independent replay with the downloaded references:
python3 tools/play_disk_final_track.py --external-nib /path/to/side-b.nib \
  --external-clean /path/to/clean-side-b.dsk
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The local checker validates image geometry, segment boundary/dictionary,
neighboring tracks, circular absence of sector markers, exact zero fill and
fresh assembly. The external check verifies both full-image hashes, decodes
all readable tracks with a2kit, recomputes the exact correspondence, and repeats
the missing-sector result. Tests reject truncation, nonzero fill at either end,
changed neighbors, changed segment bounds, duplicate sparse records and sector
markers crossing the track seam.

Both full disks remain exact. The recently recorded MAME and Apple2TS gameplay,
save/reload and utility baselines therefore remain applicable. Other temporary
and provisional regions are not classified by this evidence.
