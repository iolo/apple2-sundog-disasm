{ game_20 procedure15, $0856..$08BE, attributes $08CA; nested in13.
  Both scalar arguments are unused. Keep the captured row through text calls
  and reread its kind/category after displaying its name. }
procedure list_warehouse_stock(ignoredfirst, ignoredsecond: integer);
var
  index: integer;
begin
  clear_warehouse_text;
  write_wrapped_text('Contents:\|\');
  index := 1;
  while index <= 4 do
  begin
    with g20.warehouse_items[index] do
    begin
      write_wrapped_text('|||');
      write_wrapped_text(g20.cargo_names.names^[kind]);
      if kind > 0 then
      begin
        write_wrapped_text(' / ');
        write_text_glyph(72 - category)
      end;
      if index < 4 then text_newline;
      index := index + 1
    end
  end
end;
