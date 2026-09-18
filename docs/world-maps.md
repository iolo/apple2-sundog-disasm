# Packed world-map payloads

`assets/world-maps/` contains 18 packed payloads from disk-2 blocks 55–63,
and records the two identical payload copies at disk-1 block 194. Each payload
is 240 bytes representing 40×24 two-bit symbols. Together they replace 4,800
disk bytes. The 16-byte prefix of each 256-byte disk record is excluded and
remains unresolved; decoding starts after that prefix.

## Loader and native format

Startup 7 sets data-segment 29 word 29 to `26+16+10 = 52`, and word 28 to 61,
placing this nine-block bank before the next allocation. Game 21 procedure 28
uses a world index minus one at `$10F2`–`$10FA`. At `$1114`–`$111E`, it reads one
block from `word29 + index//2` with the library's +3 bias, into `$1800`.
At `$1121`–`$112B`, parity selects a 256-byte record. The INC 8 instruction at
`$112E` advances the typed word pointer by 16 bytes (the interpreter's `$D9CB` handler
calls `read_big_word_offset`); `$1133` passes that payload
to library 23 procedure 2. All 18 stored records share this layout; no claim
is made that every record has been visited in the current saved game.

The native decoder uses 24 rows and 40 columns (segment offsets `$0021` and
`$0029`). It consumes the low two bits of each input byte, then rotates that
byte twice; four symbols are consumed before advancing the input pointer.
The carry bits injected at the high end do not affect those four original
low-to-high pairs. The 960 symbols therefore consume exactly 240 bytes.

Each row begins in state 12. For each symbol, the decoder reads the 56-byte
table at segment offset `$006F`, indexed by `state*4 + symbol`; the result is
both the next state and the output tile index. All results lie in 0–13. This
state reset and low-pair-first order are explicitly modeled by the extractor.
Extraction checks its table against the source-built library before decoding.

The subsequent game code adds terrain variants and city locations; see
[world-tiles.md](world-tiles.md). `tiles.json` and the overview show the initial
decoded indices only. The overview was visually reviewed for all 18 maps. Its colors distinguish numeric indices and do not
assign unverified meanings such as land, water, or ownership.

## Lossless source and verification

`maps.bin` concatenates only the 18 payloads. `symbols.json` records the full
40×24 two-bit symbol grid for each; packing those grids reproduces all bytes.
`tiles.json` is the state-decoded output. Multiple symbol transitions can yield
the same tile, so the decoded tile grid alone is not a lossless source. The
original symbols are retained rather than guessed by an inverse state decoder.

```sh
python3 tools/test_world_map_asset.py
python3 tools/world_map_asset.py --extract build/world-maps-check
```

The tool validates both baseline images, the native transition table, the
shared payloads, and all packing round trips. Tests cover bit-pair order, state
reset at row boundaries, known state sequences, and malformed input. The
manifest links each payload to its exact disk/block/byte offset, and adoption
maps each 240-byte span without absorbing the prefixes. Normal builds consume
the packed source asset without reading originals. No new native execution or
live map capture is claimed for this checkpoint.
