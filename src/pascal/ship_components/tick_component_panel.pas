{ game_14 procedure9, $068C..$071D, attributes $072A.
  Retain all toggle/draw calls, the initial pending update before the descending
  scan, and parent slots5..8 used by nested10. }
procedure tick_component_panel(cursorx, cursory, heldcode: integer; active: boolean);
var
  savedy: integer;
  savedx: integer;
  index: integer;
  offset: integer;
(*$include src/pascal/ship_components/mark_damaged_component.pas*)
begin
  if active then swap_component_buffers;
  if data29.nibbles45[1] <= 2 then update_flight_state else advance_clock_and_conditions;
  if active then swap_component_buffers;
  if not odd(g14.inventory_mode) then
  begin
    offset := g14.group_byte_base + 25;
    index := data29.bytes[178 + offset];
    if index < 20 then
    begin
      if active then plot_item_icon(cursorx, cursory);
      data29.bytes[178 + offset] := 31;
      savedx := data29.words[14];
      savedy := data29.words[12];
      if not active then swap_component_buffers;
      set_glyph_mode(1);
      mark_damaged_component;
      index := 19;
      while index >= 0 do
      begin
        if data29.bytes[178 + (g14.group_byte_base + index)] > 127 then mark_damaged_component;
        index := index - 1
      end;
      if not active then swap_component_buffers;
      recompute_component_group(g14.selected_page);
      paint_component_status;
      if active then
      begin
        select_item_icon(heldcode);
        plot_item_icon(cursorx, cursory)
      end
    end
  end
end;
