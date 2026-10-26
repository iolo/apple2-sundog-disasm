{ game_16 procedure20, $07A8..$07E0, attributes $07EA.
  Flush only at a space past position60. Capitalization subtracts32 from any
  code>=97, without an invented upper bound; stores remain unchecked bytes. }
procedure append_dialog_char(char_code: integer);
begin
  if (char_code = 32) and (buffer_index > 60) then flush_dialog_text;
  if odd(capitalize_next) and (char_code >= 97) then char_code := char_code - 32;
  if (char_code >= 65) or (char_code = 44) then capitalize_next := 0;
  text_buffer.bytes[buffer_index] := char_code;
  buffer_index := buffer_index + 1
end;
