{ Library 22:40, $06C0..$06CE, attributes $06D8. Two argument words.
  Native proc22_3 is effectful and must be called exactly once, including
  when the computed modulus is invalid. No new bounds check is introduced. }
function proc22_40(lower, upper: integer): integer;
var
  randomv: integer;
begin
  { Assignment forces the parameterless call in this reference compiler;
    its MOD parser otherwise treats a bare function name as a function value. }
  randomv := proc22_3;
  proc22_40 := lower + (randomv mod ((upper - lower) + 1))
end;
