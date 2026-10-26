{ game_16 procedure19, $077A..$079B, attributes $07A6.
  Initialize the display on the first flush, then write the raw length byte.
  The final flush happens even for an empty buffer. }
procedure flush_dialog_text;
begin
  if not odd(text_started) then clear_text_window;
  text_started := 1;
  text_buffer.bytes[0] := buffer_index - 1;
  write_wrapped_text(text_buffer.text);
  buffer_index := 1
end;
