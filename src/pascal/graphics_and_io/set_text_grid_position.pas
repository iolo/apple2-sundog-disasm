{ library_22 procedure 46, $0886..$089E, attributes $08A8. }
procedure set_text_grid_position(column, row: integer);
begin
  data29.text_x := (data29.words[14] + 2) + 6 * column;
  data29.text_y := (data29.words[12] + 6) + 4 * row
end;
