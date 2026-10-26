{ game_19 procedure22, $10AE..$10D6, attributes $10E0; nested in21. }
procedure proc19_22(var value: integer; left, right: integer);
var
  factor: integer;
(*$include src/pascal/game_19/proc_23.pas*)
begin
  factor := 8 + proc22_35(left - right);
  if left >= right then value := proc19_23(factor, value, 8)
  else value := proc19_23(8, value, factor)
end;
