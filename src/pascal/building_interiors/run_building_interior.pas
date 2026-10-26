{ game_18 procedure1, $17F2..$183D, attributes $184C.
  Raw argument words4/3/2 denote caller-owned addresses; argument1 is a selector.
  Locals retain the original298-byte layout for nested access and frame copies.
  Runtime segment operations require the bindings in runtime_interfaces.pas. }
procedure run_building_interior(window_x_address, window_y_address, resume_address, venue_kind: integer);
var
(*$include src/pascal/building_interiors/locals.pas*)
(*$include src/pascal/building_interiors/inside_actor_area.pas*)
(*$include src/pascal/building_interiors/query_actor_mask.pas*)
(*$include src/pascal/building_interiors/toggle_room_actor.pas*)
(*$include src/pascal/building_interiors/reindex_room_references.pas*)
(*$include src/pascal/building_interiors/remove_room_actor.pas*)
(*$include src/pascal/building_interiors/find_counter_position.pas*)
(*$include src/pascal/building_interiors/find_open_room_position.pas*)
(*$include src/pascal/building_interiors/redirect_room_actor.pas*)
(*$include src/pascal/building_interiors/send_actor_to_exit.pas*)
(*$include src/pascal/building_interiors/step_room_actor.pas*)
(*$include src/pascal/building_interiors/create_room_actor.pas*)
(*$include src/pascal/building_interiors/seed_room_actors.pas*)
(*$include src/pascal/building_interiors/set_service_indicator.pas*)
(*$include src/pascal/building_interiors/load_room_layout.pas*)
(*$include src/pascal/building_interiors/paint_room_counter.pas*)
(*$include src/pascal/building_interiors/paint_service_stations.pas*)
(*$include src/pascal/building_interiors/prepare_room_scene.pas*)
(*$include src/pascal/building_interiors/restore_room_session.pas*)
(*$include src/pascal/building_interiors/save_room_session.pas*)
(*$include src/pascal/building_interiors/probe_counter_neighbor.pas*)
(*$include src/pascal/building_interiors/refresh_service_area.pas*)
(*$include src/pascal/building_interiors/switch_room_context.pas*)
(*$include src/pascal/building_interiors/tick_room_player.pas*)
(*$include src/pascal/building_interiors/tick_service_actor.pas*)
(*$include src/pascal/building_interiors/advance_room_customers.pas*)
begin
  rtldseg(8);
  rtldseg(27);
  restore_room_session;
  repeat
    tick_room_player;
    tick_service_actor;
    advance_room_customers;
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then advance_clock_and_conditions;
    if odd(data29.words[347]) then switch_room_context(false)
  until odd(room_controls[143]);
  toggle_pointer_glyph(room_controls[134], room_controls[133]);
  save_room_session;
  { Original exit-attribute target $182D begins this release epilogue.
    A runtime binding must preserve that target for nonlocal EXIT as well. }
  rtrlseg(27);
  rtrlseg(8)
end;
