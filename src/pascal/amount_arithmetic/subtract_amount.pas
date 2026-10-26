{ library_28 procedure3, $006E..$0081, attributes $008A. }
procedure subtract_amount(subtrahend: wordpair; var accumulator: wordpair);
var
  negated_amount: wordpair;
begin
  negated_amount.second := -subtrahend.second;
  negated_amount.first := -subtrahend.first;
  add_amount(negated_amount, accumulator)
end;
