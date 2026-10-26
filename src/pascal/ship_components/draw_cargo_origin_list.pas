{ game_14 procedure6, $040E..$04D4, attributes $04E2.
  WITH captures each stock row before any drawing calls, as original slot9.
  Caption-table index is kind itself, not kind-1; city names use origin-1. }
procedure draw_cargo_origin_list;
var
  saved: bounds4;
  line: integer;
  index: integer;
  names: captionaddr;
  last: integer;
begin
  saved := data29.bounds11;
  data29.bounds11 := g14.caption_bounds;
  clear_text_window;
  write_wrapped_text('|||||CARGO');
  store_word(5120, names.word);
  index := 1;
  last := 2;
  while index <= last do
  begin
    with data29.stock234[index] do
      if kind > 0 then
      begin
        line := 4 * index - 1;
        set_text_grid_position(0, line);
        if data29.labels238[index] = 'Unknown' then
          data29.labels238[index] := names.table^[kind];
        write_wrapped_text(data29.labels238[index]);
        if (kind > 1) and (origin > 0) then
        begin
          set_text_grid_position(0, line + 2);
          write_wrapped_text('from ');
          write_wrapped_text(data29.names25.cities^[origin])
        end
      end;
    index := index + 1
  end;
  set_text_window(saved.lower_first, saved.upper_first, saved.lower_second, saved.upper_second)
end;
