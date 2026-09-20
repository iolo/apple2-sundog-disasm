# Disk control record

The first eight bytes of disk-1 block 83 are control data, reconstructed by
`src/data/disk_control.s`. Their image offset is `$A900`; the original bytes
are `00 01 1B 9C 14 A6 02 4F`, SHA-256
`caceb39c7b5f9c9f1707f60a9b659a1e53533250a015ac99ae6a48b5ed04b98d`.
Every field has a direct consumer in already reconstructed code. The other
504 bytes of the block remain unresolved and are excluded from this component.

| Offset | Size | Stored value | Evidence |
| --- | ---: | --- | --- |
| 0 | 1 | 0 | Library 26 procedure 6, `$02DC–$02E1`, tests this byte against zero and retains the Boolean in local 21. `$0695–$069A` stores 255; `$06CD–$06D0` clears it. |
| 1 | 1 | 1 | `$02E3–$02E6` reads the save-slot selector into local 14. `$02F8–$02FD` computes its ten-block save-bank base, `24 + 10*slot`; `$0369–$036F` selects its 64-byte descriptor. |
| 2 | 4 | words `$9C1B`, `$A614` | `$02EF–$02F6` copies four bytes into data-segment 29 starting at word 21. `$04A0–$04A7` copies those globals back into the record. Their detailed meaning is not required for data classification. |
| 6 | 1 | 2 | Startup at `$01A2–$01A9` reads this byte, subtracts three and calls library 22 procedure 54, selecting the screen initializer in absolute block 2. |
| 7 | 1 | 79 | Library 26 at `$02E8–$02ED` reads this byte and subtracts three. `$06AD–$06B3` uses the result as the destination of a directory-block write, selecting absolute block 79. |

Library 26 procedure 6 first reads relative block 80, count one, into `$1400`
at `$02D3–$02D9`, then accesses it through local 2. Library 22 procedure 53
adds the three-block bias, identifying absolute block 83. Startup independently
reads the same block into `$4000` at `$0199–$019F`. The initializer load and
call are documented in [raw-screen-init.md](raw-screen-init.md).

The mode-flag updates write the whole block through library 22 procedure 53
at `$069B–$06A1` or `$06D1–$06D7`. The selected directory is read into the
same buffer only afterward, at `$06A4–$06AA`. These distinct buffer uses do
not make block 83 a Pascal directory or establish the classification of its tail.

The existing [utility-entry capture](reference/utility-entry-writes.json)
independently records four changes at `$A902–$A905`: the persisted globals
change from `1B 9C 14 A6` to `57 0A 23 85`. This locates the observed writes
inside a directly read/written data field. It does not establish the field's
algorithm or claim a new emulator run.

## Verification

The generic component adoption checks that all eight bytes assemble exactly
and were previously owned exclusively by the temporary component. Normal builds
read only the committed source and configuration. Run:

```sh
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Both full disk images must retain their reference hashes. The existing boot
and utility captures remain applicable to this identical-output checkpoint;
final save/load and dual-emulator validation remain separate work.
