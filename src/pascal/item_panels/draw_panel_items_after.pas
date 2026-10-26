{ library_27 procedure 6, $00FE..$0148, attributes $0154. }
procedure draw_panel_items_after(after: integer);
var
  secondpos: integer;
  firstpos: integer;
  index: integer;
  last: integer;
begin
  select_drawing_buffer(0, false);
  firstpos := data29.words[14];
  secondpos := data29.words[12];
  index := after + 1;
  last := data31.words[16];
  while index <= last do
  begin
    with data31.items[index] do
    begin
      select_item_icon(code);
      plot_item_icon(firstoff + firstpos, secondoff + secondpos)
    end;
    index := index + 1
  end;
  select_drawing_buffer(0, false)
end;
