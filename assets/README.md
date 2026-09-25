# Extracted assets and identified data

The build uses 32 identified-data components, totaling 101,404 mapped disk
bytes. Each component has a format, hash and classification-evidence document
in the [reconstruction manifest](../reconstruction/manifest.json). The table
below covers all 31 asset manifests; saved-game payloads and slot records share
one manifest. Retained variants have separate evidence from their live donors.

| Asset directory | Contents / evidence |
| --- | --- |
| [title](title/) | HGR title page and preview; [consumer](../docs/title-bitmap.md) |
| [font](font/) | 128 glyphs, atlas and reversible rows; [format](../docs/shared-font.md) |
| [certificate](certificate/) | Registration HGR artwork and preview; [consumer](../docs/certificate-bitmap.md) |
| [play-glyphs](play-glyphs/) | Two glyph banks; [consumers](../docs/play-glyphs.md) |
| [ship-images](ship-images/) | Two RLE images, packets, decoded pages and previews; [codec](../docs/packed-ship-images.md) |
| [play-boot](play-boot/) | RLE FLIP DISK notice; [decoder](../docs/play-disk-boot.md) |
| [tiles](tiles/) | Four tile banks and reversible rows; [renderer](../docs/tile-banks.md) |
| [world-tiles](world-tiles/) | World tile bank; [renderer](../docs/world-tiles.md) |
| [world-maps](world-maps/) | Eighteen packed maps and decoded views; [format](../docs/world-maps.md) |
| [city-maps](city-maps/) | City payloads and views; [format](../docs/city-maps.md) |
| [item-names](item-names/) | Demo/play record variants; [consumers](../docs/item-names.md) |
| [save-states](save-states/) | Four game payloads and slot descriptors; [layout](../docs/save-state-banks.md) |
| [working-state](working-state/) | Globals and record templates; [consumers](../docs/working-state.md) |
| [logo-frames](logo-frames/) | Animated logo data; [renderer](../docs/logo-frames.md) |
| [interaction-window](interaction-window/) | Window bitmap and position fields; [format](../docs/interaction-window.md) |
| [interaction-records](interaction-records/) | Bounds, styles and parameters; [consumers](../docs/interaction-records.md) |
| [dialogue-dictionary](dialogue-dictionary/) | Base dictionary; [format](../docs/dialogue-dictionary.md) |
| [dialogue-messages](dialogue-messages/) | Referenced message records; [script consumers](../docs/dialogue-scripts.md) |
| [dialogue-bank-storage](dialogue-bank-storage/) | Remaining messages and bounded storage; [layout](../docs/dialogue-bank-layout.md) |
| [map-record-prefixes](map-record-prefixes/) | Retained map prefixes; [evidence](../docs/map-record-prefixes.md) |
| [alternate-glyphs](alternate-glyphs/) | Retained glyph variant; [evidence](../docs/alternate-glyphs.md) |
| [retained-font-half](retained-font-half/) | Retained font rows; [evidence](../docs/retained-font-half.md) |
| [retained-tile-rows](retained-tile-rows/) | Retained tile rows; [evidence](../docs/retained-tile-rows.md) |
| [retained-title](retained-title/) | Retained title fragments; [evidence](../docs/retained-title-fragments.md) |
| [retained-title-changes](retained-title-changes/) | Altered retained image fragments; [bounded inference](../docs/retained-title-changes.md) |

The ordinary build reads the accepted raw/packed representations directly;
asset documents describe extraction and inverse encoders. Pillow is needed
for image-preview generation, not ordinary disk assembly. The delivered
previews can be inspected without regenerating them.

Sound-producing instructions remain source code: speaker accesses occur in
`src/pcode/library_22.s` at `$0D50/$0D5E`, `library_24.s` at `$0F07/$0F19`, and
in native I/O, viewscreen and warp routines. These are not sampled audio files.
No separate sound asset has been established by the current classification;
audio equivalence has not been tested. This does not classify any unknown tail.

The user has accepted the last 488 unidentified bytes as data. They are kept
separately under `reconstruction/assumed-data/`, outside these evidence-backed
assets. Their exact [acceptance scope](../docs/user-assumed-data.md) is recorded;
no temporary inputs remain. See the [classification ledger](../docs/classification-ledger.md)
and [delivery checklist](../docs/delivery-checklist.md).
