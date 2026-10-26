{ game_16 procedure41, $1812..$19B2, attributes $19C6.
  Retain24 local bytes and slots consumed by42/43. The unused argument1 and
  locals3/4 hold captured predicates/masks so all original effectful calls run.
  work4 retains the original discarded pre-use item store as well. }
procedure drag_dialog_item(start_item, scratch_flag: integer);
var
  saved_predicate: integer;   {3}
  scratch_word: integer;
  held_code: integer;        {5}
  source_item: integer;
  exchanged_code: integer;
  target_item: integer;
  target_code: integer;
  pointer_y: integer;        {10}
  pointer_x: integer;
  draw_y: integer;
  draw_x: integer;
  from_trade_panel: boolean;    {14}
(*$include src/pascal/dialogue/settle_item_trade.pas*)
(*$include src/pascal/dialogue/swap_dragged_item.pas*)
begin
  toggle_pointer_glyph(g16.cursor_x, g16.cursor_y);
  from_trade_panel := start_item > data31.words[10];
  draw_empty_item_marker(start_item);
  select_drawing_buffer(0, false);
  exchanged_code := 0;
  source_item := start_item;
  store_inventory_code(exchanged_code, source_item, 0);
  replace_panel_item(exchanged_code, start_item, held_code, draw_x, draw_y);
  repeat
    read_item_panel_position(pointer_x, pointer_y);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      select_drawing_buffer(0, false);
      tick_dialog_clock;
      select_drawing_buffer(0, false)
    end;
    if (pointer_x <> draw_x) or (pointer_y <> draw_y) then
    begin
      plot_item_icon(draw_x, draw_y);
      plot_item_icon(pointer_x, pointer_y);
      draw_x := pointer_x;
      draw_y := pointer_y
    end;
    if odd(poll_input(0)) then
    begin
      find_panel_item(pointer_x, pointer_y, target_code, target_item);
      if target_item > 0 then
      begin
        saved_predicate := ord(target_item = data31.words[14]);
        scratch_word := ord(from_trade_panel);
        scratch_flag := ord(amount_greater(g16.item_price, g16.cash_amount));
        if odd(saved_predicate) and not (odd(scratch_word) and odd(scratch_flag)) then
        begin
          scratch_word := held_code;
          apply_item_action(1, held_code, draw_x, draw_y);
          if from_trade_panel and (held_code = 0) then settle_item_trade
        end
        else if (target_code = 2) and not from_trade_panel then
          apply_item_action(0, held_code, draw_x, draw_y)
        else if target_item >= data31.words[14] then
        begin
          if from_trade_panel then
          begin
            if target_item <= data31.words[10] then
            begin
              if amount_greater(g16.item_price, g16.cash_amount) then
              begin
                select_drawing_buffer(0, false);
                write_item_caption('Not enough');
                draw_text(' money');
                select_drawing_buffer(0, false)
              end
              else swap_dragged_item
            end
            else if target_code = 0 then swap_dragged_item
          end
          else if target_item <= data31.words[10] then swap_dragged_item
          else
          begin
            saved_predicate := g16.selling_mode;
            scratch_flag := word_and(held_code, 31);
            scratch_word := word_and(g16.trade_item_code, 31);
            if (odd(saved_predicate) and (scratch_flag = scratch_word)) or
               (not odd(g16.selling_mode) and (target_code = 0)) then swap_dragged_item
          end
        end
      end
    end;
    scratch_flag := poll_input(1)
  until (odd(scratch_flag) and (exchanged_code = 0)) or (held_code = 0) or odd(data29.words[347]);
  if held_code <> 0 then
  begin
    exchanged_code := held_code;
    replace_panel_item(held_code, source_item, held_code, draw_x, draw_y);
    store_inventory_code(exchanged_code, source_item, 0);
    select_drawing_buffer(0, false);
    draw_empty_item_marker(source_item);
    write_item_caption('')
  end
  else
  begin
    select_drawing_buffer(0, false);
    draw_empty_item_marker(target_item)
  end;
  select_item_icon(0);
  g16.cursor_x := draw_x;
  g16.cursor_y := draw_y;
  toggle_pointer_glyph(draw_x, draw_y)
end;
