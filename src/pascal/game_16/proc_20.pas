{ game_16 procedure20, $07A8..$07E0, attributes $07EA.
  Flush only at a space past position60. Capitalization subtracts32 from any
  code>=97, without an invented upper bound; stores remain unchecked bytes. }
procedure proc16_20(code: integer);
begin
  if (code = 32) and (next > 60) then proc16_19;
  if odd(capital) and (code >= 97) then code := code - 32;
  if (code >= 65) or (code = 44) then capital := 0;
  line.bytes[next] := code;
  next := next + 1
end;
