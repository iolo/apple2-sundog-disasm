{ library_27 procedure13, $044E..$0614, attributes $0622.
  Mode is an integer: the first branch uses its low bit; later tests use full
  equality with0/1/2. Keep the apparently redundant position calls. }
procedure setup_item_panel(mode: integer);
var
  secondpos: integer;
  firstpos: integer;
  offset: integer;
  lastcol: integer;
  column: integer;
  row: integer;
  fillmode: integer;
begin
  if odd(mode) then fillmode := 9 else fillmode := 10;
  if mode = 0 then offset := 53 else offset := 37;
  set_glyph_mode(1);
  row := 0;
  while row <= 3 do
  begin
    secondpos := (data31.words[11] + 8 * row) + 26;
    if row < 2 then lastcol := 1 else lastcol := 2;
    column := 0;
    while column <= lastcol do
    begin
      firstpos := (data31.words[12] + 7 * column) + 2;
      move_pen(firstpos, secondpos);
      draw_glyph((27 + column) + 32 * row);
      column := column + 1
    end;
    row := row + 1
  end;
  move_pen(data31.words[12] + offset, data31.words[11]);
  set_line_mode(11);
  move_pen(data31.words[12] + offset, data31.words[11] + 83);
  move_pen(data31.words[12], data31.words[11] + 83);
  move_pen(data31.words[12] + 138, data31.words[11] + 83);
  set_line_mode(0);
  assign_bounds(data31.bounds6, data31.words[12] + 3, data31.words[12] + 137,
              data31.words[11] + 84, data31.words[11] + 93);
  assign_bounds(data31.bounds2, data31.words[12] + 4, data31.words[12] + 135,
              data31.words[11] + 2, data31.words[11] + 80);
  store_word(5632, data31.words[1]);
  data31.words[16] := 0;
  append_panel_item(2, 9, 7);
  if mode = 0 then
  begin
    append_panel_item(6, 41, 51);
    append_panel_item(4, 41, 71);
    append_panel_item(1, 41, 7);
    append_panel_item(5, 41, 31);
    append_panel_item(0, 4, 34);
    data31.words[13] := data31.words[16];
    with data31.items[data31.words[13]] do
    begin
      move_pen(data31.words[12] + firstoff,
                  (data31.words[11] + secondoff) + 7);
      draw_glyph(43)
    end
  end
  else if mode = 1 then append_panel_item(5, 25, 7)
  else if mode = 2 then append_panel_item(3, 25, 7);
  append_panel_item(0, 19, 27);
  data31.words[14] := data31.words[16];
  with data31.items[data31.words[14]] do
  begin
    move_pen(data31.words[12] + firstoff,
                (data31.words[11] + secondoff) + 7);
    draw_glyph(43)
  end;
  data31.words[15] := data31.words[14] + 4;
  append_inventory_item(19, 45, 0);
  append_inventory_item(3, 48, 1);
  append_inventory_item(3, 64, 2);
  append_inventory_item(19, 64, 3);
  data31.words[10] := data31.words[16];
  set_clip_bounds(data31.words[12] + offset, data31.words[12] + 137,
              data31.words[11] + 1, data31.words[11] + 82);
  draw_clip_pattern(fillmode)
end;
