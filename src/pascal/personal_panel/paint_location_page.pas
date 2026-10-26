{ game_8 procedure15, $0696..$07B7, attributes $07C2. }
procedure paint_location_page;
var
  saved_bounds: bounds4;
begin
  saved_bounds := data29.bounds11;
  set_text_window(stats_bounds.lower_first, stats_bounds.upper_first,
            stats_bounds.lower_second, stats_bounds.upper_second);
  clear_text_window;
  personal_state[15] := 0;
  write_wrapped_text('||LOCATION\');
  data29.text_y := data29.text_y + 4;
  write_wrapped_text('City:\|');
  if data29.loc37.mid5 = 0 then write_wrapped_text('deep space')
  else if data29.bits37.mid6 = 0 then begin
    if (data29.bits38.low6 = 0) and (data29.bits39.low5 = 0) then
      write_wrapped_text('orbit')
    else write_wrapped_text('surface')
  end else write_wrapped_text(data29.names25.cities^[data29.bits37.mid6]);
  text_newline;
  data29.text_y := data29.text_y + 4;
  write_wrapped_text('Planet:\|');
  if data29.loc37.mid5 = 0 then write_wrapped_text('space')
  else write_wrapped_text(data29.names24.planets^[data29.loc37.mid5]);
  text_newline;
  data29.text_y := data29.text_y + 4;
  write_wrapped_text('System:\|');
  write_wrapped_text(data29.names23.systems^[data29.loc37.low4].caption);
  text_newline;
  wait_personal_input;
  paint_condition_panel;
  set_text_window(saved_bounds.lower_first, saved_bounds.upper_first,
            saved_bounds.lower_second, saved_bounds.upper_second)
end;
