{ game_21 procedure1, $1E48..$1F5B, attributes $1F6E.
  Load8/27/23 before setup; release23/27/8 on exit. The original exit
  attribute targets $1F45: nonlocal EXIT needs the same runtime epilogue.
  NEQ6 at $1E96 compares bit0, not full input words. The encounter predicate
  captures mode/flag before the unconditional random call and reads parent35
  afterward. Previously unused parent slot24 holds the random result without
  changing the114-byte parent frame or child lexical offsets. }
procedure run_surface_maps(var tileset_primary, tileset_secondary, map_x_origin, map_y_origin, window_x, window_y, tile_or_action, exit_requested: integer);
var
(*$include src/pascal/surface_maps/locals.pas*)
(*$include src/pascal/surface_maps/wrapped_map_offset.pas*)
(*$include src/pascal/surface_maps/load_surface_tiles.pas*)
(*$include src/pascal/surface_maps/toggle_surface_player.pas*)
(*$include src/pascal/surface_maps/commit_surface_position.pas*)
(*$include src/pascal/surface_maps/draw_parked_marker.pas*)
(*$include src/pascal/surface_maps/paint_parked_transport.pas*)
(*$include src/pascal/surface_maps/render_surface_tiles.pas*)
(*$include src/pascal/surface_maps/query_surface_mask.pas*)
(*$include src/pascal/surface_maps/leave_city_edge.pas*)
(*$include src/pascal/surface_maps/walk_surface_map.pas*)
(*$include src/pascal/surface_maps/project_map_location.pas*)
(*$include src/pascal/surface_maps/within_axis_radius.pas*)
(*$include src/pascal/surface_maps/try_board_ship.pas*)
(*$include src/pascal/surface_maps/enter_parked_transport.pas*)
(*$include src/pascal/surface_maps/derive_city_limits.pas*)
(*$include src/pascal/surface_maps/enter_city_tile.pas*)
(*$include src/pascal/surface_maps/probe_building_entrance.pas*)
(*$include src/pascal/surface_maps/check_surface_interactions.pas*)
(*$include src/pascal/surface_maps/build_heading_glyphs.pas*)
(*$include src/pascal/surface_maps/choose_surface_glyphs.pas*)
(*$include src/pascal/surface_maps/place_surface_player.pas*)
(*$include src/pascal/surface_maps/seed_city_map.pas*)
(*$include src/pascal/surface_maps/setup_city_view.pas*)
(*$include src/pascal/surface_maps/decode_planet_map.pas*)
(*$include src/pascal/surface_maps/prepare_planet_view.pas*)
(*$include src/pascal/surface_maps/setup_surface_session.pas*)
(*$include src/pascal/surface_maps/pulse_teleport_box.pas*)
(*$include src/pascal/surface_maps/paint_city_overview.pas*)
(*$include src/pascal/surface_maps/choose_teleport_destination.pas*)
(*$include src/pascal/surface_maps/perform_teleport.pas*)
(*$include src/pascal/surface_maps/charge_teleport_fare.pas*)
(*$include src/pascal/surface_maps/run_public_teleport.pas*)
(*$include src/pascal/surface_maps/evade_street_pursuer.pas*)
(*$include src/pascal/surface_maps/open_surface_personal.pas*)
begin
  rtldseg(8);
  rtldseg(27);
  rtldseg(23);
  setup_surface_session;
  repeat
    update_pointer(g21.cursor_x, g21.cursor_y);
    if odd(poll_input(1)) then
    begin
      data29.nibbles45[1] := data29.nibbles45[2];
      data29.flags45[12] := data29.flags45[13];
      if data29.flags45[13] then open_surface_personal else exit_requested := 1
    end
    else
    begin
      g21.movement_poll := poll_input(4);
      if odd(g21.movement_poll) then walk_surface_map;
      if odd(g21.was_moving) <> odd(g21.movement_poll) then
      begin
        g21.was_moving := g21.movement_poll;
        if odd(g21.was_moving) then
        begin
          data29.words[353] := g21.saved_tick_limit;
          data29.words[351] := g21.saved_time_step
        end
        else
        begin
          data29.words[351] := 1;
          data29.words[353] := 15;
          check_surface_interactions;
          if odd(g21.teleport_ready) then run_public_teleport
        end
      end;
      if (data29.nibbles45[1] <> data29.nibbles45[2]) and
         ((data29.nibbles45[2] = 3) or (data29.nibbles45[2] = 4)) then setup_surface_session;
      data29.words[354] := data29.words[354] + 1;
      if data29.words[354] >= data29.words[353] then
      begin
        advance_clock_and_conditions;
        if (data29.nibbles45[2] = 3) and data29.flags45[13] then
        begin
          g21.random_scratch := random_word;
          if (g21.random_scratch mod 64 = 21) and not odd(g21.contract_city) then
          begin
            toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
            evade_street_pursuer;
            toggle_pointer_glyph(g21.cursor_x, g21.cursor_y)
          end
        end
        else g21.random_scratch := random_word
      end
    end
  until (data29.nibbles45[2] <> data29.nibbles45[1]) or
        odd(data29.words[347]) or odd(exit_requested);
  commit_surface_position;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(23);
  rtrlseg(27);
  rtrlseg(8)
end;
