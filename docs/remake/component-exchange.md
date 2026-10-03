# Component exchange — R05f

At an engineering bay, select a component, choose Move / exchange, then choose
a carried slot or compatible installed socket. An occupied destination exchanges
both items. Empty carried slots let you remove components; carried components can
repair an empty, destroyed or shunted socket. The ship's locker contains five real
shunts. Parts can also be recovered from another unit or system through pockets.

Selection is non-destructive. Escape or Cancel cancels a pending move; changing
frames or leaving the panel also cancels it. Both exchanged destinations must fit
before anything changes. Incompatible swaps leave every byte intact. Empty source
slots and remote bay access are rejected. Inspection and exchanges remain paused,
following the browser inventory convention. No invented per-part time cost is
added; this is not a simulation of the original live cursor/tick timing.

## Correction to R05e's spare interpretation

The four bytes at equipment record offsets20–23 are **standard socket requirements**,
not spare inventory. Game14 procedure4 `$02D9–$032E` draws four units of four
components using five-byte strides, stopping before this table. Procedure11
`$073B–$0784` and library24 procedure8 `$01A4–$01E0` read that table for fit and
performance comparisons. Game14's engineering writes map only the sixteen visible
component slots to offsets0–18. There is no fifth removable component row.

R04d/R05e called the table `spares` and R05e displayed it as an inspection row.
This checkpoint corrects the UI to show actual carried inventory instead and
displays the standard requirement when inspecting a socket. Recipe2's serialized
`spares` field name stays unchanged for exact replay and legacy-save compatibility;
it is immutable metadata in both creation and active equipment records. It cannot
be selected as an inventory source. Earlier validation receipts document historical
tests and do not establish the old spare interpretation.

## Fit and performance rules

Game14 procedure11 `$072C–$0789` permits the standard required type, shunt23 in
sockets1–3 (zero-based), or the group's special component in its designated socket.
The browser uses those rules for installation. Removal to an empty pocket is an
atomic adaptation of the original held cursor. Installed-to-installed exchanges
check both incoming parts; they cannot silently put an incompatible removed part
back into the source socket.

Library24 procedure8 `$014C–$0218` recalculates each of four units:

- Begin at4. Each shunt outside socket0 subtracts1.
- A missing, destroyed or wrong standard component makes the unit inoperative.
- The designated special socket accepts its special type or its standard type.
- A special part contributes availability only when its entire unit works.
- Total performance sums the four unit values (0–16).

The active record stores recalculated unit/total performance and `specialAvailable`.
Requirements and group IDs are immutable. The original also clears power/target
flags when necessary (`$0219–$0261`). This browser scope keeps all such controls at
their zero/off creation defaults and exposes no charging, power or travel actions;
there is no nonzero resource state to clear. Enabling machinery requires the full
dependent flag transitions, not simply using `specialAvailable` as a power toggle.

Game14 procedure8 `$05B9–$05F2` masks installed types and has an additional encoded
damage path, tracked by record byte25 and processed by procedures9/10. R08c establishes that this is delayed
failure, not repair; see [component failures](equipment-failures.md). Its live
update/save integration remains unsupported. Encoded carried bytes are preserved exactly;
only plain compatible component types may be installed. Destroyed type7 can be
removed to a pocket but cannot be installed. This checkpoint replaces parts; it
does not heal an individual damaged component, sell parts or add service costs.

## Persistence

`sundog-campaign` version2, scope `landed-engineering-1`, adds active `equipment`
beside immutable `start` and active `ship`. Exchanging components never rewrites
the creation recipe, initial inventory or initial equipment. Snapshots rederive
performance and availability and reject mismatched caches, wrong socket types,
altered requirements, unsupported encoded parts and extra fields.

Version1 `landed-ship-1` imports/slots first pass their full original validation.
Migration then creates owned active equipment from the immutable creation record.
Existing ship progress and identity are preserved. Loading/listing does not write
a slot; explicit save writes version2. Transaction comparisons use the original
raw slot record, so an upgrade cannot bypass stale-tab protection. Foreign/future
versions and altered legacy records still fail without replacing live state.

See [save boundary](campaign-saves.md) and [validation](component-exchange-validation.md).
There is no new original-emulator observation in this checkpoint.
