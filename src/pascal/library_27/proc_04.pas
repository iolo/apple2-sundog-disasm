{ library_27 procedure 4, $008E..$00B5, attributes $00C0. }
procedure proc27_4(code: integer);
begin
  code := 2 * (code mod 32);
  if code > 31 then code := code + 32;
  data31.words[76] := code;
  data31.words[75] := code + 1;
  data31.words[74] := code + 32;
  data31.words[73] := code + 33
end;
