{ utility_disk1:7 $18A0..$1951, attributes$1962. One Boolean parameter,
  one Boolean local. Check disk before prompting. Open a window only if this
  routine has not opened one and word20 is zero; close only that window. }
procedure require_utility_side(utility: boolean);
var opened: boolean;
begin
  opened := false;
  while not utility_disk_matches(utility) do
  begin
    if (not opened) and (data29.words[20] = 0) then
    begin
      opened := true;
      push_text_window(20, 12)
    end;
    clear_text_window;
    write_wrapped_text('Please flip to the \|\');
    if utility = true then write_wrapped_text('||||UTILITY')
    else write_wrapped_text('||||||PLAY');
    write_wrapped_text(' SIDE\|\of the disk and press either button\|\|');
    repeat until odd(poll_input(0) or poll_input(1))
  end;
  if opened then pop_text_window
end;
