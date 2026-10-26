{ library_25 procedure5, $01E2..$0204, attributes $020E.
  The output store precedes the packed code write, preserving VAR aliasing.
  Only an upper bound is tested in the original. }
procedure replace_menu_code(newcode, index: integer; var oldcode: integer);
begin
  if index > data30.nitems then oldcode := 0
  else
    with data30.items[index] do
    begin
      oldcode := tag.code;
      tag.code := newcode
    end
end;
