{ library_22 procedure 38, $0602..$0668, attributes $0674.
  Keep the original signed negation, MOD/DIV loop and bounded string assignment;
  do not replace them with a host integer-formatting function. }
procedure proc22_38(value: integer; var rendered: text15);
var
  digit: integer;
  glyph: string[1];
  negative: boolean;
begin
  rendered := '';
  negative := false;
  if value < 0 then
  begin
    value := -value;
    negative := true
  end;
  glyph := ' ';
  repeat
    digit := value mod 10;
    value := value div 10;
    glyph[1] := chr(48 + digit);
    rendered := concat(glyph, rendered)
  until value = 0;
  if negative then
  begin
    glyph[1] := '-';
    rendered := concat(glyph, rendered)
  end
end;
