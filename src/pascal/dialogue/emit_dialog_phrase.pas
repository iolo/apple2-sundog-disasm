{ game_16 procedure21, $07EC..$0835, attributes $0842.
  Copy the value string with SAS31 before reading its length. Expansion walks
  that copy with a saved limit. Literal mode processes the first byte even for
  an empty string, then performs the original MOVELEFT(length-1). }
procedure emit_dialog_phrase(caption: g16str; expand: boolean);
var
  char_index: integer;
  char_count: integer;
begin
  char_count := length(caption);
  if expand then
  begin
    char_index := 1;
    while char_index <= char_count do
    begin
      expand_dialog_token(ord(caption[char_index]));
      char_index := char_index + 1
    end
  end
  else
  begin
    append_dialog_char(ord(caption[1]));
    moveleft(caption[2], text_buffer.bytes[buffer_index], char_count - 1);
    buffer_index := buffer_index + char_count - 1
  end
end;
