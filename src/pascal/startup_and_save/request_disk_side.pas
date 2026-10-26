{ startup_7 procedure3, $003E..$00D1, attributes $00E0; nested in1.
  Integer OR forces both input calls with no extra local slots. Original
  EQU6 against true tests only bit0 of utility. Retry the whole prompt when
  the disk check fails, and just the poll pair while neither button is down. }
procedure request_disk_side(utility: boolean);
begin
  repeat
    clear_text_window;
    write_wrapped_text('Please flip to the \|\');
    if utility = true then write_wrapped_text('||||UTILITY')
    else write_wrapped_text('||||||PLAY');
    write_wrapped_text(' SIDE\|\of the disk and press either button\|\|');
    repeat
    until odd(poll_input(0) or poll_input(1))
  until check_disk_side(utility)
end;
