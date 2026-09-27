# SunDog web remake

Current milestone: an English/Korean visual preview of the original ship,
60 city layouts and 18 world layouts. Gameplay, character creation and saves
are not implemented yet. Source and behavior work continues in
`../docs/remake/behavior-matrix.md`.

From the repository root:

```sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory remake
```

Open `http://127.0.0.1:8000/` using `/opt/google/chrome/google-chrome`.
The folder is self-contained and can be copied to any static host, including
a subdirectory. No package install, build, external font request or backend is
needed. ESM requires HTTP; double-clicking `index.html` is not supported.
Local serving works without internet. A hosted copy does not yet cache for an
offline restart.

Use the preview tabs and previous/next buttons to browse. Select a map tile or
ship point to inspect coordinates. Focus the display and press Enter, then
arrow keys to move the selection. Elsewhere, left/right changes layouts.
Escape returns to the title. Language choice persists when browser storage is
available. Maps are stored layouts, without runtime overlays or inferred rules.

Open `/tests/` (relative to the served folder) for the dependency-free browser
checks. Development export checks:

```sh
python3 tools/remake/source_index.py --check
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
```

SVGs are generated from delivered Apple II assets; see `data/provenance.json`.
Mulmaru is distributed under OFL 1.1; see `assets/fonts/LICENSE.txt` and its
provenance record. This browser preview introduces no claim of new rights in
the original SunDog artwork or game content.
