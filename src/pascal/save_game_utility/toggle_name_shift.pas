{ utility_disk1:35 $139E..$13B4, attributes$13BE, nested in31.
  Complement the entire shift word and invert row2/key7's bounds. Consumers
  test its low bit; integer NOT avoids canonicalizing the stored word. }
procedure toggle_name_shift;
begin
  name_entry_state.uppercase_next := not name_entry_state.uppercase_next;
  apply_bounds(name_entry_state.keys[2, 7].bounds, 3)
end;
