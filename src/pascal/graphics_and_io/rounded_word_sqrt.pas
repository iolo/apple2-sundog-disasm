{ library_22 procedure36, $05C2..$05F4, attributes $0600.
  Keep the odd-number accumulation and native shift. No overflow repair or
  floating-point square-root substitution is implied by this recovery. }
function rounded_word_sqrt(value: integer): integer;
var
  candidate: integer;
  square_sum: integer;
  odd_step: integer;
begin
  odd_step := -1;
  square_sum := 0;
  repeat
    odd_step := odd_step + 2;
    square_sum := square_sum + odd_step
  until value < square_sum;
  candidate := right_shift_word(odd_step, 1) + 1;
  if value > square_sum - candidate then rounded_word_sqrt := candidate
  else rounded_word_sqrt := candidate - 1
end;
