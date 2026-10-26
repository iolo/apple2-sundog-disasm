{ system6:15 $0838..$0869, attributes$0874, nested in14. Candidate3,
  start2,finish1; local gap4. Strict comparisons retain the earlier candidate
  on ties. Update the parent's best and runner-up in original store order. }
procedure sys6_15(candidate, start, finish: integer);
var span: integer;
begin
  span := finish - start;
  if span > blocks then
  begin
    nextidx := bestidx;
    nextsz := blocks;
    bestidx := candidate;
    blocks := span
  end
  else if span > nextsz then
  begin
    nextsz := span;
    nextidx := candidate
  end
end;
