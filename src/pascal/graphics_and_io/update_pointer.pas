{ library_22 procedure 43, $0806..$0829, attributes $0834. }
procedure update_pointer(var firstpos, secondpos: integer);
var
  newsecond, newfirst: integer;
begin
  read_pointer_position(newfirst, newsecond);
  if (newfirst <> firstpos) or (newsecond <> secondpos) then
  begin
    toggle_pointer_glyph(firstpos, secondpos);
    firstpos := newfirst;
    secondpos := newsecond;
    toggle_pointer_glyph(firstpos, secondpos)
  end
end;
