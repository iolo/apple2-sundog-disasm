{ utility_disk1:34 $1352..$1391, attributes$139C, nested in31.
  One VAR Boolean, no locals. Cancel only if already empty; otherwise blank
  the last byte, reduce count/length byte, and erase one displayed character. }
procedure backspace_name(var entry_active: boolean);
begin
  if name_entry_state.typed_length > 0 then
  begin
    name_entry_state.namebytes[name_entry_state.typed_length] := 32;
    name_entry_state.typed_length := name_entry_state.typed_length - 1;
    name_entry_state.namebytes[0] := name_entry_state.typed_length;
    data29.text_x := data29.text_x - 6;
    write_text_glyph(32);
    data29.text_x := data29.text_x - 6
  end
  else entry_active := false
end;
