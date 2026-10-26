{ library_22 procedure 35, $05A8..$05B6, attributes $05C0.
  Signed comparison and negation are retained, including word overflow behavior. }
function word_abs(value: integer): integer;
begin
  if value < 0 then
    word_abs := -value
  else
    word_abs := value
end;
