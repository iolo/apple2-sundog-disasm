{ game_12 procedure15, $0CE6..$0F3B, attributes $0F50; nested in1.
  Child16 shares slots3/4/5. WITH captures cargo in compiler slot19.
  Retain conditionally uninitialized shield/code slots and aliased outputs.
  After menu construction, dead private slots1/2 save BOTH poll polls. }
procedure build_tactical_menu;
var
  index: integer; {1}
  count: integer; {2}
  right: integer; {3}
  left: integer; {4}
  top: integer; {5}
  shield: integer; {6}
  code: integer; {7}
  item: integer; {8}
  poll: integer; {9}
  caption: text15; {10..17}
  limit: integer; {18}
(*$include src/pascal/tactical_console/append_tactical_button.pas*)
begin
  swap_tactical_buffers;
  reset_menu;
  top := 5;
  left := 4;
  right := 62;
  if g12.menu_mode = 0 then
  begin
    item := 1;
    poll := 0;
    if (g12.display_level > 0) and data29.flags82[7] then
    begin
      append_tactical_button(4, 'JETTISON');
      item := item + 1
    end;
    if g12.display_level > 1 then
    begin
      append_tactical_button(3, 'GUNS');
      item := item + 1
    end;
    if g12.display_level > 2 then
    begin
      shield := item;
      append_tactical_button(2, 'SHIELDS');
      item := item + 1;
      if data29.flags82[20] then
        if data29.flags82[12] then
        begin
          append_tactical_button(6, 'CLOAK');
          poll := 1
        end
        else append_tactical_button(5, 'CLOAK')
    end;
    append_tactical_button(7, 'COMM')
  end
  else if g12.menu_mode = 1 then
  begin
    if data29.shield_setting < 255 then
    begin
      append_tactical_button(17, 'FULL SHLDS');
      append_tactical_button(8, 'SHIELDS `')
    end;
    if data29.shield_setting > 0 then append_tactical_button(9, 'SHIELDS &');
    if data29.flags82[4] then append_tactical_button(10, 'SHLDS OFF')
  end
  else if g12.menu_mode = 2 then
  begin
    count := 0;
    caption := 'DUMP  ';
    index := 1;
    limit := 2;
    while index <= limit do
    begin
      with data29.stock234[index] do
        if (kind > 0) and (kind < 31) then
        begin
          caption[6] := chr(48 + index);
          append_tactical_button(10 + index, caption);
          count := count + 1
        end;
      index := index + 1
    end;
    if count = 2 then append_tactical_button(13, 'DUMP BOTH')
  end
  else if g12.menu_mode = 3 then
  begin
    append_tactical_button(14, 'LASER');
    append_tactical_button(15, 'CANNON');
    if odd(g12.wreck_cargo_present) then append_tactical_button(16, 'TRACTOR');
    if (g12.display_level > 2) and (data29.fuel_amount > 0) then
    begin
      if data29.flags82[4] then append_tactical_button(10, 'SHLDS OFF');
      if (data29.shield_setting < 255) and not odd(g12.wreck_cargo_present) then
        append_tactical_button(17, 'FULL SHLDS')
    end
  end;
  apply_bounds(data29.bnd335, 8);
  draw_menu(data29.bnd335);
  if g12.menu_mode = 0 then
  begin
    if odd(poll) then activate_menu_item(item, code, data29.bnd335, poll, poll);
    if data29.flags82[4] then activate_menu_item(shield, code, data29.bnd335, poll, poll)
  end;
  swap_tactical_buffers;
  repeat
    tick_tactical_controls;
    index := poll_input(0);
    count := poll_input(1)
  until not (odd(index) or odd(count));
  initialize_pointer(g12.cursor_x, g12.cursor_y, g12.pointer_glyph, data29.bnd335)
end;
