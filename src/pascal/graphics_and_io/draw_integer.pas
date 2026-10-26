{ library_22 procedure 39, $0676..$06B1, attributes $06BE.
  Width is not clamped; original SAS 15 capacity behavior is retained. }
procedure draw_integer(value, width: integer; zeroes: boolean);
var
  rendered: text15;
  padding: string[1];
begin
  if zeroes then padding := '0' else padding := ' ';
  integer_to_text(value, rendered);
  while width > length(rendered) do
    rendered := concat(padding, rendered);
  draw_text(rendered)
end;
