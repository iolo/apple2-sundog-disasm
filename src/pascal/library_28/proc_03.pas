{ library_28 procedure3, $006E..$0081, attributes $008A. }
procedure proc28_3(value: wordpair; var accumulator: wordpair);
var
  negative: wordpair;
begin
  negative.second := -value.second;
  negative.first := -value.first;
  proc28_2(negative, accumulator)
end;
