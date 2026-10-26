{ game_14 procedure3, $0012..$02A0, attributes $02AE.
  Value argument is slot1; locals2..7 retain original positions. The caption
  "Tactical Disply" is the original15-byte literal. No unselected titles or
  bounds are initialized. Arithmetic order retains signed word DIV. }
procedure setup_component_panel(mode: integer);
var
  second: integer;
  first: integer;
  index: integer;
  height: integer;
  x: integer;
  last: integer;
begin
  g14.inventory_mode := ord(mode <= 7);
  g14.cargo_mode := ord(mode = 7);
  if odd(g14.cargo_mode) then
  begin
    if data29.nibbles45[1] = 5 then
    begin
      first := panel_x;
      second := panel_y
    end
    else
    begin
      first := 21;
      second := 15
    end
  end;
  case mode of
    5: push_text_window(17, 13);
    6: push_text_window(17, 0);
    7: push_text_window(first, second);
    8,9,10: push_text_window(23, 7);
    11,12,13: push_text_window(23, 17)
  end;
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  case mode of
    5,6: setup_item_panel(3);
    7: setup_item_panel(5);
    8,9,10,11,12,13: setup_item_panel(2)
  end;
  if odd(g14.cargo_mode) then height := 44 else height := 12;
  assign_bounds(g14.caption_bounds, data31.words[12] + 39, data31.words[12] + 133,
            data31.words[11] + 2, data31.words[11] + height);
  if odd(g14.cargo_mode) then height := 47 else height := 15;
  if odd(g14.inventory_mode) then x := data31.words[12] + 40
  else x := data31.words[12] + 74;
  assign_bounds(g14.component_bounds, x, data31.words[12] + 133,
            data31.words[11] + height, data31.words[11] + 80);
  apply_bounds(g14.caption_bounds, 8);
  apply_bounds(g14.component_bounds, 8);
  if not odd(g14.inventory_mode) then
  begin
    set_clip_bounds(data31.words[12] + 40, data31.words[12] + 70,
              data31.words[11] + 14, data31.words[11] + 80);
    draw_clip_pattern(8);
    x := 7 * ((data31.words[12] + 40) div 7 + 1);
    assign_bounds(g14.status_meter, x, x + 6, data31.words[11] + 15, data31.words[11] + 80);
    x := x + 14;
    height := data31.words[11] + 19;
    index := 0;
    last := 3;
    while index <= last do
    begin
      assign_bounds(g14.row_lamps[index], x, x + 6, height, height + 7);
      height := height + 16;
      index := index + 1
    end
  end;
  if not odd(g14.inventory_mode) then
  begin
    g14.captions[0] := 'Warp Drives';
    g14.captions[1] := 'Sub-c Engines';
    g14.captions[2] := 'Ship''s Guns';
    g14.captions[3] := 'Tactical Disply';
    g14.captions[4] := 'Force Shields';
    g14.captions[5] := 'Pilotage'
  end
  else if not odd(g14.cargo_mode) then
  begin
    g14.captions[6] := 'Ship''s Locker';
    g14.captions[7] := 'Ship''s Stores'
  end;
  if odd(g14.inventory_mode) then g14.selected_page := 6 + (mode - 5)
  else g14.selected_page := (mode - 8) - 1;
  if odd(g14.cargo_mode) then g14.group_byte_base := 28 * (g14.selected_page - 1) + 20
  else g14.group_byte_base := 28 * g14.selected_page
end;
