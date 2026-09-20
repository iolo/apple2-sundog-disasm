# Inventory and cargo name tables

The two 1,024-byte tables at disk-1 blocks 192–193 and disk-2 blocks 46–47 are
data. Each contains two banks of 32 records: inventory/action names followed by
cargo names. `assets/item-names/demo/` and `assets/item-names/play/` preserve
the distinct variants as `records.bin` and reversible `records.json`.

| Record byte | Classification |
| --- | --- |
| 0 | Counted string length, 0–14 in all 128 records |
| 1–14 | Fixed-width name storage: the counted ASCII text followed by residual bytes |
| 15 | Numeric data byte; cargo consumer reads it independently of the name |

The extracted JSON separates the visible name, residual storage in hexadecimal,
and numeric byte. Residual bytes are part of the typed string storage, including
old text and nontext values; they must not be stripped, decoded as additional
names, or silently zeroed. A zero length stays zero even if the residual field
contains `(nothing)` or `stinger`. This is a data classification of the current
record layout, not a reconstruction of the history of overwritten storage.
The precise interpretation of every numeric value remains open.

## Load paths and field consumers

- Play startup (`src/pcode/startup_7.s`, procedure 5, `$0142`–`$014B`) sets
  segment-29 word 30 to `26+16=42`. Procedure 6, `$032E`–`$0338`, reads one
  block using `word30+1` into `$1600`. Library 22 procedure 53 adds a three-block
  disk bias, establishing physical logical block `42+1+3=46`.
- `src/pcode/library_27.s` at `$0532`–`$0538` installs `$1600` as the inventory
  name-table pointer in segment-31 word 1. `$0284`–`$028A` indexes it using
  `IXA 8`, whose scale is eight 16-bit words (16 bytes), then passes the record
  to procedure 9. That procedure copies the counted string at `$0250`–`$0253`
  and calls library 22 procedure 10 to render it at `$0265`–`$0267`.
- `src/pcode/game_20.s`, procedure 5, sets the cargo-table pointer to `$5800`
  at `$028D`–`$0293`, then compares record 31 (using `IXA 8`) with `cryogens` at
  `$0296`–`$02A7`. If necessary, `$02AB`–`$02B5` reloads it from
  `word30+2+3=47`. Procedure 16, `$0B6F`–`$0B7A`, indexes the same pointer
  with a five-bit cargo ID, then reads byte 15 independently. This supplies
  direct evidence for both the complete 32-record bank and the separate byte.
- Demo startup (`src/pcode/alternate_7.s`, `$00C5`–`$00D0`) sets word 30 to
  `171+18=189`. `$0159`–`$0161` reads block `189+3=192` into `$1600`, using the
  same inventory consumer. `src/pcode/alternate_8.s` at `$05B1`–`$05BB` reads
  the next block, `189+1+3=193`, into `$4000`. Its layout matches the 32-record
  cargo table. The two disk variants are retained separately, not normalized.

Examples of variant differences include `dead component` / `(destroyed)`,
`brainboost` / `mindboost`, and `cloker` / `cloaker`; numeric bytes also differ.
Those differences are original data, not modifications introduced by extraction.

## Verification

```sh
python3 tools/test_item_name_asset.py
python3 tools/item_name_asset.py --verify assets/item-names
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Maintenance extraction uses `--extract` with a new repository-local output
directory. It reads only current rebuilt images, verifies their manifest hashes
and temporary ownership, and checks that decoding and encoding preserve every
byte before writing artifacts and adoption recipes. Tests cover counted strings,
nontext residue, zero-length names, numeric bytes, and malformed records/edits.
Normal builds read the committed binary data. Full output remains exact; no
new live gameplay observation or final behavioral-validation completion is
claimed by this extraction.
