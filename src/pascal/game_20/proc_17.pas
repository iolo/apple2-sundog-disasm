{ game_20 procedure17, $0A96..$0ABE, attributes $0AC8; nested in16. }
procedure proc20_17(var value: integer; left, right: integer);
var
  factor: integer;
(*$include src/pascal/game_20/proc_18.pas*)
begin
  factor := 8 + proc22_35(left - right);
  if left >= right then value := proc20_18(factor, value, 8)
  else value := proc20_18(8, value, factor)
end;
