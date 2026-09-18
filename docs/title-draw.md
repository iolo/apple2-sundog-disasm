# Early title drawing component

The bootstrap loads disk-1 blocks 201–218 at `$4000` and calls `$4000` before
loading the Pascal runtime. This entire 9,216-byte load was verified in the
original [bootstrap capture](bootstrap.md). Step 06a reconstructs its first
1,024 bytes, blocks 201–202, from `src/native/title_draw.s`.

| Memory range | Length | Representation |
| --- | ---: | --- |
| `$4000`–`$41FF` | 512 | Native title-reveal routine |
| `$4200`–`$420F` | 16 | Native scanline/column address helper |
| `$4210`–`$42CF` | 192 | Low bytes of HGR page-1 scanline addresses |
| `$42D0`–`$438F` | 192 | High bytes of those addresses |
| `$4390`–`$43FF` | 112 | Unreferenced tail, preserved with no claimed interpretation |
| `$4400`–`$63FF` | 8,192 | Bitmap source region; still temporary pending asset extraction |

The helper takes A as byte column and X as scanline, and returns the screen
address in `$18/$19`. Both 192-byte tables match the formula:

```text
$2000 + (y & 7)*$400 + ((y >> 3) & 7)*$80 + (y >> 6)*40
```

The reconstructed source emits the tables from this formula. The native caller
adds `$24` to the high address byte for the corresponding source in `$4400`.
Source bytes are copied to HGR page 1 at `$2000`; there is no decompressor in
this component's native code.

The routine begins with byte-column bounds 18–21 and scanline bounds 90–101,
and first copies the center at columns 19–20, scanlines 95–96. It copies strips
around an expanding rectangle, moving the horizontal bounds one byte and the
vertical bounds five scanlines per iteration. Nineteen iterations reach columns
0–39 and scanlines 0–191. The code then returns to the bootstrap at `$0867`.
It does not contain the title's joystick-button wait; that behavior belongs to
later code and must not be inferred from the title image alone.

The routine and helper are contiguous instruction ranges with direct branches
and calls; the following two tables are addressed explicitly by the helper.
The unreferenced 112-byte tail is kept separate in source. The bitmap region,
including non-displayed HGR holes, remains in the temporary remainder and is
not yet claimed as a fully classified asset.

The incremental manifest now replaces four more disk sectors with the assembled
prefix. `python3 tools/build_disks.py` checks its exact component hash, and
`python3 tools/verify_disks.py` confirms both full images are unchanged. Rebuilt
media also repeat the complete MAME play reference, with all six screenshots
matching the originals; see `reference/step06a-build-validation.json`.
