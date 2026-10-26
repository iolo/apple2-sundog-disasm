{ library_22 procedure 21, $0254..$0281, attributes $028C. }
procedure select_drawing_buffer(value: integer; first: boolean);
var
  saved: integer;
begin
  if value = 0 then
  begin
    saved := data29.secondary_buffer;
    data29.secondary_buffer := data29.primary_buffer;
    data29.primary_buffer := saved
  end
  else if first then store_word(value, data29.primary_buffer)
  else store_word(value, data29.secondary_buffer)
end;
