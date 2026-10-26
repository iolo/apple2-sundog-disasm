{ library_22 procedure 35, $05A8..$05B6, attributes $05C0.
  Signed comparison and negation are retained, including word overflow behavior. }
function proc22_35(value: integer): integer;
begin
  if value < 0 then
    proc22_35 := -value
  else
    proc22_35 := value
end;
