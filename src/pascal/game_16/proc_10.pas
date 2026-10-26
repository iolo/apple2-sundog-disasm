{ game_16 procedure10, $0234..$0251, attributes $025C.
  Capture the byte before calling9. For index4, halve that captured value
  afterward, regardless of the Boolean result. }
function proc16_10(index, adjust: integer): boolean;
var
  saved: integer;
begin
  saved := data29.bytes[94 + index];
  proc16_10 := proc16_9(saved + adjust);
  if index = 4 then data29.bytes[94 + index] := saved div 2
end;
