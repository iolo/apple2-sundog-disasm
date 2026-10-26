{ library_24 procedure11, $0274..$02A8, attributes $02B2.
  Read the VAR value before the random call, then retain ordered limit tests. }
procedure perturb_target_velocity(var value: integer);
var
  band: integer;
  before: integer;
  randomv: integer;
begin
  band := 4 - data29.target_class;
  before := value;
  randomv := random_word;
  value := (before + randomv mod (band + 1)) - right_shift_word(band, 1);
  if value < -band then value := -band
  else if value > band then value := band
end;
