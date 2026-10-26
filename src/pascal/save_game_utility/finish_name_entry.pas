{ utility_disk1:39 $16F6..$170C, attributes$1716, nested in31.
  Copy15-character value, restore all four saved display words, then clear. }
procedure finish_name_entry;
begin
  data29.name255 := name_entry_state.entered_name;
  data29.bounds11 := name_entry_state.previous_text_bounds;
  clear_text_window
end;
