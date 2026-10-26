{ game_16 procedure43, $1798..$1805, attributes $1810; nested in41.
  Capture the old item/origin before exchange, then reread target/count/mode
  for the transfer decision. Keep all drawing/buffer calls after it. }
procedure swap_dragged_item;
begin
  exchanged_code := held_code;
  source_item := target_item;
  store_inventory_code(exchanged_code, source_item, ord(from_trade_panel));
  replace_panel_item(held_code, target_item, held_code, draw_x, draw_y);
  if from_trade_panel or odd(g16.selling_mode) then
  begin
    if ((target_item <= data31.words[10]) and from_trade_panel) or
       ((target_item > data31.words[10]) and odd(g16.selling_mode)) then
    begin
      settle_item_trade;
      select_item_icon(held_code);
      set_glyph_mode(1)
    end;
    from_trade_panel := false
  end;
  select_drawing_buffer(0, false);
  show_trade_item(held_code, target_item);
  select_drawing_buffer(0, false)
end;
