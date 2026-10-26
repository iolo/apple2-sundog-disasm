{ library_22 procedure 38, $0602..$0668, attributes $0674.
  Keep the original signed negation, MOD/DIV loop and bounded string assignment;
  do not replace them with a host integer-formatting function. }
procedure integer_to_text(value: integer; var rendered: text15);
var
  digit: integer;
  digit_text: string[1];
  negative: boolean;
begin
  rendered := '';
  negative := false;
  if value < 0 then
  begin
    value := -value;
    negative := true
  end;
  digit_text := ' ';
  repeat
    digit := value mod 10;
    value := value div 10;
    digit_text[1] := chr(48 + digit);
    rendered := concat(digit_text, rendered)
  until value = 0;
  if negative then
  begin
    digit_text[1] := '-';
    rendered := concat(digit_text, rendered)
  end
end;
