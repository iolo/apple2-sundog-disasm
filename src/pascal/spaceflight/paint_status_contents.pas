{ game_13 procedure9, $0264..$04C9, attributes $04D6; nested in3.
  Retain original text, spaces, bounds, and state values0/1/2. No name-table
  selector guards or string-length limits absent from the listing are added. }
procedure paint_status_contents;
var
  component_labels: string[9];
  label_index: integer;
  last_label: integer;
begin
  push_text_window(data29.words[346] div 7 + 10, right_shift_word(data29.words[344], 3) + 6);
  set_text_grid_position(2, 1);
  write_wrapped_text('SYSTEMS  ');
  g13s.bars_x := 7 * ((data29.text_x + 6) div 7);
  g13s.bars_y := data29.text_y;
  draw_system_bars;
  set_text_grid_position(3, 3);
  component_labels := 'WEG TSP H';
  label_index := 0;
  last_label := 8;
  while label_index <= last_label do
  begin
    move_pen(g13s.bars_x + label_index * 7, data29.text_y + 2);
    draw_glyph(ord(component_labels[label_index + 1]));
    label_index := label_index + 1
  end;
  set_text_grid_position(0, 6);
  write_wrapped_text('WARP DRIVES: ');
  assign_bounds(g13s.warp_button_bounds, data29.text_x - 2, data29.text_x + 42,
            data29.text_y - 7, data29.text_y);
  if not data29.flags82[0] then
  begin
    write_wrapped_text('no charge');
    g13s.warp_state := 0
  end
  else
  begin
    write_wrapped_text('charg');
    if data29.warp_charge >= data29.warp_setting then
    begin
      write_wrapped_text('ed');
      g13s.warp_state := 2
    end
    else
    begin
      write_wrapped_text('ing');
      g13s.warp_state := 1;
      g13s.words[16] := g13s.words[16] + 6
    end;
    apply_bounds(g13s.warp_button_bounds, 3);
    apply_bounds(data29.bounds11, 0)
  end;
  set_text_grid_position(0, 8);
  write_wrapped_text('SUB-C ENGNS: ');
  assign_bounds(g13s.engine_button_bounds, data29.text_x - 2, data29.text_x + 48,
            data29.text_y - 7, data29.text_y);
  if not data29.flags82[1] then
  begin
    write_wrapped_text('power off');
    g13s.sublight_active := 0
  end
  else
  begin
    write_wrapped_text('power on');
    g13s.sublight_active := 1;
    apply_bounds(g13s.engine_button_bounds, 3);
    apply_bounds(data29.bounds11, 0)
  end;
  set_text_grid_position(0, 11);
  write_wrapped_text('SYSTEM:   ');
  write_wrapped_text(data29.names23.systems^[data29.loc73.low4].caption);
  set_text_grid_position(0, 13);
  write_wrapped_text('LOCATION: ');
  write_location_label(10, 13, data29.pos72);
  set_text_grid_position(0, 15);
  write_wrapped_text('WARP TO:  ');
  if data29.warp_destination_system = 0 then write_wrapped_text('(none)')
  else write_wrapped_text(data29.names23.systems^[data29.warp_destination_system].caption);
  set_text_grid_position(0, 17);
  write_wrapped_text('SYS DEST: ');
  if not data29.flags82[1] then write_wrapped_text('(none)')
  else write_location_label(10, 17, data29.pos66);
  if data29.flags82[25] then
  begin
    set_text_grid_position(0, 20);
    write_wrapped_text('RESCUE ETA: ');
    draw_clock(data29.clock78);
    g13s.rescue_visible := 1
  end
  else g13s.rescue_visible := 0
end;
