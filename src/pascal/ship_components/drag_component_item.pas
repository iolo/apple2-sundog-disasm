{ game_14 procedure12, $0796..$08C8, attributes $08D8.
  Slot2=start index; unused value parameter1 holds the fit result. Unused local3
  captures eligibility before the UNCONDITIONAL11 call. This retains20 local
  bytes and the original call order. Input1 is polled on every loop path. }
procedure drag_component_item(start, unused: integer);
var
  reject: boolean;
  held: integer;
  lastitem: integer;
  lastcode: integer;
  target: integer;
  selected: integer;
  mousey: integer;
  mousex: integer;
  drawy: integer;
  drawx: integer;
begin
  draw_empty_item_marker(start);
  swap_component_buffers;
  lastcode := 0;
  lastitem := start;
  write_component_item(lastcode, lastitem);
  replace_panel_item(lastcode, start, held, drawx, drawy);
  repeat
    read_item_panel_position(mousex, mousey);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then tick_component_panel(drawx, drawy, held, true);
    if (mousex <> drawx) or (mousey <> drawy) then
    begin
      plot_item_icon(drawx, drawy);
      plot_item_icon(mousex, mousey);
      drawx := mousex;
      drawy := mousey
    end;
    if odd(poll_input(0)) then
    begin
      find_panel_item(mousex, mousey, selected, target);
      if target > 0 then
      begin
        if target = data31.words[14] then apply_item_action(1, held, drawx, drawy)
        else if selected = 2 then apply_item_action(0, held, drawx, drawy)
        else if selected = 3 then
        begin
          swap_component_buffers;
          next_component_page;
          swap_component_buffers;
          select_item_icon(held)
        end
        else
        begin
          reject := not odd(g14.inventory_mode) and (target > data31.words[15]);
          unused := ord(item_fits_component(held, target));
          if reject and not odd(unused) then
          begin
            swap_component_buffers;
            write_item_caption('Doesn''t fit');
            swap_component_buffers
          end
          else if selected <> 3 then
          begin
            lastcode := held;
            lastitem := target;
            write_component_item(lastcode, lastitem);
            replace_panel_item(held, target, held, drawx, drawy);
            swap_component_buffers;
            show_item_description(held);
            swap_component_buffers
          end
        end
      end
    end
  until (odd(poll_input(1)) and (lastcode = 0)) or (held = 0) or odd(data29.words[347]);
  if held <> 0 then
  begin
    lastcode := held;
    replace_panel_item(held, lastitem, held, drawx, drawy);
    write_component_item(lastcode, lastitem);
    swap_component_buffers;
    draw_empty_item_marker(lastitem);
    write_item_caption('')
  end
  else
  begin
    swap_component_buffers;
    draw_empty_item_marker(target)
  end;
  select_item_icon(0)
end;
