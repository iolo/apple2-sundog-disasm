# Library26 source recovery

Both active disk variants are recovered:11 p-code bodies and seven native
contracts per variant, accounting for22 targeted bodies and1,822 original
instructions. The native implementations remain assembly. The common Pascal
sources are in [library_26](../../src/pascal/title_and_boot/); select exactly one
disk-specific CONST include, [disk1](../../src/pascal/title_and_boot_disk1/identity.pas)
or [disk2](../../src/pascal/title_and_boot_disk2/identity.pas).

The original [disk1 listing](../../src/pcode/title_and_boot_disk1.s) and
[disk2 listing](../../src/pcode/title_and_boot_disk2.s) include the same
[body](../../src/pcode/title_and_boot_body.inc). Independent reassembly matches each
manifest hash. Comparing the complete binaries confirms that they differ only
inside the20-byte identification string at `$03F7..$040A`; the actual differing
bytes occupy `$03F8..$0404`. The inventory retains both component identities,
references the common reviewed bodies, and records each variant's constants.

| Procedures | Reviewed behavior |
| --- | --- |
| 1 | Original return-only library entry. |
| 2 | Value-caption copy, heap release, caption placement at$4000, and nonreturning native boot transfer. |
| 4 | Forward byte copy between raw addresses, retaining overlap behavior. |
| 5 | Menu rendering, cursor-dependent timeout, unconditional random/input calls, selection, timeout fallback and cursor removal. |
| 6 | Header/seed reads, game checksum, title screen, status messages, selection, bootstrap replacement and reboot. |
| 7/17 | Certificate loading, optional native reveal, character output and original busy-wait loops. |
| 13–16 | Nested title-animation setup, six position pairs, pattern/background calls, sprite phases, sounds and column restoration. |

## Storage and effect order

The shared storage additions expose DATA29 word35 as both an address and a
pointer to text15, and words255–262 as the player caption. They add views without
changing DATA29's size or any existing offsets. Procedure2 copies its value
caption before CSP33 RELEASE. SunDog's vector `$D142` selects `$D6C6`, which
dereferences the supplied pointer-word address into heap pointer$5A/$5B and
clears$BDE6/$BDE7. The subsequent assignment installs address$4000, copies the
caption there, and calls native8. A portable allocator is not substituted.

Procedure5 leaves lasty and timeout conditionally initialized, as in the
original. The random call runs every loop even though its result is otherwise
unused. Private slot12 saves the mandatory input1 poll before the exit test;
short-circuit Boolean evaluation cannot omit it. Timeout selection calls25:8
before assigning choice3. Procedure6 likewise saves both title-screen polls in
otherwise unused private slots4/5. Its header byte0 test is a full comparison
with zero, while stored Boolean words retain low-bit tests.

Procedure6 preserves both four-byte seed copies, all disk read/write arguments,
the special mode-dependent read, the checksum comparison, and the original
selection-to-boot-image mapping. The disk-specific constant compiles as the
original inline string. No disk I/O was executed during this recovery.

Procedure13 retains its34-byte frame. Child14 sets its bounds and calls15,
which accesses13 two lexical levels up and writes each position pair's second
word before its first. Child16 retains its22-byte frame and all animation paths,
including independent restore-flag set/clear tests and the final phase8 draw
using phase7. Procedure7 preserves caption slots3–10 and passes the address of
unused local11 to the reveal overlay. Child17 reads the caption length byte,
retains both delay loops, and rereads each character after output before sound.

## Native contracts

The [native interface source](../../src/pascal/title_and_boot/native_interfaces.pas)
records stack consumption, results, memory effects and dependencies for both
variants. These contracts cover3/8/9/10/11/12/18:

- Checksum3 consumes two argument words plus the four reserved result bytes and
  returns one word. It sums alternating bytes independently modulo256, doubles
  only the low block-count byte, and loops256 pages when that doubled byte is0.
- Boot8 reads$C08A and jumps to$C600 without returning to Pascal.
- Drawing9 writes48 single-byte rows in its original zero/pattern sequence.
- Capture10 copies inclusive byte columns into contiguous memory, descending
  within each row. Sprite11 writes24 rows of four bytes with bit7 set.
- Restore12 writes one byte per row; its source advances by the captured row
  stride. It is not a full-row restore operation.
- Dictionary18 contains internal register-call helpers. Its first entry uses
  the280-byte division table without range checks; any nonzero coordinate high
  byte selects the table's second page. The second entry combines row-low plus
  byte-column without carrying into row-high. These are documented JSR
  contracts, not invented Pascal-call signatures.

Native9–12 use the original row tables at$0DC0/$0E80 and preserve byte wrapping
rather than adding clipping. The additional raw22:25 target$6000 contract is
supported by [certificate_reveal.s](../../src/native/certificate_reveal.s) and
the [existing overlay analysis](../certificate-reveal.md). It consumes but does
not dereference local11's pointer. This target is part of an already-counted
trampoline interface, not an additional native procedure.

## Validation

Both temporary checks at `build/decompile/library_26_disk{1,2}/check.pas` reuse
the existing library declaration/body prefix, with stand-in DATA29/30/31,
one variant constant, the native contracts, and the actual recovered bodies.
They include1/2/4/5/13/6/7 at outer scope;13 includes14/16,14 includes15, and7
includes17. No p-code body is represented by an external declaration.

| Original | Compiled |
| --- | --- |
| 1/2/4/5 | 108/109/110/111 |
| 13/14/15/16 | 112/113/114/115 |
| 6/7/17 | 116/117/118 |

All local sizes, parameter sizes and lexical levels match each original.
All25 string occurrences per variant are retained. Source and emitted bodies
were reviewed against every original path. Focused emitted checks cover RELEASE,
seed copies, mandatory polls/random calls, the reveal argument and character
reread. Native checks cover argument popping, checksum result restoration,
boot transfer, the complete division table and row-address arithmetic.

The reference compiler revision is
`397cf201ddf22ca25a82d0ad5401e5d70a38f849`, with
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`. Both checks compile without
warnings and differ only in the variant literal. Output SHA256 values are:

- Disk1: `5222b4474b573210395f2c719c7542e788f12d85b8ef80d95b5e180f343017e4`.
- Disk2: `2a08858cc0c622a33bbe6d2d92e4805fcb3e2636604eaa2c6a67b80ac09ea3f8`.

Procedure4's15-byte body matches exactly in both contexts, SHA256
`bcd23cfda394e750097c7fbb66ac8798033459e4dd38379d8331532754e8851d`.
Both procedure1 bodies match their two-byte returns. Other byte differences,
including call relocation, data access and private temporary use, are not
treated as equivalence failures or exact matches.

Both maintained fixtures were recompiled after adding the storage views. Their
output hashes are unchanged; only the storage-source hashes in their receipts
were refreshed. Both verifiers pass, with the existing game20 string-capacity
and game21 goto warnings confined to those fixtures. No original assembly,
decoder, reconstruction input or disk changed. Native/runtime linkage and
runtime behavior remain unvalidated. No decompiler or translation tooling was
added.
