# Data prefixes of the packed map records

`assets/map-record-prefixes/` classifies the **832 prefix bytes** omitted by the
initial world/city payload extractions: twenty 16-byte world-map prefixes and
sixty-four 8-byte city-map prefixes. Each is a bounded data field within a
record whose stride and payload access are independently established by the
consumer code. Precise prefix-field meanings remain unspecified; no executable
content or arbitrary file remainder is included in this asset.

## Record-layout evidence

The [world-map audit](world-maps.md) establishes the nine-block play bank at
blocks 55–63, a 256-byte record stride, and the explicit eight-word advance
at game-21 offset $112E before the native decoder consumes exactly 240 bytes.
Disk-1 block 194 contains two matching complete records, including their prefixes.
The [city-map audit](city-maps.md) establishes a 128-byte stride and the explicit
four-word advance at game-21 $0F65–$0F74 before reading its 120-byte packed field.
The independently traced demo consumer uses the same city layout in block 195.

Classification rests on the repeated record structure, explicit field offsets,
whole-record allocation, known adjacent payloads and the prefix patterns below.
It is not inferred solely from an absence of observed execution. Preparation
requires every prefix to be followed by the exact map payload already extracted,
and checks that payload's actual manifest ownership and source offset. It does
not absorb bytes outside these fixed records or classify unrelated zero runs.

| Record family | Prefix contents |
| --- | --- |
| World index 0 and indices 10–17 | `$08,$07`, followed by fourteen zero bytes |
| World index 1 | `$08,$07`, followed by `33 C4 FF FF FF FF FE FF FF EF 7F C0 FF FF` |
| World indices 2–9 | `$08,$07`, followed by seven `$D5,$AA` pairs |
| Two disk-1 world records | Exact prefix copies of world indices 0 and 1 |
| Play city index 0 | `$01,$00`, followed by six zero bytes |
| Play cities 1–58 and four demo cities | `$06,$05`, followed by six zero bytes |
| Play city index 59 | Eight `$11` bytes |

These are descriptions of stored data, not invented field semantics. The first
two bytes are recorded losslessly as a little-endian word and the remaining
bytes as explicit prefix storage. No meaning such as a coordinate, dimensions,
version, executable address, or official format identifier is assigned to that
word. The exceptional world bit pattern and last-city fill are retained exactly.

## Source and validation

The asset contains `prefixes.bin`, reversible `fields.json`, a record manifest
linking every prefix to its independently classified payload, and an adoption
recipe. The build reads the classified data directly and does not read originals
or invoke extraction. Existing world/city payload assets remain separate.

```
python3 tools/test_map_prefix_asset.py
python3 tools/map_prefix_asset.py --verify assets/map-record-prefixes
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The extractor checks both rebuilt-image hashes, both existing payload assets,
every record's payload bytes/ownership, all reviewed prefix patterns, and exact
field inversion. Tests reject changed patterns, wrong record identities, invalid
sizes and out-of-range fields. Both demo world prefixes equal their play-side
counterparts; all 84 prefix records are explicitly represented.

Together with the previously extracted payloads, this completes data ownership
for **13,312 disk bytes** of world and city map records. It does not identify
precise unused-field meanings, establish that every stored map is visited during
play, or replace the final live validation in both emulators.
