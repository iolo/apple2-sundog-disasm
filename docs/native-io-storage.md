# Native disk-state record and spare bank storage

The six bytes at bank-2 `$DC8F–$DC94` retain the standard Pascal disk-state
layout. The formerly unexplained `$DC91` is the second byte of the track-state
field. The following **875 zero bytes**, `$DC95–$DFFF`, are spare storage to
the fixed 4 KB bank boundary. This audit supplies evidence for 876 formerly
provisional bytes already present in `native_io.s`; five other state bytes
already had direct consumers.

## Field provenance and local consumers

Willi Kusche's [Pascal 1.1 listing](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf),
printed page 292, explicitly declares a six-byte group: one slot byte, two
`CURTRK` bytes, and three retry bytes. The group is at `$DFFA` in that release.
The second track byte is storage, even though the byte-oriented driver uses
only the first byte.

The [Apple Pascal 1.2 APPLE3 disk](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/programming/pascal/ucsd/UCSD%20Pascal%201.2_3.DSK)
provides a closer independent binary comparison. Its `SYSTEM.APPLE` has the
same state group at `$DF61–$DF66`, followed by 153 zero bytes to `$DFFF`.
Five bounded instruction windows totaling 148 bytes match SunDog exactly
after changing only nine state-address operands. These include the track
save/restore and seek operations and the slot byte used by disk writing.

| Field | Group offset | Size | SunDog address | Pascal 1.2 address |
| --- | ---: | ---: | --- | --- |
| Write slot offset | 0 | 1 | $DC8F | $DF61 |
| Track storage, low byte used | 1 | 2 | $DC90 | $DF62 |
| Address retries | 3 | 1 | $DC92 | $DF64 |
| Sector retries | 4 | 1 | $DC93 | $DF65 |
| Seek retries | 5 | 1 | $DC94 | $DF66 |

Nineteen decoded SunDog instructions reference offsets 0, 1, 3, 4 and 5 in
this group. The historical record layout accounts for offset 2; no live write
to that byte or widened arithmetic is claimed. The current source preserves
all six initial zero bytes, including this unused part of the track field.

## Allocation boundary

The full native I/O bank is the first 4 KB of the captured `SYSTEM.APPLE` load,
mapped at `$D000–$DFFF`; the independent [bootstrap capture](bootstrap.md)
establishes this fixed bank extent. Its decoded code, control-character table
and handler pointers end before the six-byte state group. That group is the
last payload before a contiguous all-zero remainder ending at the bank boundary.
The ordinary native I/O audit checks all direct/vector code targets against
instruction boundaries and accounts for the preceding tables.

The independently verified historical bank has the same state-followed-by-zero-
storage layout. SunDog moves the state record 722 bytes earlier, increasing the
zero remainder from 153 to 875 bytes while retaining the 4 KB bank extent.
Together, the matched state consumers, complete record boundary, fixed bank
allocation and zero fill establish spare bank storage. This does not assign a
runtime buffer use or a particular historical editing process to those zeros,
and does not classify unrelated disk tails by their zero contents.

## Reproduction

`src/native/evidence/native_io_storage.json` freezes the external disk/file
hashes, five bounded consumer windows, nine operand relocations, the historical
field layout and nineteen local references. The external file is research
evidence only. Its complete 16,384-byte SHA-256 is
`7ce54508b9f1564c47d1db921b530c9702c6e91cee177ccbf89bc40f88a1bd5f`.

```sh
python3 tools/test_native_io_storage.py
python3 tools/check_native_io.py
python3 tools/native_io_storage.py --external-apple /path/to/extracted/SYSTEM.APPLE
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The integrated checker validates the matched consumer windows, all nineteen
references, six state bytes and the full zero remainder. Tests reject changed
state/storage, changed instructions or operands, a missing reference and a
truncated bank. `docs/reference/native-io-storage-audit.json` records the full
native I/O check and this data audit. Source and full disk bytes remain exact;
no new peripheral or emulator execution is claimed.
