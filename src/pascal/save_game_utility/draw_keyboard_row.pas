{ utility_disk1:32 $11D6..$124A, attributes$1256, nested in31.
  Slots1 caption address,2 y,3 x,4 row; value caption copy5..12.
  Locals13 xpos,14 unused,15 index,16 limit,17 key pointer. Read all ten
  caption bytes without checking length, and write only the low code byte. }
procedure draw_keyboard_row(key_row, x, y: integer; caption: text15);
var
  key_x: integer;
  unused: integer;
  key_index: integer;
  limit: integer;
  key: utilkptr;
begin
  key_x := x;
  key_index := 0;
  limit := 9;
  while key_index <= limit do
  begin
    key := @name_entry_state.keys[key_row, key_index];
    assign_bounds(key^.bounds, key_x, key_x + 13, y - 12, y);
    key^.code.low := ord(caption[key_index + 1]);
    apply_bounds(key^.bounds, 11);
    assign_bounds(key^.bounds, key_x + 1, key_x + 12, y - 11, y - 1);
    apply_bounds(key^.bounds, 8);
    move_pen(key_x + 3, y - 2);
    draw_glyph(key^.code.low);
    key_x := key_x + 13;
    key_index := key_index + 1
  end
end;
