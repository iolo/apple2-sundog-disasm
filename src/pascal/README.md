# Recovered Pascal source

This maintained source is recovered directly from `src/pcode/`. The assembly
remains the exact disk-build input. **570 of 570 targeted p-code procedures**
have reviewed translations, covering 50,295 original instructions. All38
targeted native interfaces are documented; native bodies remain in assembly.
This completes the source-recovery scope in [the plan](../../PLAN-decompile.md).
Deferred variants and runtime integration are identified in the
[completion audit](../../docs/decompilation/README.md#completion-audit).

The identifier-naming pass covers all570 targeted p-code routines. The
[naming notes](../../docs/decompilation/identifier-names.md) describe reviewed
names, original symbol mappings, source paths, and validation. Directories
describe each module’s role; procedure files use their inferred routine names.
Original component/procedure IDs and offsets remain in comments and the catalog.
Unresolved storage and separately deferred historical variants retain neutral
names where a semantic binding is not established.

| Source | Recovered content |
| --- | --- |
| [shared_game_state.pas](shared_game_state.pas) | Bounds, bounded strings, packed time, address-word/pointer views, and overlapping DATASEG29 views. |
| [runtime_file_types.pas](runtime_file_types.pas) | Raw580-byte file record, embedded directory entry and512-byte sector views used by system2. |
| [runtime_core/](runtime_core/) | All39 bodies: system entry/dispatch, file/console I/O, number conversion, block transfers, string operations, system6 forwarding and raw flag access. Includes separately loaded38. |
| [unbound_program_entry/](unbound_program_entry/) / [empty_program_entry/](empty_program_entry/) | One entry each, calling core0:2 with error9; distinct original parameter metadata is retained in comments. |
| [buffered_files/](buffered_files/) | All5 bodies: return-only entry, buffered read/write, repeated-space decoding and whole-record save/restore. Core0:7/8/33 dependencies are recovered. |
| [runtime_initialization/](runtime_initialization/) | All10 bodies: character-set/configuration loading, device scan, file allocation, console setup and the [entry](runtime_initialization/rt_initialize_system.pas) with compatibility diagnostics. |
| [program_loader/](program_loader/) | All10 bodies: filename normalization, code-header validation, segment registration, library loading and the [entry](program_loader/rt_select_program.pas) selecting attach/startup/named code. |
| [file_manager/](file_manager/) | All15 bodies: file initialization/open/close/flush, directory loading/writing/search/editing, allocation and name parsing. Helpers14/15 nest within open4. |
| [startup_and_save/](startup_and_save/) | All8 bodies: disk-side checks, graphics/buffer setup, save/restart and completion display; [entry](startup_and_save/run_startup_or_save.pas) includes its seven children. |
| [game_dispatch/](game_dispatch/) | All6 bodies, also covering the identical disk2 startup: game dispatch, heap setup, error display and the [program block](game_dispatch/startup_program_entry.pas). |
| [save_game_utility/](save_game_utility/) |All50 bodies: name entry, initialization, attribute editing, slot display/setup, play transition, deletion, reboot and menus, assembled by the [program block](save_game_utility/utility_main_loop.pas). |
| [personal_panel/](personal_panel/) | All 18 bodies, including the complete entry and nested scope in [run_personal_panel.pas](personal_panel/run_personal_panel.pas). |
| [tactical_console/](tactical_console/) | All23 bodies: tactical setup, display, firing, cargo, menus, transitions and the enclosing [entry](tactical_console/run_tactical_console.pas). |
| [spaceflight/](spaceflight/) | All52 bodies: systems display, map rendering/selection, travel, menus, rescue setup and the enclosing [entry](spaceflight/run_space_console.pas). |
| [ship_components/](ship_components/) | All12 bodies, including menus, item transfers, repair updates and the entry in [run_component_panel.pas](ship_components/run_component_panel.pas). |
| [ship_interior/](ship_interior/) | All16 bodies, including drawing, setup, table updates, transitions, and the entry in [run_ship_interior.pas](ship_interior/run_ship_interior.pas). |
| [building_interiors/](building_interiors/) | All 28 bodies, including the complete entry and nested scope in [run_building_interior.pas](building_interiors/run_building_interior.pas). |
| [dialogue/](dialogue/) | All48 bodies, including setup, dialogue, trading, and the entry in [run_dialogue_session.pas](dialogue/run_dialogue_session.pas). |
| [street_encounters/](street_encounters/) | All 17 bodies, including the complete entry and nested scope in [run_street_encounter.pas](street_encounters/run_street_encounter.pas). |
| [civic_services/](civic_services/) | All 26 bodies, including transport, bank/depot menus, and the entry in [run_civic_services.pas](civic_services/run_civic_services.pas). |
| [cargo_exchange/](cargo_exchange/) | All 32 bodies, including pricing, trading, warehouse menus, and the entry in [run_cargo_exchange.pas](cargo_exchange/run_cargo_exchange.pas). |
| [surface_maps/](surface_maps/) | All 41 bodies, including the complete entry and nested scope in [run_surface_maps.pas](surface_maps/run_surface_maps.pas). |
| [graphics_and_io/](graphics_and_io/) | All45 p-code bodies and all18 native contracts, including buffer setup, row-table initialization, and plotting. Raw-call declarations describe each evidenced target separately. |
| [tile_rendering/](tile_rendering/) | Complete return-only entry1 and native interfaces2–4. Interface3 documents extra native stack consumption. |
| [flight_and_effects/](flight_and_effects/) | All14 p-code bodies and all3 native contracts, including circle drawing, packed-coordinate distance, screen effects, and fixed-address image decoding. |
| [menus/](menus/) | All 9 menu-item bodies; DATASEG30 caption/item views, with procedure9 nested in6. |
| [title_and_boot/](title_and_boot/) | All11 p-code bodies and seven native contracts for each active disk variant; choose its identification constant as described in the [notes](../../docs/decompilation/library_26.md). |
| [item_panels/](item_panels/) | All 15 bodies; DATASEG31 views for bounds, a packed item table, and a caption-table address. |
| [amount_arithmetic/](amount_arithmetic/) | All 6 two-word amount arithmetic/formatting bodies. |

The `.pas` files are declaration/body includes. Include `shared_game_state.pas`,
`startup_and_save/types.pas`,
`tactical_console/types.pas`, `spaceflight/types.pas`, `ship_components/types.pas`, `ship_interior/types.pas`, `dialogue/types.pas`, `street_encounters/types.pas`, `building_interiors/types.pas`, `civic_services/types.pas`, `cargo_exchange/types.pas`,
`surface_maps/types.pas`, `surface_maps/map_types.pas`, `menus/types.pas`, and `item_panels/types.pas` in a type section. For the
game12/13 type views, include game19 types first. Include game12’s entry before
game13’s entry; game12:16 is nested in15. For the completed games,
`run_personal_panel.pas` supplies the parent, locals, and children; include game8
before game18, after their library dependencies and required runtime interfaces.
Startup7 also requires its native target interface and the recovered library26
scope with a disk identification constant. Its runtime binding must preserve
the original nonlocal-exit segment-release epilogue.
Startup_disk1's entry is a program-block include ending in `end.`, after the
program header, shared declarations and dependencies. Procedure5 is nested in4.
Its game18 call expresses raw addresses with `ord(@...)`; the reference compiler
crashes on that cast. A temporary VAR-call check verifies the argument layout,
but direct compilation of that expression and runtime bindings remain unresolved.
Utility types belong after `shared_game_state.pas`; `u1: utilframe` represents its1044-byte
program frame, not DATASEG29. Place it first among program variables to retain
slots3–524. Its `utility_main_loop.pas` includes all49 descendants in dependency order and
ends in `end.`; include it after the recovered library dependencies and runtime
interfaces. Slot views retain64-byte records,
packed location, attributes and timestamps. Procedure3 retains raw string
addresses92/41; its reference compilation adds a four-byte COPY temporary.
Scope31 supplies its340-byte frame and all eight
nested keyboard/name-entry bodies32–39. Its keyboard records are five words,
and its separate editing count remains distinct from the string length byte.
Scope9 supplies its34-byte `initwork: utilinit` frame
and all twelve descendants10–21, with15 nested in14. This completes the
initializer, including buffer packing, disk writes and initial location copies.
The code rows in14 retain untouched packed values and spare bits, and13 retains
the originally uninitialized parent word9. Random expressions
use `proc22_3 + 0` where needed to force a call before MOD in the reference
compiler, which removes the addition without dropping the call.
Scope22 supplies its70-byte attribute-editor frame and eight children23–30.
Its input masks preserve eager polls, and29 retains the original unspecified
direction word until assigned. The complete utility fixture retains all50
parameter sizes/lexical levels and all88 literal occurrences;48 local sizes
match. Main's stand-in DATA variables add1254 bytes beyond the1044-byte utility
frame; procedure3 has the documented COPY temporary. The utility's original
error dispatch, native bindings and nonlocal-exit segment-release epilogue
remain runtime integration requirements. No utility runtime execution is claimed.
System types follow `shared_game_state.pas`. System2 bodies are separate lexical-level1
declarations;1 is a return-only segment initializer. Include
[core IO forwards](runtime_core/io_forwards.pas) before them to declare the
recovered7/8/33 bodies involved in mutual recursion. `sysio: ^integer` must
alias the runtime error pointer read by system2's `LOD 2,1`, also exposed as
`sy0e.state^.words[0]` by the core. All5 system2 frame interfaces match;
system1 also matches. System1 exposes callable `sys1_1(arg1,arg2:syswptr)`;
core32/38/39 pass two nil address words which its body never reads. System3
remains a program-block include ending in `end.`. Both call recovered
`sys0_2(code: integer)`. System3's original parameter
area is0 bytes; the ordinary compiler program header emits4. Runtime static
links, cross-segment calls and this unusual program ABI remain unvalidated.
System4 types follow `runtime_file_types.pas`. `syse: s4env` denotes the runtime
ancestor frame, accessed at lexical depth1/2/3 from entry/children/grandchildren;
`s4work: s4root` denotes the612-byte entry frame. These are explicit storage
views, not new DATA segments. Its `rt_initialize_system.pas` defines callable `rt_initialize_system`,
owns local `s4work` and includes all nine descendants;3 includes4–6, and7
includes8. Include shared runtime interfaces
and [system4's IO-check binding](runtime_initialization/runtime_interfaces.pas) before the entry.
All core dependencies are recovered. Core and system2/6 bodies compile with system4 callers in a
combined temporary check. File arguments address raw header word0;
buffer/caption arguments preserve the evidenced pointer words. All nine child
frames match. The named entry now retains its original612 local/0 parameter
bytes; host lexical levels shift by1. The earlier standalone fixture included
ancestor stand-ins in its entry frame. All16 nonempty
literals and four empty-string assignments are retained. Runtime bindings remain
outstanding, including the ancestor static link,2's close target$004D,1's release
target$0796 and explicit CSP0 checks. Both compatibility failures loop forever.
System5 types follow the system4 types. `sy5e: s5env` aliases the same
runtime ancestor storage as `syse`; it must not be a separate copy. Its entry
function includes all nine descendants, with6 nested in5. Include the explicit
IO-check contract before the entry. All core dependencies, including failure
routine2, are recovered. Core and system2/6 bodies pass a combined temporary
compilation check with their system5 callers.
The ordinary host fixture shifts lexical
levels by one and cannot establish the original level0 RBP1 function-entry ABI.
Unused locals are omitted in1/5, and2 adds a pointer for viewing raw strings.
See the [progress notes](../../docs/decompilation/README.md) for the focused
checks and the distinct success/failure cleanup behavior. No runtime execution
is claimed.

System6 types follow `runtime_file_types.pas` and the system4 types. `sy6e: s4env`
aliases the same runtime ancestor as `syse` and `sy5e.common`, including the
configuration/error pointer at word1. Its recovered routines are separate
lexical-level1 declarations except14/15;1 is only the segment initializer.
Include in order1/2/7/8/9/10/6/11/12/13/3/4/5 before the system4/5 callers.
Open4 includes14, which includes15. Its VAR filename accepts shorter strings
without copying them before parser11. Open4 preserves the2028-byte heap swap,
514-byte buffer-tail clear and original cleanup jumps. Close5 retains full-word
date copies, duplicate deletion and the final file-flag order.
Core7/25/26/27 are recovered dependencies. Directory records use a
13-word stride. Loader9 allocates only256 words and reads512 bytes at block79;
the nominal78-entry view does not resize that storage. Writer10 saves the first
write's result across its optional second write. Lookup6 preserves the raw
search word and its distinct cache-age and IO-result tests. Their TIME calls
require SunDog's CSP9 handler, which writes zero to both outputs. The
[parser](file_manager/rt_parse_file_spec.pas) uses a value input and VAR outputs;
its raw string views preserve core-call addresses and partial outputs. The
[flush](file_manager/rt_flush_file.pas) preserves raw low-bit flags and unchecked IO.
Focused compilation/emission checks cover all fifteen bodies, with original
parameter widths and lexical levels; runtime links and execution remain open.

Core string types follow `shared_game_state.pas`; include23–27 before system6's parser.
Core3–6 follow the system6 bodies and precede their system4 callers. They forward
the original pointer words, including a borrowed VAR filename in5. Flag readers
10/11 require `runtime_file_types.pas` and return full integer words;9/14/15 are
evidenced return-only bodies. These core bodies are originally lexical-level0,
with RBP returns; ordinary host fixtures use level1/RNP and do not establish
the runtime ABI. The string routines' extra pointer views alias caller storage.
Core23 honors explicit capacities, including120;25 clears its destination before
checking source length, and26 does not clip an overlong deletion. Core27's VAR
needle accepts literal and shorter-string arguments without an entry copy; its
SCAN requires SunDog's inclusive-endpoint CSP11 semantics. The original80-byte
string capacity of its local temporary is retained. No runtime execution is claimed.

Core I/O uses `sy0e: s4env` as another view of the SAME ancestor as `syse`,
`sy6e` and `sy5e.common`; temporary fixtures use separate stand-ins. After the
IO forwards, system2 bodies and system6 dependencies, include core7/8, then
16/17/20/19/21/22/33/34/35/18 and29/30/31. Core7/8/33 definitions complete the
forward declarations without repeating their parameters. Include `rtiochk`'s
explicit CSP0 contract before the console routines. Core19 borrows strings;
its payload pointer performs the original byte-address+1 operation without
copying. Core7/8 omit five unused local words each;18/19/22/35 add one alias
pointer. Character buffering, low-bit flags, recursive space decoding, extent
extension and console editing retain the original operation order. Core33 can
report no extension without setting failure flags. Core34's fixed11>0 test is
always true, so its trailing control string is emitted for every nonzero code.
All these bodies compile together and with system4/5 callers, with matching
parameter widths. Source review and compiler checks do not establish runtime ABI.

Core `io_types.pas` follows `runtime_file_types.pas`. Number input12 preserves its
92-byte frame because raw editing reads can reach beyond its81-byte dummy text;
formatting13 uses the ancestor power table and a separate -32768 literal.
After the earlier core bodies, include12/13/36/28/2/37, callable system1/system4
and system5, then38/39/32, and finally the core1 program block. Helper36 splits
block transfers at63 blocks;28 retains signed16-bit arithmetic and backward
SCAN's inclusive endpoint. Core38/39 explicitly release their loaded segments
on self-exit; runtime nonlocal EXIT must enter the documented release epilogues.
The combined temporary check contains all39 core and all system1/2/4/5/6 bodies,
with no p-code external stubs. Only the three explicit runtime contracts remain
external. Its independent ancestor variables and ordinary host root are stand-ins:
core1 originally has1068 locals, zero parameters, lexical-1 and XIT, whereas the
host root has4274 locals, four parameters, lexical0 and RBP. The recovered sources
are not a linked runtime replacement, and no runtime execution is claimed.

Game17 uses three VAR integer parameters. Its save/restore routines require the
documented physical frame layout and retain the original copy past the declared
parent locals; see the [completion notes](../../docs/decompilation/game_17_complete.md).
The civic services `run_civic_services.pas` supplies its parent scope and includes its25 child bodies.
The cargo exchange `run_cargo_exchange.pas` supplies its parent scope and all 31 child bodies.
Procedure 8:4 is nested inside 8:3; 14:10 is nested inside14:9; 18:7 is nested inside 18:6;
18:17 is nested inside 18:16; 24:10 is nested inside24:2; 22:58 is nested inside 22:57; 22:62 is nested inside
22:42; 22:59/60 are nested in 22:28/29; 24:16/17 are nested in 24:15;
27:14 is nested inside 27:11. In game19,13/14 are nested in12,19 in18,
22 in21, and23 in22. In game16,9/10 are nested in8,14 in13,18–21 in17,22 in18,24/26–29 in23,25 in24,36 in35,38/39 in37, and42/43 in41. In game20,6 is nested in5,14/15 in13,17/19 in16,18 in17,22 in21,
and29/30/31 in28. In game21,4 is nested in3,20 in19,24 in23,
34/35 in33, and39 in38; its enclosing entry now includes all40 children.
Names have distinct first eight
characters for reference-compiler compatibility. They describe observed roles
or storage offsets and are not claims about original names.

Recovered game-18 children refer to the parent's raw parameter words as `arg4` through
`arg1`, matching their frame slots. Slots 4, 3, and 2 are dereferenced through local
address views. The parent body is recovered; raw addresses retain the evidenced calling convention.

`data29`, `data30`, and `data31` denote existing external DATASEG29/30/31. The compile-only fixture uses
stand-in storage and an empty main body. The completed game entries supply their recovered parent bodies. The smaller fixture includes game21's full scope;
the older fixture retains its partial game21 scaffold. Game16's complete scope
is also included in the smaller fixture. Game15's complete scope retains its
original52-byte parent frame and calls the complete [game14 entry](ship_components/run_component_panel.pas),
which retains its204-byte local frame and includes all11 children.
Neither fixture binds the sources to the original runtime. Native `external` declarations describe signatures
and do not link the original library by themselves. The explicit
[runtime interfaces](segment_runtime_interfaces.pas) also require bindings for segment
load/release and the nonlocal-exit release epilogues of games15/16/18/19/20/21.

The [inventory](../../docs/decompilation/inventory.json) records identities and
per-procedure status, including separately deferred retained/alternate code.
[Recovery notes](../../docs/decompilation/game_18.md) explain interfaces,
layouts, source mappings, and reproduction commands; the
[dependency group](../../docs/decompilation/game_18_dependencies.md) and
[movement group](../../docs/decompilation/game_18_movement.md) extend them;
[setup notes](../../docs/decompilation/game_18_setup.md) cover pointers and unit I/O,
and [state notes](../../docs/decompilation/game_18_state.md) cover frame copies and input.
The [condition-display group](../../docs/decompilation/game_8_condition.md) adds
game-8 bounds, bars, and captions plus library text and coordinate helpers.
The [library-27 group](../../docs/decompilation/library_27.md) covers its complete
item-table, selection, and drawing routines.
The [clock group](../../docs/decompilation/game_8_clock.md) adds packed time,
condition updates, and game8 setup/restoration.
The [resource group](../../docs/decompilation/library_24_resources.md) adds
library24 record checks and resource updates with shared nested state.
The [shared-library completion](../../docs/decompilation/library_24_resources.md#shared-library-completion)
finishes libraries22/24. The [update group](../../docs/decompilation/library_24_updates.md) adds movement,
damage, the shared library24 update entry, game8:3/4, and native24:4.
The [game8 completion group](../../docs/decompilation/game_8_complete.md) adds
its entry, selection, wait, status, pause, and rest routines.
The [game18 completion group](../../docs/decompilation/game_18_complete.md) adds
its enclosing entry and remaining selection/update routines.
The [game17 helper group](../../docs/decompilation/game_17_helpers.md) adds setup,
selection, hit/damage, and drawing routines, preserving its packed frame layout.
The [game17 completion group](../../docs/decompilation/game_17_complete.md) adds
its entry, save/restore, and update routines.
The [game19 dependency group](../../docs/decompilation/game_19_dependencies.md)
adds libraries25/28, library22:36, and seven game19 helpers.
The [game19 completion group](../../docs/decompilation/game_19_complete.md)
adds its remaining19 bodies. The [game20 warehouse group](../../docs/decompilation/game_20_warehouse.md)
adds15 setup/inventory/menu bodies; the [completion group](../../docs/decompilation/game_20_complete.md)
adds its remaining 17. The [game21 group](../../docs/decompilation/game_21_map.md)
now covers all41 game21 bodies plus library22:6 and library23:1 and the required native contracts.
The [game16 completion notes](../../docs/decompilation/game_16_helpers.md) cover all48
bodies, including pricing, text, dialogue, trading, setup, and the enclosing entry.
The [game15 notes](../../docs/decompilation/game_15.md) cover all16 bodies,
its dependency interface, and its release-epilogue binding requirement. The
[game14 notes](../../docs/decompilation/game_14.md) cover its complete recovery.
The [game13 notes](../../docs/decompilation/game_13.md) cover all52 bodies, including
the entry's segment-release epilogue. The combined game12/game13 temporary check
includes both actual entries and all their children. The native travel declarations require the documented
overlay binding and original frame layout for the fifth warp-argument byte.
The two maintained compilation fixtures cover338 recovered routines;42 further
game13 bodies passed temporary compilation/disassembly checks, including a check
of the complete module. The
documented game20:31 string-capacity warning is confined to the first fixture. The second
warns about the intentional goto used for the permanent checksum-failure loop.
The [game12 notes](../../docs/decompilation/game_12.md) cover all23 bodies and
three raw viewscreen-overlay contracts. All23 frame interfaces match the original
in the combined check. Raw address45 passed to the string printer, single-word
bounty addition, early exits, mandatory input/random calls, aliased outputs and
the cargo read before its index check remain explicit. These23 bodies are outside
the two maintained fixtures.
Within the maintained fixtures, ten substantive bodies and four return-only
bodies reproduce exact bytes;
whole-module recompilation and runtime equivalence remain unproven.

The [library26 notes](../../docs/decompilation/library_26.md) cover both active disk
variants:22 targeted bodies using11 shared source files, with a separate CONST
include for each disk's title string. Include library26's native contracts and
outer procedures1/2/4/5/13/6/7 after the library22/25 dependencies. Procedure13
includes14/16,14 includes15, and7 includes17. Dictionary18 has an internal
register-call contract and intentionally has no invented Pascal signature.
Both temporary variant checks preserve every frame interface and caption.
Procedure4 and the return-only entry reproduce exact body bytes in both
contexts; these checks do not establish runtime equivalence.
