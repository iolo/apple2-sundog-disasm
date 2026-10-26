{ game_12 procedure5, $0126..$0170, attributes $017A; nested in1.
  Preserve exact sensor caption, bounds reads and toggles surrounding call4. }
procedure setup_sensor_panel;
begin
  swap_tactical_buffers;
  set_text_window(105 + 28 + 10, data29.words[341] - 6,
              data29.words[340] + 5, data29.words[339] - 4);
  clear_text_window;
  write_wrapped_text('||||||Sensors\');
  set_text_window(data29.words[14] + 2, data29.words[13],
              data29.text_y - 4, data29.words[11]);
  paint_target_panel;
  swap_tactical_buffers
end;
