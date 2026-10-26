{ game_13 procedure1, entry $2586, body $2588..$2759, load $2762..$2768,
  release epilogue $275A..$2760, return $276A; attributes $277A.
  Load12/25 before setup and release25/12 on normal return. The original exit
  attribute targets the release epilogue, so nonlocal EXIT needs that runtime
  binding. The reference compiler's external segment calls do not supply it.
  Eight local words retain the frame shared by all52 procedures.
  Tactical proc12_1 has no arguments/result (game_12 attributes $1578).
  Include its recovered entry and children before this scope. }
procedure run_space_console;
var space_ui: array[1..8] of integer;
(*$include src/pascal/spaceflight/seed_system_stars.pas*)
(*$include src/pascal/spaceflight/run_system_status.pas*)
(*$include src/pascal/spaceflight/select_map_location.pas*)
(*$include src/pascal/spaceflight/execute_flight_plan.pas*)
(*$include src/pascal/spaceflight/append_space_button.pas*)
(*$include src/pascal/spaceflight/open_space_menu.pas*)
(*$include src/pascal/spaceflight/close_space_menu.pas*)
(*$include src/pascal/spaceflight/poll_space_menu.pas*)
(*$include src/pascal/spaceflight/browse_world_maps.pas*)
(*$include src/pascal/spaceflight/run_navigation_menu.pas*)
(*$include src/pascal/spaceflight/group_below_limit.pas*)
(*$include src/pascal/spaceflight/build_space_menu.pas*)
(*$include src/pascal/spaceflight/request_rescue_refuel.pas*)
begin
  rtldseg(12);
  rtldseg(25);
  update_flight_state;
  if not data29.flags82[35] then
    select_map_location(data29.map_view_kind, data29.pos72, space_ui[4], 1, 1);
  space_ui[4] := ord(data29.nibbles45[1] <> 9);
  if data29.flags82[51] and data29.flags82[34] then
  begin
    request_rescue_refuel;
    space_ui[4] := 1
  end;
  data29.flags82[34] := false;
  if data29.nibbles45[2] <> 1 then data29.flags82[35] := false;
  data29.flags82[51] := false;
  disk_blocks_io(2048, 2, data29.words[27] + 2, true);
  seed_system_stars;
  data29.flags82[118] := false;
  data29.flags82[119] := false;
  if data29.nibbles45[2] = 1 then
  begin
    space_ui[3] := 3;
    data29.nibbles45[2] := 0
  end
  else space_ui[3] := 0;
  data29.words[353] := 5;
  repeat
    if odd(space_ui[4]) then apply_bounds(data29.bnd335, 8)
    else apply_bounds(data29.bnd335, 0);
    space_ui[4] := 0;
    set_text_window(data29.words[342], data29.words[341],
                data29.words[340], data29.words[339]);
    if space_ui[3] = 0 then
    begin
      build_space_menu;
      poll_space_menu(space_ui[3], space_ui[2], data29.words[297], data29.bnd335, space_ui[4])
    end;
    if (not odd(space_ui[4])) and (not odd(data29.words[347])) then
      data29.nibbles45[2] := 2;
    case space_ui[3] of
      1: run_system_status;
      2: run_navigation_menu;
      3: begin
           data29.nibbles45[0] := data29.nibbles45[1];
           data29.nibbles45[1] := 0;
           run_tactical_console;
           if data29.nibbles45[2] <> 9 then
             select_map_location(data29.map_view_kind, data29.pos72, space_ui[4], 1, 1)
         end;
      4: begin
           data29.nibbles45[2] := 9;
           play_sound(10, 100, 40, 252, 1, 7, 0);
           data29.flags82[34] := true
         end
    end;
    space_ui[3] := 0
  until (data29.nibbles45[2] <> 0) or odd(data29.words[347]);
  if not data29.flags82[35] then data29.nibbles45[1] := 0;
  if data29.nibbles45[2] <> 9 then data29.flags82[5] := false;
  data29.nibbles45[0] := 11;
  data29.flags45[12] := true;
  load_buffer_pair(1, 1, 2048);
  if (data29.nibbles45[2] <> 1) and (data29.nibbles45[2] <> 9) then
    if (data29.nibbles45[2] = 10) and odd(data29.words[347]) then
      data29.nibbles45[2] := 2;
  rtrlseg(25);
  rtrlseg(12)
end;
