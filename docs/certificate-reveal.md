# Registration-certificate reveal routine

Library 26 procedure 7 at `$0772` loads 18 blocks starting at relative block 2
into `$4000`. Library 22 procedure 53 adds 3, selecting disk-1 blocks 5–22.
It then calls `$6000` through the native-call wrapper, library 22 procedure 25.
Thus the first 16 loaded blocks are an HGR page at `$4000`; block 21 starts the
native routine at `$6000`. The routine is reconstructed in
`src/native/certificate_reveal.s`.

The alternative path at library 26 `$0785` loads only the 16 image blocks,
directly to visible HGR page 1 at `$2000`. The certificate artwork can therefore
be shown with or without the animated reveal. The same library source exists on
both disks, but this does not establish the same asset extent on the play side.
Only the supplied disk-1 bytes are classified by this load path here.

## Native code and image consumer

The routine consumes one unused pointer parameter and restores its return
address. It uses the low/high row tables at `$0DC0` and `$0E80`, established by
the [raw screen initializer](raw-screen-init.md). For each incoming image row
0–191, it shifts the appropriate bottom part of the visible screen upward and
copies the new row from `$4000` to the bottom row. Its unrolled copy at
`$6055`–`$611A` moves exactly 40 bytes. The high-byte addition at `$604F` selects
the source image's `$4000` page instead of the visible `$2000` page. Both row
counters stop at 192. Delay loops control the reveal speed.

The complete 307-byte instruction stream ends with RTS at `$6132`. All internal
branches/jumps resolve to decoded instruction boundaries. There are no external
calls or transfers within this stream. The consumer establishes the image's
7,680 display bytes; the 512 holes contain uniform `$80` image-buffer padding.

## Complete first-block classification

| Block-21 offsets | Classification and evidence |
| --- | --- |
| `$000`–`$132` | 307 instruction bytes, reachable from the `$6000` call |
| `$133` | Zero alignment between RTS and the word-aligned native metadata |
| `$134`–`$13B` | Four zero relocation-list counts |
| `$13C`–`$13D` | Backward entry displacement `$013C`, pointing to offset 0 |
| `$13E`–`$13F` | Native attributes: marker 0, lexical level 0 |
| `$140`–`$141` | Procedure-dictionary displacement 2, pointing to `$13E` |
| `$142`–`$143` | Segment number 1, procedure count 1 |
| `$144`–`$1FF` | 188 zero bytes extending the completed native segment to its disk-block boundary |

The procedure dictionary and four relocation lists independently validate this
324-byte native segment. The source retains the metadata even though this call
path invokes the raw address. Padding begins after the explicit segment trailer
and is entirely zero; it is not used to conceal an undecoded native body.

Block 22, also fetched by the 18-block read, is **not** part of this component.
It contains nonzero contents with a separate, unresolved classification. A read
extent alone cannot establish those bytes as padding or executable code.

The strict raw decoder, exact ca65 preparation/adoption comparison, and full-disk
comparison verify the reconstruction. No fresh runtime capture of this reveal
routine is claimed at this checkpoint.
