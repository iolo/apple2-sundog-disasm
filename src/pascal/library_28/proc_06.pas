{ library_28 procedure6, $00FE..$0122, attributes $012C.
  Strict lexicographic comparison of the two signed words; equality is false. }
function proc28_6(left, right: wordpair): boolean;
begin
  proc28_6 := false;
  if left.first > right.first then proc28_6 := true
  else if (left.first = right.first) and (left.second > right.second) then
    proc28_6 := true
end;
