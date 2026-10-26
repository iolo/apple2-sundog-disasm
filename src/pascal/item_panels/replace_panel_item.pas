{ library_27 procedure 7, $0156..$01D6, attributes $01E0.
  Captures the entry before the index/count test, as the original does.
  Keep VAR stores, rereads and drawing in their original order. }
procedure replace_panel_item(newcode, index: integer; var oldcode, firstpos, secondpos: integer);
var
  byteidx: integer;
  newsecond: integer;
  newfirst: integer;
begin
  set_glyph_mode(1);
  with data31.items[index] do
  begin
    newfirst := firstoff + data29.words[14];
    newsecond := secondoff + data29.words[12];
    if index > data31.words[16] then oldcode := 0
    else oldcode := code;
    code := newcode
  end;
  byteidx := (index - data31.words[14]) - 1;
  if (0 <= byteidx) and (byteidx <= 3) then
    data29.bytes[122 + byteidx] := newcode;
  if newcode > 0 then
  begin
    plot_item_icon(firstpos, secondpos);
    plot_item_icon(newfirst, newsecond)
  end
  else
  begin
    firstpos := newfirst;
    secondpos := newsecond
  end;
  if oldcode > 0 then
  begin
    select_item_icon(oldcode);
    plot_item_icon(newfirst, newsecond);
    plot_item_icon(firstpos, secondpos)
  end
end;
