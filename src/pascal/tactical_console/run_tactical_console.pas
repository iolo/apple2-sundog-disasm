{ game_12 procedure1, $1374..$1562, attributes $1578.
  All22 children share this94-byte frame;16 is nested in15. No segment
  load/release occurs here: game13 supplies the enclosing runtime context.
  Counter354 is tested by BIT0, not nonzero. Input1's close path skips
  dispatch/rebuild; only a positive menu hit reaches the rebuild below. }
procedure run_tactical_console;
var g12: g12frame;
(*$include src/pascal/tactical_console/swap_tactical_buffers.pas*)
(*$include src/pascal/tactical_console/draw_target_hull.pas*)
(*$include src/pascal/tactical_console/paint_target_panel.pas*)
(*$include src/pascal/tactical_console/setup_sensor_panel.pas*)
(*$include src/pascal/tactical_console/handle_target_destroyed.pas*)
(*$include src/pascal/tactical_console/fire_tactical_weapon.pas*)
(*$include src/pascal/tactical_console/draw_radar_contact.pas*)
(*$include src/pascal/tactical_console/setup_tactical_view.pas*)
(*$include src/pascal/tactical_console/move_tactical_view.pas*)
(*$include src/pascal/tactical_console/flash_target_hit.pas*)
(*$include src/pascal/tactical_console/tick_tactical_controls.pas*)
(*$include src/pascal/tactical_console/open_tactical_menu.pas*)
(*$include src/pascal/tactical_console/close_tactical_menu.pas*)
(*$include src/pascal/tactical_console/build_tactical_menu.pas*)
(*$include src/pascal/tactical_console/run_manual_combat.pas*)
(*$include src/pascal/tactical_console/tractor_wreck_cargo.pas*)
(*$include src/pascal/tactical_console/adjust_tactical_setting.pas*)
(*$include src/pascal/tactical_console/switch_tactical_menu.pas*)
(*$include src/pascal/tactical_console/jettison_cargo_pods.pas*)
(*$include src/pascal/tactical_console/hail_target_ship.pas*)
(*$include src/pascal/tactical_console/enable_available_cloak.pas*)
begin
  open_tactical_menu('TACTICAL');
  setup_tactical_view;
  build_tactical_menu;
  g12.exit_requested := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if odd(data29.words[354]) then tick_tactical_controls
    else update_pointer(g12.cursor_x, g12.cursor_y);
    apply_bounds(data29.bnd335, 0);
    if odd(poll_input(1)) then
    begin
      if g12.menu_mode = 0 then g12.exit_requested := 1
      else
      begin
        if g12.menu_mode = 2 then
        begin
          swap_tactical_buffers;
          paint_target_panel;
          swap_tactical_buffers
        end;
        g12.menu_mode := 0;
        close_tactical_menu;
        build_tactical_menu;
        g12.exit_requested := poll_input(1)
      end
    end
    else if odd(poll_input(0)) then
    begin
      find_menu_item(g12.cursor_x - g12.menu_x_origin, g12.cursor_y - g12.menu_y_origin,
                   g12.menu_action, g12.menu_item);
      if g12.menu_item > 0 then
      begin
        play_sound(30, 50, 10, 0, 0, 0, 0);
        toggle_pointer_glyph(g12.cursor_x, g12.cursor_y);
        tick_tactical_controls;
        activate_menu_item(g12.menu_item, g12.menu_action, data29.bnd335,
                     g12.words[13], g12.words[13]);
        case g12.menu_action of
          2: if data29.fuel_amount = 0 then play_sound(10, 40, 50, 0, 0, 0, 0)
             else switch_tactical_menu(1, 'SHIELDS');
          3: switch_tactical_menu(3, 'GUNS');
          4: jettison_cargo_pods(0);
          5: enable_available_cloak;
          6: data29.flags82[12] := false;
          7: hail_target_ship;
          8: adjust_tactical_setting(64, 4, data29.shield_setting);
          9: adjust_tactical_setting(-64, 4, data29.shield_setting);
          10: adjust_tactical_setting(-256, 4, data29.shield_setting);
          11, 12, 13: jettison_cargo_pods(g12.menu_action - 10);
          14, 15: begin
                    g12.laser_selected := ord(g12.menu_action = 14);
                    run_manual_combat
                  end;
          16: tractor_wreck_cargo;
          17: adjust_tactical_setting(256, 4, data29.shield_setting)
        end;
        if not odd(g12.exit_requested) then build_tactical_menu
      end
    end
  until odd(g12.exit_requested) or odd(data29.words[347]);
  if odd(g12.words[28]) then data29.flags82[44] := true;
  data29.nibbles45[1] := 1;
  select_drawing_buffer(data29.words[16], false);
  if g12.saved_flight_mode = 0 then data29.map_view_kind := 2
  else data29.map_view_kind := g12.saved_flight_mode;
  data29.flags82[5] := false;
  if odd(data29.words[347]) and (data29.nibbles45[2] = 10) then
  begin
    data29.nibbles45[2] := 2;
    data29.nibbles45[1] := 0
  end
  else if data29.nibbles45[2] <> 9 then
  begin
    apply_bounds(data29.bnd343, 8);
    if not odd(data29.words[347]) then data29.nibbles45[2] := 0;
    data29.nibbles45[0] := 11;
    apply_bounds(data29.bnd339, 8)
  end;
  select_drawing_buffer(data29.words[15], true);
  close_tactical_menu
end;
