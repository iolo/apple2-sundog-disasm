{ game_8 procedure 7, $017E..$0249, attributes $0258.
  Saves/restores only the four bounds words; other drawing state is retained. }
procedure paint_condition_panel;
var
  saved_bounds: bounds4;
  bar_index, bar_x: integer;
  bar_label: string[6];
begin
  saved_bounds := data29.bounds11;
  set_text_window(stats_bounds.lower_first, stats_bounds.upper_first,
            stats_bounds.lower_second, stats_bounds.upper_second);
  clear_text_window;
  write_wrapped_text('|Condition');
  text_newline;
  text_newline;
  bar_index := 0;
  while bar_index <= 3 do
  begin
    bar_label := copy('Vigor Rest  HealthNoursh', bar_index * 6 + 1, 6);
    write_wrapped_text(bar_label);
    bar_x := 7 * ((data29.text_x + 6) div 7);
    assign_bounds(condition_bars[bar_index], bar_x, bar_x + 32,
              data29.text_y - 6, data29.text_y - 1);
    text_newline;
    if bar_index = 0 then data29.text_y := data29.text_y + 4;
    bar_index := bar_index + 1
  end;
  bar_index := 0;
  while bar_index <= 3 do
  begin
    draw_condition_bar(bar_index);
    bar_index := bar_index + 1
  end;
  draw_personal_button(sleep_button_bounds, 'Sleep');
  data29.bounds11 := saved_bounds;
  personal_state[15] := 1
end;
