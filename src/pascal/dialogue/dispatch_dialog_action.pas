{ game_16 procedure34, $111A..$117B, attributes $1188.
  Only the redirect flag21 resets on each dispatch. Bank changes store39 before
  I/O and table repair; return records the possibly rewritten action at44. }
procedure dispatch_dialog_action(action_code, redraw_cursor: integer);
var
  bank_index: integer;
begin
  if odd(redraw_cursor) then toggle_pointer_glyph(g16.cursor_x, g16.cursor_y);
  data29.words[354] := 0;
  g16.buttons_enabled := 1;
  repeat
    g16.redirect_requested := 0;
    if action_code < 16 then act_dialog_command(action_code)
    else
    begin
      bank_index := action_code div 16 - 1;
      if g16.script_bank <> bank_index then
      begin
        g16.script_bank := bank_index;
        disk_blocks_io(18432, 1, g16.script_disk_base + g16.script_bank, true);
        merge_dialog_phrases
      end;
      execute_dialog_record(action_code)
    end
  until not odd(g16.redirect_requested);
  g16.last_action := action_code;
  if odd(redraw_cursor) then toggle_pointer_glyph(g16.cursor_x, g16.cursor_y)
end;
