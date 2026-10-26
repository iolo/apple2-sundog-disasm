{ library_27 procedure15, $0428..$0442, attributes $044C. Lexical level1. }
procedure proc27_15(firstpos, secondpos, index: integer);
var
  code: integer;
begin
  code := data29.bytes[122 + index];
  proc27_5(code, firstpos + 7, secondpos + 8);
  if code = 0 then proc27_12(data31.words[16])
end;
