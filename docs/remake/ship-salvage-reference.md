# Original-game Tractor continuation — R10s

An owned MAME0.285 unenhanced Apple IIe/joystick session on copied media records
the full original Tractor procedure, its cargo copy and return to the main
tactical loop. [Metadata](../reference/remake-salvage-reference.json) retains12
asserted source contexts and26 hashed artifacts. Receipts include removal of
every owned breakpoint, joystick release and terminal exit0.

This is a declared continuation fixture. After the supplied save's recorded
boot and prepared contact, `salvage_reference.lua` prepares R10n's observed
wreck record217/0 (cargo25, quality6, unknown origin, price0), clears only pod
slot2, and redirects the paused main activation's source IP to the original
Tractor case call at Game12 `$148E`. It selects the Guns submenu, clears retained
Comm/firing/contact context and sets range21/counter0.
[Setup](../reference/remake-salvage-setup.json) retains every edit and its before
and after owners. It changes no original instruction bytes and creates no new
Pascal activation manually. The original proc18 entry is observed at `$0FCA`.

Slot1's actual fuel record remains intact. This probe does not prove native menu
selection, a newly won kill, natural encounter generation or ordinary
fresh-character acceptance. R10n separately retains its native kill/wreck vector.
Incomplete, console-race and cleanup-error runs are excluded from this inventory.

| Source stop | Observed result |
| --- | --- |
| Proc18 `$0FCA` | Range21, counter0, phase1, charge68; slot2 empty. |
| Five `$1048` stops after proc12 | Range17/13/9/5/1, drift−4, counter1/2/3/4/5. Proc18 local1 selects slot2. The fifth call advances phase1→2 before the copy. |
| `$1072`, after copy | Slot2 becomes217/0; slot1 unchanged. Wreck/inhibition still present. |
| `$1096`, proc18 return | Parent wreck local27 and flag36 cleared; cargo retained. Screenshot reads “Cargo loaded.” |
| Proc15 `$0F19` | Menu rebuilt after collection; phase2, charge68, counter5. |
| Proc15 `$0F2B` | Its release poll calls proc12 without incrementing354: phase3, charge60, counter5. |
| Main `$1388` | Same phase3/charge60/counter5 and manifest; tactical dispatch resumes. |

RNG bytes `[209,34,130,18]`, clock `[18,21,0,0]`, equipment, hull, condition,
attributes and carried inventory remain unchanged throughout this prepared
continuation. Screenshots and raw source frames retain actual state.

The earlier browser host copied correctly but delayed the return-menu call.
R10s now runs that explicit release poll immediately after successful collection,
without adding elapsed time or incrementing354. Due machinery and post-call
movement retain their existing owners, including fatal due-frame exit ordering.
Newly collected auxiliary fuel can be consumed by this following call; the
preceding pull-loop call cannot use cargo that has not been copied yet. A phase1
counter reset can leave the release poll below the due threshold, so it adds no
power call in that case.

The native-vector campaign regression checks every range, slot1 preservation,
phase3/charge60, unchanged RNG/time, original input immutability and fresh JSON
restoration at partial/completed boundaries. Existing cadence and terminal
regressions remain in the full rule suite.

Reproduce with the [a2-mame skill](/home/iolo/.codex/skills/a2skills/a2-mame/SKILL.md)
and verified unenhanced IIe ROMs:

```sh
python3 tools/remake/capture_salvage_reference.py --output-dir /tmp/new-salvage-reference --rompath /absolute/roms
python3 tools/remake/verify_salvage_reference.py --retain /tmp/new-salvage-reference
python3 tools/remake/verify_salvage_reference.py
```

The runner owns one persistent terminal, waits for matching receipts and actual
debugger stops, and asserts every source IP. Host waits are bounded. Failed
cleanup terminates only its owned child and records the terminal result.

R10 remains in progress for fatal entry/startup and Comm-dispatch contexts,
rare reward224 and ordinary ground/space encounter, equipment, negotiation and
recovery acceptance. This closes the prepared native collection audit; it does
not replace those gates.
