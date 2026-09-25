# User-authorized data exception: 488 bytes

On 2026-09-25 the user instructed:

> ignore the remaining 488 bytes. assume those bytes as unidentified data.

This explicitly changes the earlier completion requirement for **these exact
488 mapped bytes only**. Their code/data role and meaning remain unidentified;
they are accepted as data by user assumption. No decoder, consumer, donor or
historical producer has been established that proves their classification.
The [earlier research](unresolved-tails.md) remains available without promoting
its hypotheses to evidence. Further classification research on these bytes is
outside the revised required scope.

| Location | Bytes | Preserved contents |
| --- | ---: | --- |
| Disk 1 block 22, offsets 505–511 | 7 | Template suffix |
| Disk 2 blocks 2 and 45, offsets 505–511 | 14 | Two copies of that suffix |
| Disk 2 block 0, offsets 193–255 | 63 | Sparse boot suffix |
| Disk 2 block 54, offsets 135–511 | 377 | Mixed checksum-allocation suffix |
| Disk 2 block 89, offsets 485–511 | 27 | Dictionary-allocation suffix |

`reconstruction/assumed-data/disk1-data.bin` stores seven bytes and
`reconstruction/assumed-data/disk2-data.bin` stores 481 bytes in their existing
manifest order. Their hashes and every physical image/input mapping are frozen
in [user-assumed-data.json](reference/user-assumed-data.json). The checksum tail
has two physical mappings because of sector order. No byte, offset, encoding or
output disk changes. There are no remaining temporary input declarations.

The build distinguishes `user-assumed-data` from evidence-backed
`identified-data`. It checks the acceptance record, exact file size/hash and
complete mapping list. Changed bytes, additional copies or shifted ranges do
not silently inherit this exception. The strict build rejects temporary inputs
as before, but accepts these explicitly recorded data assumptions.

The ledger separately reports 136,686 code bytes, 149,546 evidenced data bytes,
and 488 user-assumed data bytes. Its completion status means every byte is
accounted for under the revised requirements; it does not mean all 488 bytes
have acquired classification evidence. Unknown data or hidden code outside
this bounded exception remain unacceptable.
