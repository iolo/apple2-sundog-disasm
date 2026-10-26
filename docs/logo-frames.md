# Animated SUNDOG letter frames

`assets/logo-frames/` contains the six eight-frame groups loaded from disk-1
blocks 67–78 for the startup/menu animation. Each group develops one letter of
`SUNDOG`, confirmed by visual inspection of the extracted atlas. There are
48 records of 128 bytes: a 28×24 bitmap in the first 96 bytes, followed by
32 zero bytes of record padding. The entire 6,144-byte allocation is classified
as data, with 4,608 bitmap bytes and 1,536 explicitly checked padding bytes.

`frames.bin` retains the full records. `rows.json` gives all four source bytes
of each bitmap row. The atlas shows seven low-order pixels per byte, left to
right, with the rows in stored order. Source high bits are preserved even
though the renderer forces bit 7 high before writing video memory. The preview
is monochrome and does not emulate Apple II artifact colors or animation timing.

## Loader and native renderer

All offsets below are relative to `src/pcode/title_and_boot_body.inc`.

- Procedure 14 at `$0068`–`$006E` reads twelve blocks into `$4000` using
  relative disk block 64. Library 22 procedure 53 adds three, establishing
  disk-1 blocks 67–78. Procedure 13 calls the setup and animation procedures
  at `$01C0`–`$01C2`.
- Procedure 16 iterates six letter groups at `$00D1`–`$00DA`. The native
  drawing call is procedure 11, reached at `$0125`/`$012D` with letter index,
  frame selector, x position, and y position. The y origin is 44.
- Native procedure 11, `$0960`–`$0974`, constructs the source pointer as
  `$4000 + letter*1024 + selector*128`. The selector is split between pointer
  bit 7 and the high byte; the letter index is multiplied by four pages.
- `$0983`–`$0988` calculates the final row as y+23. The loop at `$0995`–
  `$09B7` copies four bytes per row, increments the source pointer by four,
  and draws through that final row inclusively. `$0999` forces the video
  phase bit with `ORA #$80`. Thus each stored frame supplies exactly 24×4
  source bytes in consecutive row order.

The stored bank contains eight 128-byte records per 1,024-byte letter group.
The animation's control counter also reaches eight; the native formula has
no special ninth-frame storage rule. A call with selector eight would address
the next 1,024-byte boundary. This extraction describes the stored bank and
does not invent an extra record or claim a new dynamic trace of that control
case. The final stored frame in each group is visible in the atlas.

## Padding classification

Every record's last 32 bytes is zero. These spans have the same position and
size in all 48 records, within the renderer's 128-byte array stride and the
loader's exact six-group allocation. They are classified as unused aligned
record storage, separate from the 96 bitmap bytes. This does not classify
arbitrary zero tails elsewhere on the disks. The extractor rejects any nonzero
padding rather than discarding it or assigning it an unsupported meaning.

## Verification

```sh
python3 tools/test_logo_frame_asset.py
python3 tools/logo_frame_asset.py --verify assets/logo-frames
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The maintenance extractor's `--extract` option requires a new repository-local
directory. It checks the current rebuilt image hash, temporary ownership, all
padding, and the complete frame-record round trip before writing artifacts.
Tests cover frame/group strides, last-row boundaries, high-bit preservation,
nonzero padding rejection, and malformed extents. Normal builds read only the
committed asset. The atlas was visually reviewed; no new live animation capture
or completion of final both-emulator checks is claimed.
