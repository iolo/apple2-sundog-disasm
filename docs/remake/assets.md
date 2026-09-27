# Browser asset batch — R02a / R05a

Run `python3 tools/remake/export_assets.py` to regenerate, or append `--check`
to verify committed output. The exporter reads only delivered source assets.
`remake/data/provenance.json` records source and output SHA-256 hashes.

Exports: three HGR-derived SVGs (title/full ship/ship section), 64 city tile
SVGs across four banks, 21 world tile SVGs, 60 live city layouts, 18 raw world
layouts, 64 inventory/cargo name records, and the browser catalog. The four
demo city records are excluded. Stable IDs retain the original record index.

Each SVG is composed of horizontal vector paths from the seven displayed bits
per byte. HGR row addressing uses the existing decoder. Memory holes and the
color-phase bit never become monochrome pixels. Original source bytes remain
unchanged. This first vector pass preserves source silhouettes; it does not
claim a smooth hand-refined redraw or original artifact-color simulation.

The browser preview can display a city using any of the four tile banks. That
choice is illustrative: runtime bank selection, variants, clipping, NPCs and
collision are not yet implemented. World index 13 is shown as stored; the
original later replaces it with generated variants and restores city positions.
Source artwork and map data must not be used as an inferred collision mask.
R05a separately traces the native ship collision consumer; see `ship-movement.md`.
It adds the shared-font player glyph as an external SVG and `ship-walk.json`
with explicit glyph masks, source spawn and packed low-bit ship collision rows.
The exporter now verifies 94 artifacts, including 89 SVGs. Ship collision is
independent of decorative SVG paths; city/world collision remains unresolved.

R05b extends the batch to 119 artifacts, including 113 SVGs. The 24 item icons
compose four bank1 glyphs following library27's renderer, rather than assigning
names from an unlabeled atlas. `ship-inventory.json` contains only verified
deterministic carried/locker/store slots; independent capture checks cover all
44 bytes. See `inventory.md` for source addresses and the campaign boundary.

Mulmaru v1.0's `Mulmaru.woff2` and `LICENSE.txt` were extracted from the pinned
release ZIP. Its source URL and archive/file hashes are in
`remake/assets/fonts/provenance.json`. No runtime network font is used.

R02 remains partial: interaction geometry, semantic place associations, complete
localized item/dialogue content, colored/hand-refined artwork and status icons
belong to the relevant gameplay steps. The current batch supports R03's
explicit asset inspection scene, not a fabricated campaign.
