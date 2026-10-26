{ library_27 procedure15, $0428..$0442, attributes $044C. Lexical level1. }
procedure append_inventory_item(firstpos, secondpos, index: integer);
var
  code: integer;
begin
  code := data29.bytes[122 + index];
  append_panel_item(code, firstpos + 7, secondpos + 8);
  if code = 0 then draw_empty_item_marker(data31.words[16])
end;
