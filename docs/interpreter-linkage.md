# Interpreter linkage pointer and address table

The ten bytes at `$D1AD–$D1B6` in `pcode_primitives.s`, formerly described as
an unresolved descriptor, are native interpreter linkage data. They consist of
a pointer to a four-word address table. Step 08n replaces the provisional
field description with named source fields and consumer checks; output bytes
and manifest ownership do not change.

| Field address | Stored word | Meaning established here |
| --- | --- | --- |
| `$D1AD` | `$D1AF` | Base used by the interpreter-relocation pass |
| `$D1AF` | `$D1FB` | Native runtime error entry |
| `$D1B1` | `$FF00` | Base of the high-memory service-entry array |
| `$D1B3` | `$BDDE` | Address of the two-byte I/O-result cell |
| `$D1B5` | `$007E` | Address of the current runtime scratch-pointer workspace |

## Direct local consumer

`native_shared.s` at `$E60D`, `$E618`, `$E623`, and `$E630` calls the same
relocation walker, `$E3FD`, with successive bases for global, segment,
procedure, and interpreter references. The last setup loads `$D1AD/$D1AE`
into zero-page `$92/$93` before the fourth call. The walker reads each backwards
relocation displacement, locates its target word, and adds `$92/$93` to that
word. `$D1AD` therefore supplies the address of the linkage table; its bytes
are not opcodes or a direct jump instruction.

The table's targets also have independent local context:

- `$D1FB` is the existing named `runtime_error` instruction boundary. That
  handler writes the two-byte result at `$BDDE/$BDDF`.
- `$FF00` begins the already audited high-memory array of three-byte service
  entry instructions. The first entry calls the bank-2 service gateway.
- `$7E/$7F` is used as a scratch pointer by native runtime helpers. The final
  word points to that workspace; it is not the workspace contents themselves.

These are address fields, including the two whose targets are data. No new
executable bytes or runtime entry points are introduced.

## Historical correspondence and limits

The [Pascal 1.1 interpreter listing](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/pascal/Apple%202%20Pascal%2011%20PCodeIntDism.pdf)
printed page 21 declares the same pointer and four-word layout at the same
addresses. Its first eight bytes match exactly; its final workspace address is
`$0074`, whereas SunDog stores `$007E`. Printed page 137 shows the corresponding
load of the first pointer before the final relocation call, with the older
runtime's relocated routine and zero-page addresses. These differences are
explicit, not normalized away in the rebuilt output.

All currently inventoried SunDog native procedures have empty interpreter
relocation lists. This evidence identifies the retained runtime linkage
structure; it does not claim a live dereference of every slot, a newly exercised
native procedure, or that every historical linkage feature is still in use.

## Checks

`src/native/evidence/interpreter_linkage.json` records five named fields and
five bounded consumer/target excerpts. `tools/interpreter_linkage.py` checks
component lengths, field values/boundaries, the local relocation sequence and
historical layout correspondence. It is integrated into `check_pcode_native.py`.

```sh
python3 tools/build_disks.py
python3 tools/test_interpreter_linkage.py
python3 tools/check_pcode_native.py
python3 tools/verify_disks.py
```

The two tests mutate every field byte, the relocation source/destination/call
operands, the base-add instructions, target consumers and component lengths.
The full primitive audit still reports 2,146 instructions, 3,899 instruction
bytes, 426 data bytes and 555 direct/vector targets. Its new linkage result is
recorded in `docs/reference/interpreter-linkage-audit.json`. Both disks remain
exact. Other temporary regions and the title's provisional tail remain open.
