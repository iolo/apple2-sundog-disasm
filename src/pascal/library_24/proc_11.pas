{ library_24 procedure11, $0274..$02A8, attributes $02B2.
  Read the VAR value before the random call, then retain ordered limit tests. }
procedure proc24_11(var value: integer);
var
  band: integer;
  before: integer;
  randomv: integer;
begin
  band := 4 - data29.words[214];
  before := value;
  randomv := proc22_3;
  value := (before + randomv mod (band + 1)) - proc22_31(band, 1);
  if value < -band then value := -band
  else if value > band then value := band
end;
