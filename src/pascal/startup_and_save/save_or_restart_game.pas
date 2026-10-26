{ startup_7 procedure8, $042E..$06EE, attributes $0704; nested in1.
  Preserve both identical ten-block writes around checksum3, save/restart
  selection and all calls52. Integer OR retains both certificate input polls.
  The final DUST transfer invokes26:2, whose native boot call does not return. }
procedure save_or_restart_game;
var
  game_checksum: integer; {1}
  save_slot: integer; {2}
  restart_choice: integer; {3}
  unused: integer; {4}
  game_won: integer; {5}
  save_attempted: integer; {6; original store retained though not subsequently read}
begin
  while data29.words[20] > 0 do pop_text_window;
  if (data29.nibbles45[2] = data29.nibbles45[1]) and
     (data29.nibbles45[2] = 11) then
  begin
    if data29.loc37.mid5 = 0 then data29.nibbles45[1] := 2
    else if data29.bits37.mid6 = 0 then
    begin
      if data29.bytes[75] = 0 then data29.nibbles45[1] := 2
      else data29.nibbles45[1] := 4
    end
    else data29.nibbles45[1] := 3
  end;
  data29.seed64 := data29.seed21;
  game_won := 0;
  restart_choice := 2;
  save_attempted := 0;
  push_text_window(20, 12);
  if data29.nibbles45[2] = 12 then
  begin
    write_wrapped_text('Sorry, ');
    write_wrapped_text(data29.name255);
    write_wrapped_text(', you didn''t make it.\');
    write_wrapped_text('Restart at last saved point?');
    s7.words[13] := 4;
    s7.words[12] := data29.words[13] - data29.words[14] - 4;
    s7.words[11] := (s7.words[12] + s7.words[13]) div 2;
    s7.words[5] := data29.words[11] - data29.words[12] - 12;
    reset_menu;
    add_menu_button(1, 'Yes', s7.words[13], s7.words[11] - 2, s7.words[5], s7.words[5] + 10);
    add_menu_button(2, 'No', s7.words[11] + 2, s7.words[12], s7.words[5], s7.words[5] + 10);
    repeat select_title_menu(restart_choice, 0) until restart_choice > 0
  end
  else if data29.nibbles45[2] = 13 then game_won := 1
  else
  begin
    save_attempted := 1;
    if data29.nibbles45[1] < 5 then data29.nibbles45[2] := data29.nibbles45[1]
    else data29.nibbles45[2] := data29.nibbles45[0];
    data29.nibbles45[1] := 11;
    data29.nibbles45[0] := 11
  end;
  copy_raw_bytes(word_address(data29.words[36]), 16384, 512);
  disk_blocks_io(16384 + 512, 6, data29.words[30] + 3, true);
  copy_raw_bytes(-5887, 16384 + 3584, 1440);
  request_disk_side(true);
  if restart_choice = 2 then
  begin
    disk_blocks_io(16384, 10, data29.words[31], false);
    game_checksum := even_odd_checksum(16384, 10);
    disk_blocks_io(16384, 10, data29.words[31], false);
    disk_blocks_io(16384, 1, 23, true);
    save_slot := (data29.words[31] - 24) div 10;
    copy_raw_bytes(word_address(game_checksum), 16384 + 64 * save_slot + 30, 2);
    disk_blocks_io(16384, 1, 23, false);
    if odd(game_won) then
    begin
      clear_text_window;
      write_wrapped_text('Congratulations, ');
      write_wrapped_text(data29.name255);
      write_wrapped_text('!  You completed the contract in just ');
      write_integer(data29.clock42.day, 3, false);
      write_wrapped_text(' days. ');
      write_wrapped_text('You now own the SunDog.');
      show_certificate(data29.name255, true);
      repeat
      until odd(poll_input(0) or poll_input(1))
    end
    else pop_text_window
  end
  else pop_text_window;
  reboot_with_caption('DUST')
end;
