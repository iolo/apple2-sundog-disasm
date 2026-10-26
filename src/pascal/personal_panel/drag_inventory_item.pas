{ game_8 procedure10, $03AA..$04C1, attributes $04CE.
  Original local2 is unused. Keep hit uninitialized until proc27_8 writes it:
  the original exit path also reads that slot if the parent item is zero. }
procedure drag_inventory_item(start_item: integer);
var
  unused2: integer;
  item_action: integer;
  target_index: integer;
  target_code: integer;
  pointer_y: integer;
  pointer_x: integer;
  cancel_poll: integer;
begin
  lift_inventory_item(start_item);
  select_drawing_buffer(0, false);
  repeat
    read_item_panel_position(pointer_x, pointer_y);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then tick_personal_panel(true, false);
    if (pointer_x <> personal_state[7]) or (pointer_y <> personal_state[6]) then begin
      plot_item_icon(personal_state[7], personal_state[6]);
      plot_item_icon(pointer_x, pointer_y);
      personal_state[7] := pointer_x;
      personal_state[6] := pointer_y
    end;
    if odd(poll_input(0)) then begin
      find_panel_item(pointer_x, pointer_y, target_code, target_index);
      if target_index > 0 then begin
        if target_index <= data31.words[14] then begin
          item_action := 1;
          if target_code = 2 then item_action := 0
          else if target_index = data31.words[13] then item_action := 2;
          apply_item_action(item_action, personal_state[3], personal_state[7], personal_state[6])
        end else if target_index > data31.words[14] then begin
          personal_state[5] := personal_state[3];
          personal_state[4] := target_index;
          replace_panel_item(personal_state[3], target_index, personal_state[3], personal_state[7], personal_state[6]);
          select_drawing_buffer(0, false);
          show_item_description(personal_state[3]);
          select_drawing_buffer(0, false)
        end
      end
    end;
    { $0469: input selector1 is always called before all exit predicates. }
    cancel_poll := poll_input(1)
  until (odd(cancel_poll) and (personal_state[5] = 0)) or (personal_state[3] = 0) or
        odd(data29.words[347]);
  if personal_state[3] <> 0 then begin
    personal_state[5] := personal_state[3];
    replace_panel_item(personal_state[3], personal_state[4], personal_state[3], personal_state[7], personal_state[6]);
    select_drawing_buffer(0, false);
    draw_empty_item_marker(personal_state[4]);
    write_item_caption('')
  end else begin
    select_drawing_buffer(0, false);
    draw_empty_item_marker(target_index)
  end;
  select_item_icon(0)
end;
