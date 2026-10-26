{ library_22 procedure 21, $0254..$0281, attributes $028C. }
procedure proc22_21(value: integer; first: boolean);
var
  saved: integer;
begin
  if value = 0 then
  begin
    saved := data29.words[356];
    data29.words[356] := data29.words[355];
    data29.words[355] := saved
  end
  else if first then proc22_23(value, data29.words[355])
  else proc22_23(value, data29.words[356])
end;
