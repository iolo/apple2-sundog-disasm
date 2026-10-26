{ library_22 procedure 46, $0886..$089E, attributes $08A8. }
procedure proc22_46(column, row: integer);
begin
  data29.words[19] := (data29.words[14] + 2) + 6 * column;
  data29.words[18] := (data29.words[12] + 6) + 4 * row
end;
