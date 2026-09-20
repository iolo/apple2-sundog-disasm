# Raw buffer transformation routine

`src/native/raw_buffer_transform.s` reconstructs the 93-byte routine at the
start of disk-1 block 156, executed at `$0F40`. Startup segment 7 procedure 4
sets its parent's local 7 to 3904 (`$0F40`) and local 4 to 153. Procedure 5 at
`$01AD` passes that address, count 1, block 153, and read flag 1 to library 22
procedure 53, whose +3 block bias selects block 156. Procedure 7 at `$03B6`
passes the address of data-segment 29 word 56 and `$0F40` to the native call
wrapper, library 22 procedure 25.

The routine consumes its return address and one pointer argument. Four bytes
at that pointer supply a destination page, a block count, an initial additive
value, and an increment. It doubles the block count to count 256-byte pages.
For each byte it performs:

```
memory[address] = (memory[address] + value) & 255
value = (value + increment) & 255
```

After the page loops, it writes `SHIP` at `$1801`–`$1804` and returns. Its
parameter source can also be seen in utility procedure code at `$095E`–`$0979`,
which writes `[88, 4, 251, 185]` to data-segment 29 word 56. This is a concrete
buffer transformation; the final semantics of every affected game-data field
are not claimed. Inverse asset encoding must also account for the explicit
`SHIP` stores, not assume the whole routine is an invertible byte transform.

All 93 bytes on the evidenced entry path are native instructions, with bounded
internal branches and an RTS at offset 92. The next three bytes decode as
`JMP ($0004)` but have no demonstrated entry or consumer yet, so they remain
outside this adopted component. At offset 96, four zero relocation counts,
an entry displacement, native attributes, one dictionary pointer, and trailer
form a structurally valid one-procedure Pascal native segment ending at offset
112. This is evidence for the surrounding layout, not a claim that the remaining
block has been fully classified. The analogous metadata following the raw
screen initializer in block 2 also remains outside its adopted range.

Preparation uses the same strict raw decoder as the screen initializer; generated
source must assemble identically before adoption. No new runtime execution of
this particular routine is claimed. The earlier apple2ts capture reached the
title screen after validating the screen initializer. Subsequent analysis
identifies [encoded native overlays](encoded-native-overlay.md) under both
parameter sets; their entry routines are now separately reconstructed.
