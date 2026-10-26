{ Library 22:40, $06C0..$06CE, attributes $06D8. Two argument words.
  Native proc22_3 is effectful and must be called exactly once, including
  when the computed modulus is invalid. No new bounds check is introduced. }
function random_between(lower, upper: integer): integer;
var
  random_value: integer;
begin
  { Assignment forces the parameterless call in this reference compiler;
    its MOD parser otherwise treats a bare function name as a function value. }
  random_value := random_word;
  random_between := lower + (random_value mod ((upper - lower) + 1))
end;
