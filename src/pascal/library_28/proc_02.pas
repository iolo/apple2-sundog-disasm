{ library_28 procedure2, $0000..$0063, attributes $006C.
  wordpair.first is the high part; second is the low part. The value copy
  precedes every accumulator write, including when the arguments alias. }
procedure proc28_2(value: wordpair; var accumulator: wordpair);
var
  lowtotal: integer;
begin
  lowtotal := accumulator.second + value.second;
  accumulator.second := lowtotal mod 1000;
  if lowtotal < 0 then accumulator.second := -accumulator.second;
  accumulator.first := lowtotal div 1000 + value.first + accumulator.first;
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
