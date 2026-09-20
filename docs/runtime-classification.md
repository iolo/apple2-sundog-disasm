# Resident runtime classification checkpoint

All **16,384 unique source bytes** in the five resident native-runtime
components are covered by the existing instruction and data audits. Their
combined count is **12,345 code bytes** and **4,039 data bytes**. The formerly
provisional native I/O storage, initializer payload, high-memory metadata and
interpreter linkage fields now have their own supporting audits.

| Component | Source bytes | Code bytes | Data bytes |
| --- | ---: | ---: | ---: |
| P-code primitives | 4,325 | 3,899 | 426 |
| Native I/O bank | 4,096 | 2,778 | 1,318 |
| Shared native services | 4,523 | 4,212 | 311 |
| Initializer | 1,280 | 1,065 | 215 |
| High-memory services | 2,160 | 391 | 1,769 |

These are **component-source counts**, not total disk ownership counts. Copies
and partial mappings elsewhere on disk must retain their own classification
evidence. The I/O code count includes three separately emitted overlapping BIT
opcode bytes. The initializer and high-memory counts each include one identified
instruction-fragment byte; neither is incorrectly counted as data or as a whole
instruction. Complete instructions continue to be assembled as instructions.

## Reproduction and scope

```sh
python3 tools/build_disks.py
python3 tools/runtime_classification.py
```

The combined checker re-runs the five existing audits and the interpreter-linkage
audit against current assembled components. It checks component kind, size and
manifest hash, exact instruction coverage in declared spans, the existing
control-flow/table/metadata assertions, resolved provisional fields, code/data
totals and complete source mapping. The result must equal the committed
`docs/reference/runtime-classification.json`. Use `--write` only to regenerate
that report after reviewed changes.

The report links each component to its detailed classification documents. This
checkpoint consolidates existing evidence; it does not classify a new disk byte
or prove that every routine executes. External peripheral conventions and some
data semantics remain outside this audit. Full-disk classification, all other
components and final reproducibility/documentation checks remain separate work.
At this checkpoint, 584 disk bytes still have temporary-unresolved ownership.

The [executable inventory](executable-coverage.json) concerns only inventoried
Pascal segments. Its old static remaining-work list was not a current audit of
these resident native components. The inventory now links this separate report
and describes its excluded scope without reporting resolved runtime work as open.
