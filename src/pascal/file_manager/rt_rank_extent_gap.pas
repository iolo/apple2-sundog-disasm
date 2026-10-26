{ system6:15 $0838..$0869, attributes$0874, nested in14. Candidate3,
  start2,finish1; local gap4. Strict comparisons retain the earlier candidate
  on ties. Update the parent's best and runner-up in original store order. }
procedure rt_rank_extent_gap(candidate, start, finish: integer);
var span: integer;
begin
  span := finish - start;
  if span > blocks then
  begin
    runner_index := best_index;
    runner_size := blocks;
    best_index := candidate;
    blocks := span
  end
  else if span > runner_size then
  begin
    runner_size := span;
    runner_index := candidate
  end
end;
