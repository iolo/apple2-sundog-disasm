{ game_21 procedure2, $0000..$0014, attributes $001E.
  One wrap only; this is not a general modulo operation. }
function wrapped_map_offset(value, base, period: integer): integer;
begin
  if value >= base then wrapped_map_offset := value - base
  else wrapped_map_offset := period + value - base
end;
