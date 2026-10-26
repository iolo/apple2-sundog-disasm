# UCSD p-code source

Source filenames describe module behavior. Component IDs and segment/procedure
numbers remain stable in comments, the reconstruction manifest and the
[naming catalog](../../docs/decompilation/identifier-names.json).
Pascal procedure files use their inferred routine names; see the
[Pascal source guide](../pascal/README.md).

| Source | Original component | Recovered Pascal entry |
| --- | --- | --- |
| [tactical_console.s](tactical_console.s) | `game_12` | [run_tactical_console.pas](../pascal/tactical_console/run_tactical_console.pas) |
| [spaceflight.s](spaceflight.s) | `game_13` | [run_space_console.pas](../pascal/spaceflight/run_space_console.pas) |
| [ship_components.s](ship_components.s) | `game_14` | [run_component_panel.pas](../pascal/ship_components/run_component_panel.pas) |
| [ship_interior.s](ship_interior.s) | `game_15` | [run_ship_interior.pas](../pascal/ship_interior/run_ship_interior.pas) |
| [dialogue.s](dialogue.s) | `game_16` | [run_dialogue_session.pas](../pascal/dialogue/run_dialogue_session.pas) |
| [street_encounters.s](street_encounters.s) | `game_17` | [run_street_encounter.pas](../pascal/street_encounters/run_street_encounter.pas) |
| [building_interiors.s](building_interiors.s) | `game_18` | [run_building_interior.pas](../pascal/building_interiors/run_building_interior.pas) |
| [civic_services.s](civic_services.s) | `game_19` | [run_civic_services.pas](../pascal/civic_services/run_civic_services.pas) |
| [cargo_exchange.s](cargo_exchange.s) | `game_20` | [run_cargo_exchange.pas](../pascal/cargo_exchange/run_cargo_exchange.pas) |
| [surface_maps.s](surface_maps.s) | `game_21` | [run_surface_maps.pas](../pascal/surface_maps/run_surface_maps.pas) |
| [personal_panel.s](personal_panel.s) | `game_8` | [run_personal_panel.pas](../pascal/personal_panel/run_personal_panel.pas) |
| [graphics_and_io.s](graphics_and_io.s) | `library_22` | [graphics_library_entry.pas](../pascal/graphics_and_io/graphics_library_entry.pas) |
| [tile_rendering.s](tile_rendering.s) | `library_23` | [tile_library_entry.pas](../pascal/tile_rendering/tile_library_entry.pas) |
| [flight_and_effects.s](flight_and_effects.s) | `library_24` | [effects_library_entry.pas](../pascal/flight_and_effects/effects_library_entry.pas) |
| [menus.s](menus.s) | `library_25` | [menu_library_entry.pas](../pascal/menus/menu_library_entry.pas) |
| [title_and_boot_disk1.s](title_and_boot_disk1.s) | `library_26_disk1` | [title_library_entry.pas](../pascal/title_and_boot/title_library_entry.pas) |
| [title_and_boot_disk2.s](title_and_boot_disk2.s) | `library_26_disk2` | [title_library_entry.pas](../pascal/title_and_boot/title_library_entry.pas) |
| [item_panels.s](item_panels.s) | `library_27` | [item_panel_library_entry.pas](../pascal/item_panels/item_panel_library_entry.pas) |
| [amount_arithmetic.s](amount_arithmetic.s) | `library_28` | [amount_library_entry.pas](../pascal/amount_arithmetic/amount_library_entry.pas) |
| [startup_and_save.s](startup_and_save.s) | `startup_7` | [run_startup_or_save.pas](../pascal/startup_and_save/run_startup_or_save.pas) |
| [game_dispatch.s](game_dispatch.s) | `startup_disk1` | [startup_program_entry.pas](../pascal/game_dispatch/startup_program_entry.pas) |
| [unbound_program_entry.s](unbound_program_entry.s) | `system_1` | [rt_unbound_entry_failure.pas](../pascal/unbound_program_entry/rt_unbound_entry_failure.pas) |
| [buffered_files.s](buffered_files.s) | `system_2` | [rt_buffer_library_entry.pas](../pascal/buffered_files/rt_buffer_library_entry.pas) |
| [empty_program_entry.s](empty_program_entry.s) | `system_3` | [rt_empty_program_failure.pas](../pascal/empty_program_entry/rt_empty_program_failure.pas) |
| [runtime_initialization.s](runtime_initialization.s) | `system_4` | [rt_initialize_system.pas](../pascal/runtime_initialization/rt_initialize_system.pas) |
| [program_loader.s](program_loader.s) | `system_5` | [rt_select_program.pas](../pascal/program_loader/rt_select_program.pas) |
| [file_manager.s](file_manager.s) | `system_6` | [rt_files_library_entry.pas](../pascal/file_manager/rt_files_library_entry.pas) |
| [runtime_core.s](runtime_core.s) | `system_core` | [runtime_main_loop.pas](../pascal/runtime_core/runtime_main_loop.pas) |
| [save_game_utility.s](save_game_utility.s) | `utility_disk1` | [utility_main_loop.pas](../pascal/save_game_utility/utility_main_loop.pas) |

[runtime_entry.s](runtime_entry.s) supplies the separately owned36-byte system
entry prefix. [title_and_boot_body.inc](title_and_boot_body.inc) supplies the
shared title/boot implementation for both disk variants. `.cfg` files retain
the original placement constraints; `.adopt.json` recipes retain disk mappings.

Retained introduction sources are named for their observed content:

- [retained_intro_dispatch.s](retained_intro_dispatch.s) and [retained_intro_display.s](retained_intro_display.s): initialization, dispatch and display helpers.
- [retained_ship_tour.s](retained_ship_tour.s): ship components, gauges, controls and introduction.
- [retained_world_tour.s](retained_world_tour.s): systems, planets, cities and travel descriptions.
- [retained_credits.s](retained_credits.s): title, contributors and credits.

These names describe static evidence and do not establish live reachability.
Their historical component IDs and numeric routine identities remain in the
catalog. The retained utility variant and clipped linker contexts remain
separate sources with their existing provenance.

```sh
python3 tools/build_disks.py --no-temporary
python3 docs/decompilation/checks/verify_identifier_names.py
```
