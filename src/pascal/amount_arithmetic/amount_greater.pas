{ library_28 procedure6, $00FE..$0122, attributes $012C.
  Strict lexicographic comparison of the two signed words; equality is false. }
function amount_greater(left, right: wordpair): boolean;
begin
  amount_greater := false;
  if left.first > right.first then amount_greater := true
  else if (left.first = right.first) and (left.second > right.second) then
    amount_greater := true
end;
