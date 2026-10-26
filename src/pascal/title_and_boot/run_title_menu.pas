{ Both library26 variants: procedure6, $02C8..$06DA, attributes $06EA.
  id26 is the disk-specific20-byte literal at$03F7; select exactly one
  identity.pas in the CONST section. All other instructions agree.
  Keep the original disk reads/writes, random calls, seed copies and reboot
  transfer. Private unused slots4/5 save BOTH title-screen input polls.
  Header byte0 is compared with zero (not bit0); other Boolean slots use bit0. }
procedure run_title_menu(playing_disk: boolean);
var
  state_header: address16; {2}
  boot_block: integer; {3}
  poll0: integer; {4}
  poll1: integer; {5}
  saved_checksum: integer; {6}
  actual_checksum: integer; {7}
  timeout: integer; {8}
  boot_image: integer; {9}
  other_disk_choice: integer; {10}
  choice: integer; {11}
  top: integer; {12}
  right: integer; {13}
  slot_or_random: integer; {14; later random scratch}
  play_blocked: integer; {15}
  invalid_slot: integer; {16}
  game_damaged: integer; {17}
  game_won: integer; {18}
  player_dead: integer; {19}
  new_game: integer; {20}
  skip_title: integer; {21}
begin
  game_damaged := 0;
  invalid_slot := 0;
  state_header.word := 5120;
  disk_blocks_io(5120, 1, 80, true);
  skip_title := ord(state_header.bytes^[0] <> 0);
  slot_or_random := state_header.bytes^[1];
  boot_block := state_header.bytes^[7] - 3;
  moveleft(state_header.bytes^[2], data29.words[21], 4);
  data29.words[31] := 10 * slot_or_random + 24;
  if slot_or_random < 4 then
    disk_blocks_io(word_address(data29.words[36]), 1, data29.words[31], true)
  else data29.flags82[122] := false;
  if not odd(skip_title) then animate_title_letters;
  if playing_disk then
  begin
    other_disk_choice := 1;
    boot_image := 77
  end
  else
  begin
    other_disk_choice := 2;
    boot_image := 78
  end;
  if slot_or_random < 4 then
  begin
    disk_blocks_io(16384, 10, data29.words[31], true);
    if playing_disk then disk_blocks_io(22528, 4, 194, true);
    actual_checksum := even_odd_checksum(16384, 10);
    disk_blocks_io(5632, 1, 23, true);
    copy_raw_bytes(5662 + 64 * slot_or_random, word_address(saved_checksum), 2);
    if saved_checksum <> actual_checksum then
    begin
      game_damaged := 1;
      state_header.bytes^[1] := 255
    end
  end
  else
  begin
    invalid_slot := 1;
    data29.name255 := 'there'
  end;
  if (not odd(skip_title)) or playing_disk then push_text_window(40, 24);
  if not odd(skip_title) then
  begin
    clear_text_window;
    write_wrapped_text('|||||||SunDog>\');
    write_wrapped_text('||||Frozen Legacy\');
    write_wrapped_text('|||||Version 2.0\|\');
    write_wrapped_text(id26);
    write_wrapped_text('|by FTL Games, Inc.\');
    write_wrapped_text('|All rights reserved\|\');
    write_wrapped_text('|Press either joystick\');
    write_wrapped_text('||||button to begin');
    timeout := 11400;
    repeat
      slot_or_random := random_word;
      timeout := timeout - 1;
      poll0 := poll_input(0);
      poll1 := poll_input(1)
    until odd(poll0) or odd(poll1) or (timeout <= 0);
    moveleft(data29.words[21], state_header.bytes^[2], 4);
    clear_text_window;
    player_dead := ord(data29.nibbles45[2] = 12);
    game_won := ord(data29.nibbles45[2] = 13);
    new_game := ord((data29.clock42.day = 0) and
                   (data29.clock42.hour = 0) and (data29.clock42.minute = 0));
    if odd(player_dead) or odd(game_damaged) then write_wrapped_text('Too bad, ')
    else if odd(game_won) then write_wrapped_text('Well done, ')
    else write_wrapped_text('Hello, ');
    write_wrapped_text(data29.name255);
    play_blocked := player_dead or game_won or game_damaged or invalid_slot; {bitwise OR of0/1 words}
    if odd(play_blocked) then
    begin
      if odd(player_dead) or odd(game_won) then
      begin
        if odd(player_dead) then write_wrapped_text('.  You died')
        else write_wrapped_text('!  You won');
        write_wrapped_text(', so your game is over')
      end
      else if odd(game_damaged) then write_wrapped_text('.  Your game is damaged')
    end;
    write_wrapped_text('.  You can ');
    if not odd(play_blocked) then
    begin
      if odd(new_game) then write_wrapped_text('start') else write_wrapped_text('continue');
      write_wrapped_text(' your game, ')
    end;
    write_wrapped_text('use the utilities or run the demo.');
    right := data29.words[13] - data29.words[14] - 4;
    top := data29.words[11] - data29.words[12] - 42;
    reset_menu;
    if not odd(play_blocked) then add_menu_button(2, 'Play SunDog>', 4, right, top, top + 10);
    top := top + 15;
    add_menu_button(1, 'Use utilities', 4, right, top, top + 10);
    top := top + 15;
    add_menu_button(3, 'Run demo', 4, right, top, top + 10);
    repeat
      select_title_menu(choice, 1)
    until choice > 0;
    if (choice = other_disk_choice) or (choice = 3) then
    begin
      if choice = 3 then boot_image := 79
      else
      begin
        state_header.bytes^[0] := 255;
        disk_blocks_io(5120, 1, 80, false)
      end;
      disk_blocks_io(5120, 1, boot_image, true);
      disk_blocks_io(5120, 1, boot_block, false);
      pop_text_window;
      reboot_with_caption('MUST')
    end
    else if not playing_disk then pop_text_window
  end
  else
  begin
    state_header.bytes^[0] := 0;
    disk_blocks_io(5120, 1, 80, false)
  end
end;
