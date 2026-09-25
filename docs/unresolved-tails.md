# Remaining tails: evidence and bounded searches

**Historical research, superseded for acceptance:** the user subsequently
instructed that these 488 bytes be accepted as unidentified data. They are now
preserved as [user-assumed data](user-assumed-data.md); the hypotheses and
evidence limits below remain true, but further research is no longer required.

At step 08aa, **488 disk bytes remain unidentified**. This document records
where current evidence ends and which searches should not be repeated without
a new lead. Neither absence of execution nor failed decoding establishes data.
The [classification ledger](classification-ledger.md) remains authoritative for
disk accounting; no component or byte was adopted in this checkpoint.

## Record-template suffix: 21 mapped bytes

Disk 1 block 22 and disk 2 blocks 2 and 45 each end with
`00 0A 00 22 03 01 00` at offsets 505–511. The documented template consumer
uses eighteen 28-byte records and the selector at offset 504. It provides no
field interpretation for these last seven bytes.

A **hypothesis**, not a classification, is a retained Pascal procedure-1 footer:
the candidate attribute byte would be at 510, lexical level at 511, exit
displacement `$000A` at 506, and entry displacement `$0322` at 508. That implies
an exit at 496 and an entry 294 bytes before this block. The local-size field,
low parameter-size byte, original body, and pointing dictionary are missing or
overwritten. The current byte at 504 is a template selector and must not be
reinterpreted as a historical parameter size.

The seven-byte shape is insufficient to prove a procedure footer. No donor
match was found in the new local disk corpus. A separate structural scan of
27 files extracted from Apple Pascal 1.3 APPLE0–APPLE3 examined 96 valid segment
dictionary occurrences, including repeated files. No p-code footer matched
the candidate's parameter-high/exit-displacement prefix and procedure/level
suffix. This scan does not decode historical procedure instructions or change
the SunDog segment-version rules. A donor with a complete procedure/dictionary,
or a historical writer explaining this boundary, remains a useful next lead.

## Play boot suffix: 63 bytes

Disk 2 block 0 offsets 193–255 contain 59 zero bytes, `$09`, and three zeros.
The reconstructed boot program ends before this range; the following packed
notice begins at offset 256. Current consumers do not establish a role for
the `$09`. Simple byte-sum, XOR and word-sum checks did not establish a checksum
relationship. A numerical resemblance to an address is not pointer evidence.
The new disk corpus contains no exact copy of the first 32 boot bytes, so it
does not establish a boot-template donor either.

## Checksum-allocation suffix: 377 bytes

Disk 2 block 54 offsets 135–511 follow the identified checksum table and routine.
The tail SHA-256 is
`e0475c332163ebe181b1ab80585d4e50242e4b28b00116597e1daac469600945`.
Its current read allocation and checksum coverage do not classify its contents.

Earlier checkpoints tested exact and transformed donor matches, feedback
transforms, and the million-member affine family described in step 08y of
PROGRESS.md. None established a decoder, donor or coherent execution path.
The new probes add:

- Exact 16-byte windows against 149 local 140-KiB disk images, in both file
  order and the DOS-to-Pascal block permutation: no matches. The permutation
  is a search view, not a claim that every corpus image has DOS sector order.
- Twenty-eight cross-byte bitstream variants: optionally reverse each byte's
  bits, then shift adjacent bytes left or right by 1–7 bits. Each output has
  376 bytes. Search their exact 16-byte windows and 15-byte adjacent-XOR and
  modulo-subtraction signatures against 237 assembled, asset and Apple ROM
  inputs: no matches. The latter signatures test necessary conditions for a
  constant XOR/add donor transformation, not general encryption.
- Apply each constant XOR/add key to those variants and score linear legal
  NMOS 6502 instructions, excluding BRK: the maximum is 47 instructions at
  offset 147 after left shift 1, no bit reversal, and addition of 106. This
  run ends at 253 and contains no control transfers. Linear opcode density
  alone is not executable-code evidence; no bytes were classified from it.

Unbounded additional transform searches are not a completion strategy. A
producer, known encoding, complete donor, or independently supported structure
would provide a stronger next experiment.

## Dictionary suffix: 27 bytes

Disk 2 block 89 offsets 485–511 contain 26 zeros and `$A0`. These are offsets
997–1023 within the dictionary allocation. The audited supplement-copy ranges
end before them. Treating `$A0` as a high-bit space or assuming all unused bytes
are padding would add no producer or format evidence. The current
[dictionary workspace audit](dialogue-workspace.md) therefore excludes them.

## Historical protection documentation

Marc Lirette's article in *COMPUTIST* 33, July 1986, printed pages 14–15
([scan](https://www.quartdepomme.fr/quartdepomme/Publication_USA_Apple_World/Pages/US___Hardcore_COMPUTIST_files/COMPUTIST%20N%C2%B0%2033.pdf)),
describes the encoded protection routines and a bypass writing SHIP before
returning. Its 21-byte original sequence at front-side track `$13`, sector
`$07` matches the supplied disk at file offset `$13700`; the published
replacement does not. Page 15 was visually checked because OCR misread the
first original opcode `$68` as `$58`. This establishes only the absence of
that particular patch at that location, not an untouched-disk provenance claim.
The article does not identify any of the remaining tails.

The downloaded scan SHA-256 is
`1c0a56b5b84246d9bfb53f46710842cdbacbb62269a87996292c0c8f0ff1e4dc`;
printed page 15 is PDF page 17. The scan is an external research reference and
is not included as a reconstruction input. The author's
[SunDog page](https://brucefwebster.com/past-projects/sundog/) and the old
[Resurrection archive index](https://sundog.sourceforge.net/id5.htm) were also
checked; neither inspected page supplied a source download for these tails.
This is not evidence that such source does not exist elsewhere.

## Replay and limits

[unresolved-tail-probes.json](reference/unresolved-tail-probes.json) records
each searched input's name, size and SHA-256, plus the negative match sets.
The external corpora are optional research dependencies; they are not shipped
or needed to build the disks. With equivalent local corpora available:

```sh
python3 tools/probe_unresolved_tails.py \
  --disk-root /path/to/local/disk-corpus \
  --rom-root /path/to/apple-rom-zips \
  --pascal-files /path/to/extracted-pascal13-files \
  --output /tmp/unresolved-tail-probes.json
```

Build the project first to populate the assembled-component corpus. The Pascal
files were extracted with `a2kit get -d IMAGE -f NAME -t raw`, preserving their
allocation bytes. The receipt records their identities; reproducing a match
count with a different corpus is not a repeat of the same experiment.
The tool replays the three donor/structural searches, not the separate linear
opcode-scoring heuristic. No search result changes classification automatically.
