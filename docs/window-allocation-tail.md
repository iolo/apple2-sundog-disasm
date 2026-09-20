# Interaction-window allocation storage and retained identifier prefix

The remaining 126 bytes of disk-2 blocks 37–40 are classified as **110 bytes
of bounded zero storage and a 16-byte retained Pascal identifier-record prefix**.
Together with the already extracted bitmap and saved positions, all 2,048 bytes
of this allocation now have explicit data classification.

| Allocation offsets | Size | Data role |
| --- | ---: | --- |
| 0–1919 | 1920 | Previously extracted 96-row bitmap |
| 1920–1999 | 80 | Zero storage between the bitmap and saved-position fields |
| 2000–2001 | 2 | Previously extracted saved-position fields |
| 2002–2031 | 30 | Zero storage between the saved positions and retained record |
| 2032–2047 | 16 | Retained identifier-record prefix |

The [window consumer](interaction-window.md) fixes the bitmap extent at 96 rows
of 20 bytes, the position addresses at 2000 and 2001, and the four-block read
extent. The zero ranges are bounded gaps within that identified data allocation,
ending at distinct known fields or the separately identified record fragment.
They are checked completely as zero. They are not additional displayed rows,
and no unverified capacity of a historical array is asserted. This is a
specific storage classification from the full layout, not a rule that every
unreached zero on the disk is data.

## Retained compiler-record evidence

The final 16 bytes are `49 4E 46 49 4C 45 20 20 4E 48 22 48 06 48 3C 33`.
They have the layout of the common prefix of a UCSD Pascal compiler IDENTIFIER:

| Prefix offset | Field | Stored value |
| --- | --- | --- |
| 0–7 | NAME, eight-byte padded ALPHA | `INFILE  ` |
| 8–9 | LLINK | `$484E` |
| 10–11 | RLINK | `$4822` |
| 12–13 | IDTYPE | `$4806` |
| 14–15 | NEXT | `$333C` |

The [compiler's record declaration](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/compiler/compglbls.text#L220)
defines the eight-character name followed by these four pointer fields; the
variant tag and class-specific fields come afterward. All four stored pointer
words are even main-memory addresses. [ENTERID](https://github.com/jdykstra/ucsd-psystem-os/blob/f0a8e66f6aff82e95207300e11e310155d2d1599/compiler/procs.a.text#L149)
uses the name and left/right tree links. The Apple Pascal native TREESEARCH
implementation independently confirms the relevant byte layout: compare eight
name bytes, then load a link word at offset 8 or 10. See the
[interpreter listing](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf),
printed pages 146–148, especially `$E652`, `$E662` and `$E679` on page 147.

The padded identifier, four aligned words in the documented order and the
independently implemented name/link layout support **retained record data**.
This is a structural classification inference. The original compiler session
and pointer targets have not been recovered. The variant tag lies beyond the
surviving fragment, so no variable class, declared type, file object, complete
record length or current SunDog use is invented. In particular, the letters
INFILE are not taken as evidence that the game opens a file with that name.
The fragment remains separate from the image and saved-position fields.

## Source and verification

`src/data/window_allocation_tail.s` names the record fields and declares both
zero ranges explicitly. It reconstructs the two disjoint tail intervals without
duplicating the already extracted position bytes. The record field listing is
reversible; the full allocation and asset hashes are frozen in
`docs/reference/window-allocation-tail.json`.

```sh
python3 tools/test_window_allocation_tail.py
python3 tools/window_allocation_tail.py
python3 tools/window_asset.py --verify assets/interaction-window
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The audit checks the independently classified bitmap/state bytes, both zero
ranges, complete retained prefix, field representation, fresh ca65 assembly and
manifest ownership. Tests reject every altered tail byte, shifts across either
known boundary and truncated/extended buffers. Source adoption and full-image
comparison preserve exact disk bytes; no new runtime use of these stored gaps
or historical compiler pointers is claimed.
