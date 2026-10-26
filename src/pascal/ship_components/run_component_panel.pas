{ game_14 procedure1, $08DA..$09C5, attributes $09D4.
  VAR action is slot3; two value words are slots2/1. Retain204 local bytes.
  The outer loop changes the selected page; the inner loop polls input and
  updates the clock. No segment-load or release epilogue occurs here. }
procedure run_component_panel(var panel_action: integer; panel_x, panel_y: integer);
var
  g14: g14frame;
(*$include src/pascal/ship_components/swap_component_buffers.pas*)
(*$include src/pascal/ship_components/setup_component_panel.pas*)
(*$include src/pascal/ship_components/draw_component_grid.pas*)
(*$include src/pascal/ship_components/paint_component_status.pas*)
(*$include src/pascal/ship_components/draw_cargo_origin_list.pas*)
(*$include src/pascal/ship_components/next_component_page.pas*)
(*$include src/pascal/ship_components/write_component_item.pas*)
(*$include src/pascal/ship_components/tick_component_panel.pas*)
(*$include src/pascal/ship_components/item_fits_component.pas*)
(*$include src/pascal/ship_components/drag_component_item.pas*)
begin
  setup_component_panel(panel_action);
  draw_panel_items_after(0);
  repeat
    next_component_page;
    g14.page_changed := 0;
    initialize_pointer(g14.cursor_x, g14.cursor_y, 2, data31.bounds2);
    repeat
      data29.words[354] := data29.words[354] + 1;
      if data29.words[354] >= data29.words[353] then
      begin
        toggle_pointer_glyph(g14.cursor_x, g14.cursor_y);
        tick_component_panel(0, 0, 0, false);
        initialize_pointer(g14.cursor_x, g14.cursor_y, 2, data31.bounds2)
      end;
      update_pointer(g14.cursor_x, g14.cursor_y);
      if odd(poll_input(0)) then
      begin
        toggle_pointer_glyph(g14.cursor_x, g14.cursor_y);
        find_panel_item(g14.cursor_x, g14.cursor_y, g14.hit_code, g14.hit_item);
        if g14.hit_code = 3 then g14.page_changed := 1
        else if g14.hit_code > 6 then
        begin
          show_item_description(g14.hit_code);
          drag_component_item(g14.hit_item, 0)
        end;
        initialize_pointer(g14.cursor_x, g14.cursor_y, 2, data31.bounds2)
      end;
      g14.cancel_poll := poll_input(1)
    until odd(g14.cancel_poll) or odd(g14.page_changed) or odd(data29.words[347]);
    toggle_pointer_glyph(g14.cursor_x, g14.cursor_y)
  until odd(g14.cancel_poll) or odd(data29.words[347]);
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    if data29.nibbles45[2] = 5 then data29.nibbles45[1] := data29.nibbles45[0]
    else data29.nibbles45[1] := 8;
    data29.nibbles45[0] := 11
  end;
  pop_text_window;
  if panel_action >= 8 then panel_action := 8 + g14.selected_page
end;
