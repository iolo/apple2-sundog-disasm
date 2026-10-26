{ game_21 procedure2, $0000..$0014, attributes $001E.
  One wrap only; this is not a general modulo operation. }
function proc21_2(value, base, period: integer): integer;
begin
  if value >= base then proc21_2 := value - base
  else proc21_2 := period + value - base
end;
