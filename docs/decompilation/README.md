# Pascal recovery progress

Direct source recovery under [PLAN-decompile.md](../../PLAN-decompile.md) is
complete for the target inventory. No decompiler was built. The [source index](../../src/pascal/README.md)
lists maintained Pascal and the [inventory](inventory.json) records full scope.

There are 570 targeted p-code procedures across active game, startup, utility,
system, and library modules: 570 recovered, none not started. The recovered bodies
cover 50,295 original instructions. Native bodies are excluded; all38 native
interfaces are reviewed. These are source-review statuses, not runtime results.

The entries below record successive recovery milestones. Earlier fixture hashes,
procedure mappings and references to pending dependencies describe those earlier
snapshots. The [completion audit](#completion-audit) records the final scope and
the remaining compiler/runtime limitations.

The inventory reuses `docs/pascal-inventory.json`, the reconstruction manifest,
the existing split-system analyzer, and retained-variant metadata. Identical
startup components on both disks count once. SYSTEM.PASCAL is a combined logical
view of `system_entry` and `system_core`, including procedure 38; its offsets
are not raw `system_core.bin` offsets. Component hashes and assembly revision
are recorded. Native identities use dictionary numbers, not zero attribute markers.

Six alternate modules and retained utility procedures are separately deferred:
42 p-code and 3 native procedures. Retained linker and utility edge fragments
have entries without invented complete-procedure counts. Additional exact-copy
contexts remain documented by existing assembly evidence; they are not counted
again as new active bodies. Deferred code must not be silently merged with the
primary source or reported as recovered.

The first group comprises game 18:2, 5, 15, 25, library 22:14, 19, and native
22:7's interface. [Group notes](game_18.md) cover their evidence and validation.
The [second group](game_18_dependencies.md) adds game 18:3, 4, 6–11 and library
22:11, 12, 34, 40, 57, 58, with native interfaces 22:3, 9, 56. The
[movement group](game_18_movement.md) adds game 18:12–14, library 22:35, 41,
and native interface 22:22. The [setup group](game_18_setup.md) adds game 18:16–20,
nine library bodies, and native interface 22:15. The [state group](game_18_state.md)
adds game 18:21, 22, 24, library 22:42, 61, 62, and five native interfaces.
The [condition-display group](game_8_condition.md) adds game 8:2, 5–7 and
library 22:10, 38, 39, 43–48.
The [library-27 group](library_27.md) recovers all 15 of that component's bodies,
library 22:13/21, and native interfaces 22:23/32/33.
The [clock group](game_8_clock.md) adds game8:8/9/18 and
library22:26–29/49/59/60, preserving packed time and condition-update behavior.
The [resource group](library_24_resources.md) adds library24:7/8/11/14–17 and
native22:4, retaining shared lexical state and effectful calls.
The [update group](library_24_updates.md) adds library24:9/12/13, game8:3/4, and native24:4,
preserving arrival copies, random-call order, damage-loop state, and ancestor EXIT.
The [game8 completion group](game_8_complete.md) adds procedures1/10–17,
completing all18 game8 bodies and their enclosing scope.
The [game18 completion group](game_18_complete.md) adds1/23/26–28, completing
all28 game18 bodies with explicit segment-runtime interfaces.
The [game17 helper group](game_17_helpers.md) adds2–10 and13–15 with packed
frame views, setup, selection, hit/damage, and drawing behavior. The
[game17 completion group](game_17_complete.md) adds1/11/12/16/17, completing all17
bodies and preserving its stack-relative copy extent beyond declared locals.
The [game19 dependency group](game_19_dependencies.md) completes libraries25/28,
adds library22:36, and recovers game19:2–6/8/26 with menu, amount, and table views.
The [game19 completion group](game_19_complete.md) adds the remaining19 bodies,
including transport, bank/depot menus, purchases, and the enclosing entry.
The [game20 warehouse group](game_20_warehouse.md) adds procedures2–15/32
with inventory setup, phase handling, menus, and warehouse moves.
The [game20 completion group](game_20_complete.md) adds1/16–31, completing all 32
bodies and its enclosing entry. The [game21 group](game_21_map.md) adds28
map, placement, selection, payment, and update bodies. Its continuation adds nine
more game21 bodies, library22:6, library23:1, and native interfaces23:2–4. The completion group adds game21:1/12/30/40
and native22:25's raw checksum-call contract, completing all41 game21 bodies. The [shared-library completion](library_24_resources.md#shared-library-completion)
adds the last seven library22/24 bodies and four native contracts, completing
both libraries as reviewed source/interfaces. The [game16 completion](game_16_helpers.md)
now covers all48 bodies, including setup, dialogue, trading, and the enclosing
entry with its segment-release epilogue.
The [game15 recovery](game_15.md) covers all16 bodies, including drawing,
movement, setup, table updates, transitions and its enclosing entry.
The [game14 recovery](game_14.md) covers all12 bodies, replacing its temporary
interface with the complete menu, item-transfer, repair and entry scope.
The [game13 systems-display group](game_13.md) adds procedures2–11, preserving
random-state restoration, packed location views, both input polls and cleanup.
The same component notes cover seven further menu/rescue helpers42–45/50–52.
Procedures27–41 add the complete travel scope, including the original packet
overrun and two raw native-overlay contracts. Procedures12–26 add the complete
map-rendering and selection scope, including cursor timeout, packed location
updates and saved permission flags. Entry1 and46–49 finish all52 game13 bodies,
preserving nested map menus, navigation result/input distinctions and the
segment-release epilogue. The game12 tactical entry is now recovered as well.
The two maintained compilation fixtures cover338 bodies; the42 additional
game13 bodies passed temporary compilation/disassembly checks, including the
complete module scope. The first
retains the expected game20:31 string-capacity warning documented in those notes;
the second has the expected goto warning for the checksum-failure loop;
library 22:34, 35, 37, 53, and 58, library24:14, game21:22, library22:6, game16:15/25, plus library22:1, library24:1, library27:1, and library23:1's return-only bodies, reproduce
exact body bytes. No recovered Pascal
runtime execution has been performed.

The [game12 tactical recovery](game_12.md) completes all23 bodies, covering2,590
instructions: setup, target display, firing, bounty/cargo, coordinate drawing,
menus, input, transitions and the enclosing entry. Its combined temporary check
includes the actual game12 and game13 scopes and preserves all23 game12 frame
interfaces. Three viewscreen-overlay target contracts extend the already-reviewed
raw-call interface without increasing native procedure coverage. Review retains
raw string address45, single-word bounty writes, mandatory polls/random calls,
aliased outputs and the cargo read before its index check. This adds23 game12 bodies outside the maintained fixtures.

The [library26 recovery](library_26.md) completes11 bodies and seven native
contracts in each active disk variant. Their shared source and disk-specific
identification literals preserve both inventory identities, adding22 targeted
bodies and1,822 instructions. Both variants pass temporary compilation, with
all frame interfaces and literals retained; their forward-copy and return-only
bodies reproduce exact bytes. All38 targeted native contracts are now reviewed.
Total temporary coverage beyond the338 maintained-fixture bodies is87 target
bodies (42 game13,23 game12,22 across library26's two variants).

The [startup7 source](../../src/pascal/startup_and_save/run_startup_or_save.pas) completes eight
bodies and778 instructions: disk-side checks, prompts, graphics/buffer setup,
seed restoration, save/restart selection and completion display. Source comments
map each body to the assembly. Both input polls, the initial six-block write,
both ten-block save writes, raw copies and segment-release order are preserved.
The raw-buffer-transform contract extends the existing22:25 trampoline contract;
it adds no native procedure to the inventory.

The temporary `build/decompile/startup_7/check.pas` includes actual recovered
library dependencies, stand-in DATA29/30/31 and an empty main. Original1–8 map
to compiled121–128; all local/parameter sizes and lexical levels match, and
all14 literal occurrences are retained. It compiles without warnings using
reference compiler revision `397cf201ddf22ca25a82d0ad5401e5d70a38f849` and
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`. Output SHA256 is
`2e16c1e6b2f87c6d348400810e512ee40a4d9eb5186fba9327dd4824ef49022c`.
Source and emitted paths were reviewed, including explicit IORESULT handling,
self EXIT, packed fields, pointer copies, input polls and repeated writes.
Native linkage, nonlocal-exit release bindings and runtime behavior remain
unvalidated. Shared storage views leave both maintained fixture outputs
unchanged. Temporary coverage beyond the338 maintained bodies is now95.

The [startup caller](../../src/pascal/game_dispatch/startup_program_entry.pas) adds six bodies
and243 instructions. Its576-byte assembly matches both startup_disk1 and
startup_disk2 manifest identities; the inventory counts this identical code
once. It preserves the ordered, repeated segment loads/releases, the two
distinct dispatch loops, uninitialized local slots, map VAR-argument order,
MARK35 then34, header-byte screen setup and startup7 calls. The root is a
program block with the original implicit four-byte parameter area and RBP.
Original nonlocal-exit epilogues and the error-handler procedure number require
runtime bindings; the temporary program does not supply those bindings.

The temporary `build/decompile/startup_disk1/check.pas` reuses actual startup7
and library bodies, with compile-only interfaces to the already-recovered game
entries. Production source does not replace those game bodies with externals.
The compiler crashes lowering `ord(@boot4[4])`: procedure4's raw-address
expressions are statically reviewed, but do not pass direct compilation. The
temporary check substitutes VAR arguments and a matching game18 declaration
only for that call. Its emitted LLA4/3/1, value-slot2 sequence matches the
original calling convention. This workaround is validation evidence, not a
change to the recovered game18 interface or a working runtime integration.

Original1–6 map to compiled1/147/148/149/150/151. All parameter sizes and lexical
levels match, as do local sizes for2–6. The fixture root reserves1254 bytes for
stand-in data segments; the original has no locals. Emitted checks retain
map argument addresses, heap operations and duplicate load/release order.
The only warning in the adapted fixture is the deliberate infinite error loop.
It uses the same compiler revision/options as startup7; output SHA256 is
`bd51dc26add3e342940210113fc46ea1304f27eeaea940b8ff45ead91625a992`.
Temporary checks now cover101 target bodies outside the338 maintained bodies,
including this explicitly adapted procedure4 check. No runtime execution or
exact body match is claimed for the startup caller.

The [utility helper group](../../src/pascal/save_game_utility/) adds ten bodies
(2/4/5/7/41–46),400 instructions and17 retained string occurrences. It covers
error display, disk-side checks/prompts, delete confirmation/action, reboot,
status labels and menu selection. The source preserves the256-byte unit read,
self EXIT on positive IORESULT, mandatory input pairs, countdown-before-poll,
conditional window cleanup,64-byte slot clearing and conditional block80 write.
Reboot writes512 bytes from program slot12, extending past the four64-byte
save-slot records exactly as the original does. Shared state is a1044-byte
utility frame; the rest of the program remains unrecovered.

The temporary `build/decompile/utility_disk1/check.pas` uses actual library and
startup7 bodies, declares the utility frame first to retain slots3–524, and
has an empty main. It includes no utility body stubs. Original2/41/7/4/5/42/43/
44/45/46 map to compiled129–138. All local/parameter sizes and lexical levels
match. Emitted review also checks the menu midpoint/tone slots4/3, selection
coordinates at5/4, slot stride, disk arguments and eager input/count expression.
The reference compiler warns about the address-of extension used to select a
slot; it accepts that pointer assignment without the startup caller's integer
cast problem. Compiler revision/options are the same as startup7. Output SHA256:
`c6ab5d933187168871cb95a898615bcb776bf6063e0cd01e16489b07fdccc6ea`.
The assembled utility matches its manifest SHA256. These are static recovery
and temporary compilation checks, not runtime or exact-body-equivalence claims.
Temporary checks now cover111 target bodies outside the338 maintained bodies,
including the previously documented adapted startup caller check.

The utility continuation adds3/6/8/40/47/49: six bodies,776 instructions and26
literal occurrences. It covers slot display, screen setup, saved-slot loading
and checksum/state updates, play transition, action menus and certificates.
The64-byte slot views now expose timestamps at word16, location at18 and
attributes at10. Program views retain buffer269–524 and state nibbles at278;
word504 plus byte2 maps to byte1004 relative to program slot3. Copies preserve
all six location words and both timestamp words before checksum evaluation.

Source review preserves raw string addresses92/41 in procedure3, conditional
header invalidation, two identical boot-block writes in40, the four-byte seed
MOVELEFT and both input polls. Procedure47 captures the selected pointer before
display, then rereads status after each menu call. Procedure49 retains its two
unused parameter words. No speculative repair of those original operations was
introduced.

The expanded temporary utility fixture maps3/6/8/40/47/49 to139–144. Parameters
and lexical levels match all six originals; local sizes match five. Procedure3
compiles with26 local bytes versus22 because COPY adds a four-byte temporary
at slots14/15. Its declared locals keep their original slots; the extra private
temporary is documented rather than hidden behind a frame-match claim. Emitted
checks confirm raw string pointers, aggregate-copy order, duplicate writes and
MOVELEFT arguments. All26 literal occurrences are retained. The same compiler
revision/options produce SHA256
`39da8fdde7ebc0b6a3a11a32be1e0dbca158b023bbb508dd629da879065c6e0a`.
This supersedes the earlier ten-helper fixture output; source changes are
limited to utility files and recovery documentation/inventory. Temporary checks
now cover117 target bodies outside the338 maintained bodies. Runtime remains
unvalidated.

The [name-entry scope31](../../src/pascal/save_game_utility/enter_character_name.pas) adds nine
bodies31–39,565 instructions and13 literal occurrences. Its340-byte frame
contains30 five-word keyboard entries, saved bounds, the15-character name,
confirmation and shift flags, and a separate editing count. The source retains
low-byte-only key-code writes, input1 deletion priority, both button-release
waits, repeated status reads and full-word NOT for the shift flag. Confirmation
trims the string length byte without synchronizing the editing count, compares
all four names regardless of slot state, then restores both bounds. Entry31
always copies the name through39, including the cancellation path.

The expanded temporary utility fixture maps31–39 to145–153. All parameter
sizes, local sizes and lexical levels match. Source/emitted review covers the
keyboard strides, parent-slot offsets, initial character read before the length
test, string delete, confirmation branches, cursor restoration and unconditional
final copy. Focused byte checks confirm full-word complement and the entry/final
copy sequences. All13 literal occurrences are retained. The same compiler
revision/options produce SHA256
`5535faaf2384017d29c7537e9aecbeb8450aaff1096e06d4290a01311a9b2b4a`.
Only the existing address-of extension warning remains. This replaces the
earlier utility fixture output and brings temporary coverage to126 target
bodies outside the338 maintained bodies. No runtime result is claimed.

Initialization children10–13/19–21 add seven bodies and765 instructions. They
recover system-position perturbation/separation, planet-byte initialization,
item-band generation and initial game-data setup. System10 remains fixed at
6/5/6; the other systems retry until the original spacing predicate accepts.
Planet initialization retains the initially unknown parent word9. Masked writes
preserve other bits of system word5 and planet word7; the amount pointer at
system word6 uses a12-byte offset and retains both word stores.

Source/emitted review preserves both absolute-value calls in11, the read before
RNG in10, and all four random call sites in19. Integer AND/OR prevents the
fifth-item random test or the random OR operand from being skipped. The
`proc22_3 + 0` expression forces a parameterless call before MOD; the emitted
code removes the addition and needs no temporary. Procedure21 saves the name,
clears512 bytes at DATA29 word36, restores the name, and preserves ordered
seed/transform bytes, packed state writes and all six item-band calls.

The temporary utility fixture adds an explicitly partial scope9 scaffold at
compiled154 and maps10/11/12/13/19/20/21 to155–161. Only the seven complete
child bodies count as recovered. All local/parameter sizes and lexical levels
match; the single inline literal is retained. Focused emitted checks verify
eager RNG calls and the caption-save/clear/restore sequence. The same compiler
revision/options produce SHA256
`28b00b9b507257135105adf39075f4d2f11b9ebb7216e69a371f06d6c7eaa5ec`.
This supersedes the earlier utility fixture output; temporary coverage is133
target bodies outside the338 maintained bodies. No shared decoder/storage,
assembly, disk or runtime implementation changed, and runtime remains untested.

The [complete initialization scope9](../../src/pascal/save_game_utility/create_game_state.pas)
adds six bodies9/14–18 and575 instructions. It replaces the temporary parent
scaffold with the actual save-area selection and ordered calls21/17/18.
Procedure14 rotates18 templates, copies each second seven-word half before the
first, flushes at16 output rows, and appends54 bytes of packed codes. Procedure15
packs each caption backwards into five-bit values, preserving the ninth value
and spare bits. The final copy/two-row advance has no added boundary flush.
Procedure16 preserves occupied-entry retries, both RNG call sites, the1024-byte
clear, the32-byte copy from5120+352 to2048+960, and the two-block write. Procedure17
retains both three-block writes. Procedure18 recomputes table addresses between
stores, copies the six-word location four times with temporary coordinates147/115,
then restores the saved coordinate fields.

The temporary utility fixture now includes the actual scope9 and maps9–21 to
154–166 in order. All13 parameter sizes, local sizes and lexical levels match
the originals. Source/emitted review checks packed offsets, three-word code-row
stride, copy order, buffer boundaries, retry branches, call order and location
restoration; all nine new literal occurrences are retained. A template-pointer
field was renamed to avoid the reference compiler's eight-character identifier
collision. The existing address-of extension warning remains. Compiler revision
`397cf201ddf22ca25a82d0ad5401e5d70a38f849`, with
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`, produces SHA256
`2077fade5b6d7a02dcd97389f5537bf292801994e7527ed51131a3da28019a6b`.
This supersedes the earlier utility fixture output; temporary coverage is139
target bodies outside the338 maintained bodies. Shared storage and maintained
fixtures are unchanged. Runtime remains unvalidated.

The [attribute-editor scope22](../../src/pascal/save_game_utility/edit_start_attributes.pas) and
[utility program block](../../src/pascal/save_game_utility/utility_main_loop.pas) finish the
remaining12 utility bodies22–30/48/50/1, adding992 instructions and22 literal
occurrences. Scope22 retains its five attribute bars, rounded points bar,
initial30/30/30/30/0 values and440 points. Editor29 preserves the initially
unspecified direction word, mandatory input4 poll in the adjustment condition,
unused final poll, selection handoff, and rejection of candidate points <=0.
Cost27 retains its signed integer doubling loop. Save26 copies the five
attributes, writes one block, reads ten blocks, updates the slot and computes
its checksum in original order.

Caller48 requires both confirmation and accepted name entry before running9/22.
Dispatch50 retains all four actions and the certificate-specific window path.
Entry1 preserves heap MARK/MARK/RELEASE, raw-screen initialization, both main
input polls, and repeated segment30 loads/releases. Its runtime must bind
utility error dispatch to2 and nonlocal EXIT to the release epilogue at$2126.
The recovered program block supplies all49 descendant bodies; no enclosing
scaffold remains.

The complete temporary utility fixture maps entry1 to compiled1; helpers
2/41/7/4/5/42/43/44/45/46/3/6/8/40/47/49 to134–149;31–39 to150–158;
9–21 to159–171;22–30 to172–180;48/50 to181/182. All50 parameter sizes and
lexical levels match, as do48 local sizes. Procedure3 still has its four-byte
compiler COPY temporary. Main has2298 local bytes because compile-only DATA
storage adds1254 bytes after the original1044-byte `u1` frame; its utility slots
remain3–524. All88 utility literal occurrences are retained, and cost27's body
reproduces exact bytes. Source/emitted review covers all new paths, including
the full-word input masks, cost branches, save copies and entry cleanup.

The same compiler revision/options produce SHA256
`ee7863b14d521d3d34d9ffa03b55f9fe3d6efce663218cf55ff55202c41dcafd`.
This supersedes the earlier utility fixture output; temporary coverage is151
target bodies outside the338 maintained bodies. Only the existing address-of
extension warning remains. Shared storage, maintained fixtures and original
assembly are unchanged. Runtime/native/error/segment-release bindings remain
unvalidated.

System segments1–3 add seven reviewed bodies and516 instructions. The entries
in [system1](../../src/pascal/unbound_program_entry/rt_unbound_entry_failure.pas) and
[system3](../../src/pascal/empty_program_entry/rt_empty_program_failure.pas) call core0:2 with error9 and
return with RBP0, but have different parameter metadata. The five
[system2 bodies](../../src/pascal/buffered_files/) recover buffered file read/write,
repeated-space decoding, whole-record save/restore and return-only initialization.
The [file storage views](../../src/pascal/runtime_file_types.pas) retain the580-byte
record, directory entry at word16 and512-byte sector at word33.

Review preserves partial copies, dirty-flag clearing before writes, IORESULT
checks even when no I/O occurred, the full290-word snapshot/restore, and the
low-bit tests of file word13. Writer5 retains both extension/capacity checks,
error8 stores, the read-versus-zero-fill branch and the carriage-return boundary
path. The unreachable join instructions at$0028/$01D3 are explicitly accounted
for in source comments using the existing branch evidence. They are included
in instruction coverage without inventing new reachable paths.

Core0:2/7/8/33 bodies remain pending in the inventory. Their call interfaces were
checked from the core listings and call sites; temporary external declarations
are compilation stand-ins only, not recovered implementations. `sysio` must
bind to the pointer read by `LOD 2,1`; ordinary fixture globals do not establish
that runtime static-link binding. No new external declarations were added to
the maintained source to hide these pending dependencies.

Temporary fixtures in `build/decompile/system_1/`, `system_2/`, and `system_3/`
compile with revision `397cf201ddf22ca25a82d0ad5401e5d70a38f849` and
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`. Assembled input hashes match
the reconstruction manifest. System2 originals1–5 map to compiled5–9; all
parameter sizes, local sizes and lexical levels match. Emitted checks retain
both MOV290 copies, the eager AND expressions, low-bit NOT and two explicit
IORESULT checks in each buffered transfer routine, without automatic IOCHECK.
Its return-only entry reproduces exact body bytes. Compiler warnings are limited
to the deliberate goto and address-of extensions. Output SHA256 is
`ecd1752ce65bc915a4988999344bc192a3f413068b6f2cd35ac78586c7c5cffc`.

System1's frame matches. System3 has zero original parameter bytes versus four
in the ordinary compiler program ABI, documented in its source. Both temporary
program fixtures produce SHA256
`869efa5c03953c3f81aebcb07198b418671d30bc4dd96d33f90197b30ee3cf8e`;
this shared fixture result does not erase their original metadata difference.
Temporary coverage is158 target bodies outside the338 maintained bodies.
Runtime integration and execution remain unvalidated.

System4's [configuration scope3](../../src/pascal/runtime_initialization/rt_configure_console.pas) and
helpers2/8/9/10 add eight bodies2–6/8–10,568 instructions and five literals.
The [storage views](../../src/pascal/runtime_initialization/types.pas) distinguish the runtime
ancestor frame from the612-byte segment entry frame. Procedure2 preserves its
fixed-address flag read, SYSTEM.CHARSET load, result store into local43 and both
close calls;$004D remains a required nonlocal-exit cleanup target.

Configuration3 reads288 bytes only when the file-open flag's low bit is set,
copies fields29/30 and the6/11-word control/key records, then initializes the
character mask in original order. All ten key registrations and eight control
registrations remain, including the full-word key code. Control strings retain
the seven-word temporary at local160, two core0:23 appends with capacities6/12,
SAS6 copy and explicit final length-byte writes. Helper4 clamps the supplied
length to11 and clears only that prefix. Helper8 performs UNITCLEAR before its
IORESULT test. Helper9 allocates four30-word file headers and three one-word
buffers in order; using the larger buffered-file type would change heap layout.
Helper10 retains all close/init/open operations and three final file-pointer
assignments, with the SYSTERM open conditional on ancestor229's low bit.

The temporary `build/decompile/system_4/check.pas` uses actual scope3 and
compile-only entry1/scope7 scaffolds. Pending core0:3/5/6/23/28 and system6:2/4/5
calls have temporary interface declarations only. Ancestor storage is a stand-in;
the required lexical links are not supplied by this fixture. Original2/3/4/5/6/
8/9/10 map to compiled10/11/12/13/14/16/17/18. All parameter sizes, local sizes
and lexical levels match; all five literals are retained. Source/emitted checks
confirm allocation sizes/order, duplicate closes, record-copy extents, packed
mask accesses, registration calls, the reused concat temporary and absence of
an invented automatic IOCHECK after the configuration read. The interpreter's
CSP38 vector$D14C and handler$EF7D support the UNITCLEAR binding used here.

The same reference compiler revision/options produce SHA256
`417ed774850f8500e53b123a36f55966356c84286b42fa0851012712e9754ce7`.
Only the address-of extension warning remains. Temporary coverage is166 target
bodies outside the338 maintained bodies. No existing shared storage, assembly,
decoder or maintained fixture changed; runtime remains unvalidated.

The [system4 device scan7](../../src/pascal/runtime_initialization/rt_enumerate_devices.pas) and
[entry1](../../src/pascal/runtime_initialization/rt_initialize_system.pas) complete all ten system4 bodies,
adding287 instructions and11 nonempty literals. Scan7 preserves the six-word
unit table, conditional UNITCLEAR/IORESULT/volume-read sequence, low-bit masks,
and directory lookup's overwrite of the loop index before increment. It reads
the packed seven-bit flags three times, retains the nil-directory HALT, and
names all six character devices through8. Entry1 preserves the allocate-or-
release heap path, initialization order, version/flag reads at fixed addresses,
all diagnostic calls and both infinite failure loops. Segment6 is released only
on the normal path or through the original nonlocal-exit epilogue at$0796.

The [explicit IO-check contract](../../src/pascal/runtime_initialization/runtime_interfaces.pas)
binds `rtiochk` to CSP0, vector$D100 -> handler$EEDC. It reads the low error byte
at$BDDE and transfers to interpreter error dispatch on nonzero, without clearing
the result. This contract retains the twelve diagnostic checks; it does not
implement the runtime or add a native target to the inventory.

The complete temporary fixture maps entry1 to compiled1,2–6 to18–22,7/8 to23/24,
and9/10 to25/26. All nine child parameter sizes, local sizes and lexical levels
match. Original entry1 has612 local bytes and zero parameter bytes; the fixture
has1680 locals because it also allocates the1068-byte ancestor stand-in, and its
ordinary program header contributes four parameter bytes. Neither its original
frame placement nor runtime static link is claimed validated. All16 nonempty
literals and four empty-string assignments are retained. Emitted review checks
the six child8 calls, loop-index reuse, masks, twelve IO-check calls, both failure
loops and the final release call. The actual source replaces both scaffolds;
pending core/system6 bodies still have compilation-only interface declarations.

The same compiler revision/options produce SHA256
`b1cd2036628bede12780c12f2197f790d1b66e8dc1634194fd41caa5684a7136`.
This supersedes the earlier system4 fixture output. Warnings cover address-of
and the two deliberately constant-false loop conditions. Temporary coverage
is168 target bodies outside the338 maintained bodies. Existing shared storage,
assembly and maintained fixtures are unchanged; runtime remains unvalidated.

The [system5 entry and children](../../src/pascal/program_loader/rt_select_program.pas) recover
all ten bodies, accounting for 894 instructions. Filename normalization retains
space removal, the early trailing-dot return, bounded bracket-suffix copying, ASCII
uppercasing and the original extension-capacity test. Header helpers preserve
packed segment mapping, legacy-field checks, the unbounded segment1 search,
descriptor write order and the allowed-mask copy before output clearing.
The library reader retains its effectful mask-builder call despite ignoring
the Boolean result, then registers segments and returns true.

The main loader's success path closes once and exits directly at $0591,
retaining the selected volume. Local failure cleanup at $0580 closes and
restores the saved volume. CSP4's vector at $D108 and handler at $E75C..$E797
confirm that self-EXIT bypasses failure cleanup. Library reader9's exit pointer
likewise targets its return at $03B0, after its local close. The recovery
preserves these distinctions, all three version-diagnostic IO checks, and the
paths after error calls in case those calls return. Entry1 preserves file-pointer
setup, attach/startup/named-file selection and result codes 0/3/4.

The temporary `build/decompile/system_5/check.pas` includes the complete scope.
Reference compiler revision `397cf201ddf22ca25a82d0ad5401e5d70a38f849`, with
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`, produces SHA256
`00116449cb0a59196492c0a4e82cb636e167378c7cf528a5ec4188f648d33292`.
Original procedures1–10 map to compiled15–24. Focused emitted-code review
confirms the copy-before-clear, ignored-result call, two-word mask comparison,
string operations and return-only exit targets; all nine nonempty literals
remain. Warnings cover address-of and goto. Parameter widths match, but this
ordinary function fixture shifts lexical levels by one and uses RNP1 for the
original RBP1 entry. Source1/5 omit unused local words; source2 adds a string-view
pointer. These differences are documented without padding frames to match.

Pending core0:2/19/22/23/25/26/27/31 and system6:2/4/5/11 calls have temporary
interface declarations only. Ancestor storage and IO-check linkage are stand-ins;
runtime integration and execution remain unvalidated. Temporary compilation
coverage is 178 target bodies outside the 338 maintained fixture bodies.

System6 procedures1/2/3/7/8/11/12/13 add eight reviewed bodies and 743 original
instructions. The [name parser11](../../src/pascal/file_manager/rt_parse_file_spec.pas) copies
its input before clearing outputs, removes control/space characters, uppercases
ASCII, resolves volume prefixes and parses the bracket amount and filename
extension. It retains partial outputs on failure, accepts `[]` and `[*]`, and
does not reject trailing text after the closing bracket. The recovered code
preserves these original behaviors rather than adding input validation.

Directory helpers7/8 retain descending insertion and ascending deletion with
13-word copies, including the effect of a source aliased into the directory.
Lookup12 tests the low bit of its class argument against the packed date field.
Initializer2 preserves file-header write order and the special kinds0/-2.
[Flush13](../../src/pascal/file_manager/rt_flush_file.pas) retains its two conditional
UNITWRITE sites, buffer padding and flag updates. Its extra-block predicate uses
the low bit of word13; it has no IORESULT or automatic IO-check. Procedure3
clears the runtime error word, calls13 and conditionally calls pending core7.
Entry1 is a return-only initializer.

The temporary `build/decompile/system_6/check.pas` checks those storage and
evaluation details with the same compiler revision/options recorded above.
Original1/2/7/8/11/12/13/3 map to compiled6–13. All parameter widths and lexical
levels match. Source2 adds one buffer-view pointer and11 adds two string-view
pointers; other local sizes match without padding. All nine nonempty literals
remain. The only warning is address-of; output SHA256 is
`3c75d1c4c54b3374f0e026010b0a420909cc3b803ab2f82405f3e9a134339df5`.
The assembled original matches the inventory hash; decoding uses the existing
extra roots documented for pending procedure4 in `pcode-unreachable-branches.md`.

`build/decompile/system_6/system5_callers.pas` also compiles the actual2/11
bodies with their system5 callers, replacing those two temporary declarations.
This checks interface compatibility; its ancestor variables remain stand-ins
for one runtime frame. Core7/25/26/27 are still untranslated dependencies.
Temporary coverage is 186 target bodies outside the 338 maintained fixture
bodies. Runtime linkage and execution remain unvalidated.

System6's [directory loader9](../../src/pascal/file_manager/rt_read_volume_directory.pas),
[writer10](../../src/pascal/file_manager/rt_write_directory.pas), and
[lookup6](../../src/pascal/file_manager/rt_resolve_volume.pas) add three bodies and 620
instructions. Loader9 preserves the256-word allocation and512-byte read at
block79, despite the original entry-count limit of77. The directory view does
not enlarge that allocation. Sanitizing a changed volume deletes invalid
entries without advancing the index; failure RELEASEs the cache before storing
nil. Its status checks read the IO word directly, without consuming IORESULT.

Writer10 retains its26-byte verification read and the optional second directory
write, which occurs even when the first write fails. Only the saved first
write result controls timestamping and unit invalidation. Lookup6 preserves raw
search-word masking, numeric/name scans, the cache age check without a lower
bound, and the IORESULT check after a false loader result. These paths compile
without additional IO-check calls. The TIME calls retain CSP9's SunDog binding:
vector$D112 selects the handler at$E819..$E832, which writes zeros to both
outputs; it is not a host-clock substitution.

The expanded temporary system6 fixture includes all eleven recovered bodies;
original9/10/6 map to compiled10/11/12. Their parameter/local sizes and lexical
levels match. Focused emitted review confirms allocation size, release order,
packed fields, call counts and saved-status branches; the earlier eight bodies'
interface/storage checks still pass. Output SHA256 is
`e2a50c59a9b081d14e9edd62d0194b34b49f2442b9b3875893e363deb5d4fdfa`
with the same compiler revision/options. The address-of warning remains.
`build/decompile/system_6/system4_callers.pas` compiles actual2/6/8/9 bodies
with system4; ancestor variables remain stand-ins for one runtime frame.
Temporary coverage is 189 target bodies outside the338 maintained bodies.
Runtime integration and execution remain unvalidated.

The [open routine4](../../src/pascal/file_manager/rt_open_file.pas), its nested
allocation helpers14/15, and [close5](../../src/pascal/file_manager/rt_close_file.pas)
complete system6: four more bodies and969 instructions,2332 in the module.
Open4 passes the filename by reference until parser11 makes its value copy,
preserving the early-error and aliasing order. It retains mode normalization,
the2028-byte heap swap, both restore/flag cleanup paths, and the514-byte tail
clear before two text-file writes. Restoring swapped data preserves the prior
IO word. The original return-only exit pointer skips local cleanup on nonlocal
EXIT. Both unreachable joins remain accounted for by the existing evidence.

Helpers14/15 retain strict gap comparisons, largest/runner-up selection for
nonpositive requests, first-fit selection for positive requests, and the77-entry
limit. The new directory entry initializes only the evidenced fields; its kind
word's upper twelve bits remain unspecified until the close path clears them.
Close5 preserves buffer-identity gating, mode3's pre-flush edits, extent matching,
duplicate removal and index adjustment, full-word date copies, directory-write
order and error branches that skip directly to final file flags.

All fifteen system6 bodies compile in the temporary fixture. New4/14/15/5 map
to compiled17/18/19/20; their parameter/local sizes and lexical levels match.
Focused emitted-code checks cover nested ancestor accesses, packed stores,
13-word copies, IO call order, swap/clear extents and return-only exit targets.
Earlier storage/interface checks and all nine nonempty literals still pass.
The same compiler revision/options produce SHA256
`c2f69475870df97b7e90cf0c22236839367880b0b5ebe9dac581b786f6614882`;
warnings are limited to address-of and goto.

The temporary system4/system5 caller fixtures now use all recovered system6
bodies, including4/5, and both compile. Shorter filename variables are accepted
by4's VAR string interface without an added value copy. These checks replace
temporary system6 declarations in those fixtures; ancestor variables are still
stand-ins for one shared runtime frame, and core calls remain untranslated.
Temporary coverage is193 target bodies outside the338 maintained bodies.
Runtime integration and execution remain unvalidated.

The [core string bodies23–27](../../src/pascal/runtime_core/) recover append,
insert, substring, delete and search directly from the listings. Forwarding
bodies3–6 call the recovered system6 routines without copying pointer arguments;
10/11 return full file flag words, and9/14/15 are evidenced no-ops. These14
bodies account for284 original instructions.

The string review preserves eager predicates, direction-specific overlapping
copies, and length rereads after mutation. Substring25 clears its destination
before checking the source; delete26 leaves an overlong request unchanged.
Search27 borrows its needle without a value copy, initializes only the local
string length, and retains the inclusive-endpoint scan and final-candidate
comparison. CSP2/3 select forward/backward copies through the handler at$E878
and selector test at$E8A2; CSP11's handler$E6CF tests the byte before checking
the endpoint. These bindings are evidenced in `src/native/native_shared.s`
and the vectors in `src/native/pcode_primitives.s`.

The temporary `build/decompile/system_core/check.pas` compiles these14 bodies
with all15 system6 bodies. Original23–27 map to compiled3–7; original3–6,
9/10/11/14/15 map to compiled23–31. All original parameter widths are retained.
The string bodies add pointer views (four local bytes in23/24/25, two in26/27);
the other nine retain their zero local bytes. Emitted review confirms eager
tests, copy direction, post-copy length loads, SAS80-before-test order, SCAN's
six argument words, string comparison and direct pointer forwarding.
The host fixture changes core lexical level0/RBP to level1/RNP; it does not
validate original static links or cross-segment calling conventions.

Compilation uses revision `397cf201ddf22ca25a82d0ad5401e5d70a38f849` of
`../../tmp/ucsd-psystem-xc`, with `--p-machine=ii.1 -f no-range-check
-f no-efj-nfj`. The check output SHA256 is
`63a4bf950aa939dab84ac2c5e212924c42d409f30753cf21a1e613c09fbb7d86`.
The temporary system4/system5 caller fixtures in the same directory replace
the newly recovered core declarations with actual bodies. Both compile,
including system4's literal filename and system5/6's literal search needles;
their output SHA256 values are respectively
`7d3c3ffaaa3ec595d00f503ce7fc1341d9a935b331ad34baa48d7f3a72e60239` and
`dfe857eed9ccca9740c44de21598a3164510b267e8cedf05e962772702d6e8a1`.
Warnings are address-of/goto, plus system4's two intentional constant-false
loop conditions. Remaining core declarations and ancestor storage are stand-ins.
Temporary compilation coverage is207 target bodies outside the338 maintained
bodies. Runtime integration and execution remain unvalidated.

Core7/8/16–22/29–31/33–35 add15 bodies and893 original instructions. This
recovers file-byte input/output, string/line I/O, console editing and control,
and directory extent extension. The [IO forwards](../../src/pascal/runtime_core/io_forwards.pas)
express actual mutual recursion with system2/6; all three forward declarations
are now fulfilled by reviewed Pascal bodies.

Core7 preserves repeated-space early returns, echo masking, one-byte input into
a zero-high-byte integer, CR/zero handling and buffer-pointer rereads after
recursive calls. Core7/8 retain the differing IO-result checks and failure
flag order. Core18 retains the final drain loop even when flag2 stopped storage.
Core19 borrows its string and passes its payload byte address without copying;
core20 retains padding-before-output and unchecked direct writes. Core33 edits
the directory before its write, preserves failure paths without rollback, and
distinguishes a successful no-extension search from failure flag updates.
Core35 consumes configured editing keys even at the beginning of the line;
34's fixed11>0 branch always emits its trailing control string. Console29
preserves ordered coordinate clamps, and31 captures configuration after30 and
clears unit3 without adding an IO check.

`build/decompile/system_core/io.pas` compiles all29 recovered core bodies,
all5 system2 bodies and all15 system6 bodies. The new original7/8/33 map to
compiled2/3/4; original16/17/20/19/21/22/34/35/18/29/30/31 map to40–51.
All15 parameter widths match. Core7/8 omit ten unused local bytes each;
18/19/22/35 add two bytes for alias pointers; the others retain their local
sizes. Emitted review confirms raw flag tests, recursive call edges, IO order,
byte offsets, ordered extent edits, packed7-bit stores and console output order.
The core still compiles at host level1/RNP instead of original level0/RBP.
`sy0e`, `sy6e` and `sysio` are compilation stand-ins, not separate runtime storage.

Using the same compiler revision/options as the previous check, `io.code` has
SHA256 `a6c883df407157c19a586726561aaee525e785be5e0ced972516c29cf3165645`.
The updated `io_system4.pas` and `io_system5.pas` fixtures compile actual core,
system2 and system6 bodies with their callers; only core28 and core2 respectively
remain temporary p-code declarations. Their output hashes are
`91e5464ff5d32f674f953703a7c37c52fa89b9669567fe3cbbe6ca3c9d0c3c1f` and
`b40c49034c32edb7b4e55c5f4aa29ad65063ad5c85a391ea942df803e51a51ef`.
Warnings remain address-of/goto plus the two intentional system4 loop warnings.
Temporary coverage is222 target bodies outside the338 maintained bodies.
Runtime integration and execution remain unvalidated.

Core1/2/12/13/28/32/36–39 complete the target body inventory, adding714
instructions. Number input12 retains its92-byte frame, including character3,
flags4/5, index6, dummy text7..47 and file pointer48; editing can read past the
dummy text's nominal bound. It fills81 bytes with80, preserves sign/digit flags
through editing, and does not add overflow or length rejection. Formatter13
retains the power table, -32768 literal, width handling and reviewed dead join.
Block helper36 preserves63-block chunks and ordered IORESULT checks; caller28
retains clipping/extension order, discarded extension result, raw status writes,
signed arithmetic and negative-count SCAN through its inclusive endpoint.

The dispatch recovery preserves failure2's exact literals and infinite loop,
37's heap release and mismatch loop, and32's status resets. Separately loaded38
retains loader/close order, eager UNITBUSY calls and partial flag updates.
38/39 load and release their segments, including explicit self-exit paths;
nonlocal runtime EXIT must still target their documented release epilogues.
Root1 initializes only heap5 before its unit-clear/setup/dispatch loop.

System1 and system4 now expose named callable entries for these actual callers.
System1 accepts the two unused address words supplied by32/38/39. System4 owns
its original612-byte frame and nine descendants, with its original zero
parameter bytes. Their recovered executable bodies are unchanged; ordinary
host nesting shifts their lexical levels and return conventions.

`build/decompile/system_core/complete.pas` compiles all39 core bodies with
system1 and all system2/4/5/6 bodies,80 target bodies in total. No pending p-code
external declarations remain in that check; `rtiochk`, `rtldseg`, and `rtrlseg`
are explicit runtime bindings. New original12/13/36/28/2/37 map to compiled54–59,
system1 to60, system4 scope to61–70, system5 scope to71–80, and38/39/32 to81–83;
root1 is compiled1. All non-root parameter widths match. Input12 retains its
exact accessed local offsets. Unused locals in2/37/38 and the constant-zero
bound in13 are omitted. Original36/38/39 lexical levels match; the other new
core routines shift by1. The host root has4274 local/4 parameter bytes and
lexical0/RBP versus original1068/0/lexical-1/XIT. Ancestor storage remains
compile-only stand-ins. Nonlocal exits and cross-segment runtime ABI are not
validated by compilation.

With compiler revision `397cf201ddf22ca25a82d0ad5401e5d70a38f849` and
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`, output SHA256 is
`bfc682570b2b3f9308525e7a82598f6f450fb9799f5042a8d178dd5c48c72843`.
Emitted review covers numeric editing, chunk arithmetic, SCAN operands,
dispatch calls, status order, both UNITBUSY operations and explicit release
paths. All four new nonempty literals match the original bytes. Warnings are
address-of/goto and four intentional constant-false loop conditions. Temporary
coverage is232 target bodies outside the338 maintained bodies. Runtime
integration and execution remain unvalidated.

## Completion audit

The planned source recovery is complete. Acceptance rests on the recorded
instruction-path reviews and routine-specific evidence in the maintained Pascal,
inventory and recovery notes. The following final checks reconcile those reviews
with the complete original scope; counts and compiler results alone are not
claims of behavioral equivalence.

| Plan requirement | Final evidence |
| --- | --- |
| Recover every targeted p-code body | Replayed the existing procedure-aware analyzers against all29 target component binaries, using their reviewed roots and mixed-native recipes. Manifest/inventory hashes, procedure numbers, entry/attribute offsets, lexical levels and representations agree. Every one of570 reviewed source entries exists; all per-procedure instruction counts agree, totaling50,295. |
| Account for native interfaces | All38 target native identities map to reviewed contracts in nine maintained interface files. Contracts describe stack/register arguments, results, effects and unusual cleanup; library26's internal register helper deliberately has no invented Pascal signature. Native implementations remain authoritative assembly. |
| Retain complete bodies and consistent dependencies | All numeric procedure references in maintained Pascal have declarations. The13 empty target bodies correspond exactly to original single-return routines. No untranslated p-code body is hidden behind an external declaration; maintained externals describe native targets or the three explicit runtime operations. |
| Reconcile system entry and shared interfaces | The combined core/system1/2/4/5/6 check includes80 actual target bodies and only runtime externals. System1's two address words and system4's zero-parameter612-byte entry frame are exposed explicitly. System3's entry also compiles with actual core2. Shared ancestor/DATA views and nonlocal-exit epilogues remain documented runtime binding requirements. |
| Preserve the agreed scope and original inputs | Startup's identical disk2 copy remains an explicit alias. Both distinct library26 identities retain their own constants. The42 p-code/3 native procedures in deferred variants, plus retained fragments without complete-procedure counts, remain deferred. Assembly, native sources, decoder tools, reconstruction inputs, disks and the accepted488-byte unidentified-data exception were not changed. |
| Validate proportionally and report limits | Both maintained verifiers pass, covering338 distinct recovered bodies with pinned source/output hashes and scoped interface/effect checks. The other232 have the temporary checks documented above. Source references, includes, inventory paths and whitespace were checked. No emulator/runtime equivalence is claimed. |

The maintained checks are:

```sh
python3 docs/decompilation/checks/verify_game_18.py
python3 docs/decompilation/checks/verify_game_21.py
```

The final system3 entry check uses
`build/decompile/system_core/system3_entry.pas`, substituting its program block
for core1 in the complete system fixture. Its emitted root calls recovered
core2 with9, then returns; output SHA256 is
`4397f99e9bb9d5ada3f08a33b31fa1e158f5bf760fecf4f7ed2e40ce954fcaa7`.
It has the same documented host-root ABI differences and uses the compiler
revision/options recorded above. Inventory validation notes now distinguish
earlier compilation stubs from the actual recovered system dependencies.

Remaining limitations are outside the source-recovery completion criterion:
original native/CSP bindings, shared runtime storage, lexical/segment calling
conventions and nonlocal-exit cleanup are not linked or executed. Startup's
raw `ord(@...)` expression still encounters the documented reference-compiler
failure; its temporary VAR-call substitute is validation evidence only. Exact
whole-program recompilation and runtime equivalence have not been established.
The assembly remains the disk reconstruction source. No decompiler framework,
replacement runtime or new general testing engine was added.
