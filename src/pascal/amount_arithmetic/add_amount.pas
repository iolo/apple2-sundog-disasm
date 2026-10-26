{ library_28 procedure2, $0000..$0063, attributes $006C.
  wordpair.first is the high part; second is the low part. The value copy
  precedes every accumulator write, including when the arguments alias. }
procedure add_amount(addend: wordpair; var accumulator: wordpair);
var
  low_part_sum: integer;
begin
  low_part_sum := accumulator.second + addend.second;
  accumulator.second := low_part_sum mod 1000;
  if low_part_sum < 0 then accumulator.second := -accumulator.second;
  accumulator.first := low_part_sum div 1000 + addend.first + accumulator.first;
  if (accumulator.first < 0) and (accumulator.second > 0) then
  begin
    accumulator.second := accumulator.second - 1000;
    accumulator.first := accumulator.first + 1
  end;
  if (accumulator.first > 0) and (accumulator.second < 0) then
  begin
    accumulator.second := accumulator.second + 1000;
    accumulator.first := accumulator.first - 1
  end
end;
