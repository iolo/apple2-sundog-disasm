{ utility_disk1:36 $13C0..$1421, attributes$142C, nested in31.
  One value word, no locals. Space toggles shift only in unshifted mode;
  shifted nonspace subtracts32. At capacity only sound runs. }
procedure append_name_character(code: integer);
begin
  if name_entry_state.typed_length < 15 then
  begin
    name_entry_state.typed_length := name_entry_state.typed_length + 1;
    name_entry_state.namebytes[0] := name_entry_state.typed_length;
    if odd(name_entry_state.uppercase_next) then
    begin
      if code <> 32 then code := code - 32;
      name_entry_state.uppercase_next := 0;
      apply_bounds(name_entry_state.keys[2, 7].bounds, 3)
    end
    else if code = 32 then toggle_name_shift;
    name_entry_state.namebytes[name_entry_state.typed_length] := code;
    write_text_glyph(code)
  end
  else play_sound(20, 100, 10, 0, 0, 0, 0)
end;
