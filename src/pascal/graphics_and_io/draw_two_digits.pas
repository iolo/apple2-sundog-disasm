{ library_22 procedure59, $0348..$0356, attributes $0360; nested in28. }
procedure draw_two_digits(value: integer);
begin
  draw_glyph(48 + value div 10);
  draw_glyph(48 + value mod 10)
end;
