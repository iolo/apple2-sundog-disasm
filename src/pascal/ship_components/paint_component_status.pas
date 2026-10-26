{ game_14 procedure5, $0356..$0400, attributes $040C.
  For a value outside0..4, mode retains its previous (possibly uninitialized)
  word. The assembly supplies no default; do not invent one. }
procedure paint_component_status;
var
  value: integer;
  edge: integer;
  index: integer;
  base: integer;
  mode: integer;
  last: integer;
begin
  base := g14.group_byte_base + 4;
  index := 0;
  last := 3;
  while index <= last do
  begin
    value := data29.bytes[178 + (base + 5 * index)];
    case value of
      0: mode := 4;
      1,2,3: mode := 9;
      4: mode := 5
    end;
    apply_bounds(g14.row_lamps[index], mode);
    index := index + 1
  end;
  value := data29.bytes[178 + (base + 20)];
  if value = 16 then apply_bounds(g14.status_meter, 5)
  else if value = 0 then apply_bounds(g14.status_meter, 4)
  else
  begin
    edge := g14.words[74] - 4 * value;
    set_clip_bounds(g14.words[77], g14.words[76], edge, g14.words[74]);
    draw_clip_pattern(9);
    set_clip_bounds(g14.words[77], g14.words[76], g14.words[75], edge - 1);
    draw_clip_pattern(8)
  end;
  apply_bounds(data29.bounds11, 0)
end;
