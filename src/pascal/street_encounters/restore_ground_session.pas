{ game_17 procedure11, $0418..$051B, attributes $0526.
  Keep exactly two local words: count must occupy slot2. The original copy
  length subtracts this CHILD address from PARENT slot99, not parent slot4.
  Under the original frame allocator this is212 bytes, extending16 bytes
  beyond the parent's196-byte local area. Preserve the raw operation. }
procedure restore_ground_session;
var
  poll4: integer;
  copy_size_or_poll5: integer;
begin
  data29.words[2] := 2;
  if resume_selector <> 0 then
  begin
    copy_size_or_poll5 := word_address(g17.save_anchor) - word_address(copy_size_or_poll5);
    g17.resume_image.word := -9408;
    moveleft(g17.resume_image.bytes^, g17, copy_size_or_poll5);
    data29.bounds11 := g17.resume_bounds;
    set_encounter_bounds(false);
    if data29.flags82[48] then update_player_stun
    else if data29.flags82[49] then
    begin
      g17.player_status := 2;
      data29.flags82[49] := false
    end;
    repeat
      poll4 := poll_input(4);
      copy_size_or_poll5 := poll_input(5)
    until not odd(poll4) and not odd(copy_size_or_poll5)
  end
  else
  begin
    if data29.ground_encounter_mode = 16 then
    begin
      data29.flags82[50] := false;
      g17.fighter_count := random_between(2, 6)
    end
    else if data29.ground_encounter_mode <> 15 then
    begin
      data29.flags82[50] := true;
      g17.fighter_count := 2
    end;
    { Mode15 deliberately leaves count94 unchanged. }
    g17.saved_clock_step := data29.words[351];
    data29.words[351] := 1;
    g17.player_status := 0;
    set_encounter_bounds(true);
    setup_ground_fighters;
    data29.flags82[48] := false;
    data29.flags82[49] := false
  end;
  find_personal_shield;
  g17.victory_pending := 0;
  g17.exit_requested := ord(data29.ground_encounter_mode = 15);
  apply_bounds(data29.bounds11, 0);
  g17.items[1].active := false;
  g17.spread_weapon_active := 0;
  g17.spread_shots_left := 0;
  if not data29.flags82[50] then equip_personal_weapon
end;
