{ game_8 procedure14, $05CC..$0687, attributes $0694. }
procedure show_player_attributes;
var
  saved_bounds: bounds4;
  attr_index: integer;
  attr_labels: text15;
  last_attribute: integer;
begin
  saved_bounds := data29.bounds11;
  set_text_window(stats_bounds.lower_first, stats_bounds.upper_first,
            stats_bounds.lower_second, stats_bounds.upper_second);
  clear_text_window;
  personal_state[15] := 0;
  attr_labels := 'STIQDXCHLK';
  write_wrapped_text('|Attributes\');
  data29.text_y := data29.text_y + 4;
  attr_index := 0;
  last_attribute := 4;
  while attr_index <= last_attribute do begin
    write_wrapped_text(copy(attr_labels, 1 + attr_index * 2, 2));
    write_wrapped_text(':');
    if attr_index < 4 then begin
      write_integer(data29.bytes[94 + attr_index], 3, false);
      write_wrapped_text(' /')
    end else write_wrapped_text('|?? /');
    write_integer(data29.bytes[94 + attr_index + 5], 3, false);
    if attr_index < 4 then begin
      text_newline;
      data29.text_y := data29.text_y + 4
    end;
    attr_index := attr_index + 1
  end;
  wait_personal_input;
  paint_condition_panel;
  set_text_window(saved_bounds.lower_first, saved_bounds.upper_first,
            saved_bounds.lower_second, saved_bounds.upper_second)
end;
