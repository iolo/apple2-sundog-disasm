{ game_16 procedure23, $0D62..$0E3C, attributes $0E4C.
  Retain its20-byte frame, including work10 shared with28. Header flag tests
  use low bits after division. Save the byte cursor around dialogue17, and
  retain the early self EXIT before any option processing. }
procedure execute_dialog_record(var value: integer);
var
  command_index: integer;
  record_flags: integer;
  line_record: integer;
  unused5: integer;
  unused6: integer;
  option_action: integer;
  caption_id: integer;
  option_count: integer;
  scratch_word: integer;
  last_command: integer;
(*$include src/pascal/dialogue/select_dialog_alternative.pas*)
(*$include src/pascal/dialogue/apply_dialog_flags.pas*)
(*$include src/pascal/dialogue/label_dialog_button.pas*)
(*$include src/pascal/dialogue/handle_dialog_display.pas*)
(*$include src/pascal/dialogue/resolve_dialog_fallback.pas*)
begin
  data31.words[16] := data31.words[10];
  g16.trade_active := 0;
  g16.stream_cursor := g16.script_bytes.bytes^[value mod 16];
  read_dialog_byte(scratch_word);
  record_flags := scratch_word div 16;
  option_count := scratch_word div 4 mod 4;
  g16.dialog_timeout := 2 * (scratch_word mod 4);
  apply_dialog_flags;
  if odd(record_flags div 2) and (option_count = 0) then
  begin
    read_dialog_byte(value);
    select_dialog_alternative(value);
    g16.redirect_requested := 1;
    if record_flags >= 8 then handle_dialog_display;
    exit(execute_dialog_record)
  end;
  read_dialog_byte(line_record);
  if line_record < 30 then select_dialog_alternative(line_record);
  scratch_word := g16.stream_cursor;
  render_dialog_line(line_record);
  g16.stream_cursor := scratch_word;
  command_index := 3;
  last_command := 4;
  while command_index <= last_command do
  begin
    read_dialog_byte(g16.words[95 + command_index]);
    if odd(record_flags) then resolve_dialog_fallback(g16.words[95 + command_index]);
    command_index := command_index + 1
  end;
  scratch_word := 0;
  while scratch_word < 3 - option_count do
  begin
    label_dialog_button(scratch_word, -1, -1);
    scratch_word := scratch_word + 1
  end;
  g16.buttons_enabled := 0;
  while option_count > 0 do
  begin
    g16.buttons_enabled := 1;
    read_dialog_byte(caption_id);
    read_dialog_byte(option_action);
    if odd(record_flags div 2) then resolve_dialog_fallback(option_action);
    label_dialog_button(scratch_word, option_action, caption_id);
    option_count := option_count - 1;
    scratch_word := scratch_word + 1
  end;
  if record_flags >= 8 then handle_dialog_display
end;
